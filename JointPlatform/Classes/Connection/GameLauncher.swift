//
//  GameLauncher.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/21.
//

import UIKit
import SwiftyJSON

protocol GameLauncherDelegate:NSObjectProtocol{
    
    func gameLauncher(_ launcher:GameLauncher,onUpdateFor player:GameRoomPlayer,state:GameLauncher.LaunchState)
    
    func gameLauncher(_ launcher:GameLauncher,timerUpdateWith remain:Double)
    
    func launchCompleted()
    
    /// 0 = no error
    /// 1 = timeout
    /// 2 = lack of players
    /// 3 = assets load failed
    func launchFailed(_ launcher:GameLauncher,withError code:Int)
    
}

protocol GameLauncherDataSource:NSObjectProtocol{
    
    func gameLauncherRequestForRoom() -> GameRoom
    
}

protocol GameLauncherAssetsProvider:NSObjectProtocol{
    
    func gameLauncher(_ launcher:GameLauncher,assetsFor key:String) -> Data?
}

///资源类型标识符
enum AssetsKey:String{
    case Image = "imageName"
    case GameIcon = "gameIcon"
}

///游戏资源加载器，负责在游戏开始前和手柄端进行资源同步
class GameLauncher:NSObject{
    
    enum LaunchState{
        case Prepare
        case AssetsSync
        case InitLayout
        case PrepareComplete
        case PrepareFailed
        case Offline
    }
    
    
    private var roomModel:GameRoom?
    
    private var connector:GameRoomConnector?
    
    private var playerState:[String:LaunchState] = [:]
    
    private var syncDictionary:[String:Any] = [:]
    
    private var isAssetsLoaded:Bool = false
    
    private var gameConfig:[String:Any] = [:]
    
    private var gameProfile:GameProfile?
    
    private var launchTimer:Timer?
    
    private var _isLaunching:Bool = false{
        didSet{
            if _isLaunching{
                NotificationCenter.customAddObserver(self, selector: #selector(onGamerEchoArrive(_:)), name: .GamerEcho, object: nil)
            }
            else{
                launchTimer?.invalidate()
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    
    private var completedCount:Int = 0
    
    private var launchTimeRemain:Double = 0
    
    public weak var delegate:GameLauncherDelegate?
    
    public weak var dataSource:GameLauncherDataSource?
    
    public weak var assetsProvider:GameLauncherAssetsProvider?
    
    public var launchTimeout:TimeInterval = 60
    
    
    public var isLaunching:Bool{
        get{
            return _isLaunching
        }
    }
    
    func setSyncConfig(_ dic:[String:Any]){
        self.gameConfig = dic
        self.isAssetsLoaded = false
    }
    
    func setConnector(_ connector:GameRoomConnector?){
        self.connector = connector
    }
    
    func startProcedure() -> Bool {
        
        guard self.connector?.isConnected ?? false else {
            debugLog("[Game Launcher] connector is not connected")
            return false
        }
        
        self.roomModel = dataSource?.gameLauncherRequestForRoom()
        
        guard self.roomModel != nil else {
            debugLog("[Game Launcher] room model is not define")
            return false
        }
        
        //connector?.allowNewConnection(false)
        
        //check stick layout
        guard let stickConfig = gameConfig["joyStick"] as? [String:Any] else { return false }
        
        
        guard let gameProfile =  gameConfig["profile"] as? GameProfile else { return false }
        self.gameProfile = gameProfile
        //check assets version
        guard let assetsConfig = gameConfig["assets"] as? [String:Any] else {
            debugLog("[Game Launcher] assets config is not defined")
            return false
        }
        
        guard let assetsVersion = assetsConfig["version"] as? String else {
            debugLog("[Game Launcher] assets version is not defined")
            return false
        }
        
        NotificationCenter.customAddObserver(self, selector: #selector(onGamerDisconnected(_:)), name: .GamerDisconnected, object: nil)
        
        let needRefresh = assetsConfig["forceRefresh"] as? Bool ?? false
        
        _isLaunching = true
        completedCount = 0
        isAssetsLoaded = false
        
        launchTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onLaunchTimerUpdate), userInfo: nil, repeats: true)
        launchTimeRemain = launchTimeout
        
        //init player state
        self.playerState = [:]
        for player in roomModel!.players{
            self.playerState[player.playerId] = .Prepare
            delegate?.gameLauncher(self, onUpdateFor: player, state: .Prepare)
        }
        
        
        //1. send local assets version
        guard connector?.syncAll(.gamePrepare, message: [
            "assets":[
                "version":assetsVersion,
                "forceRefresh":needRefresh,
            ],
            "stickConfig":stickConfig
        ]) ?? false else {
            debugLog("[GameLauncher] send game prepare failed")
            return false
        }
        
        debugLog("[GameLauncher] wait for assets verify")
        //2. wait for request of assets.
        
        return true
    }
    
    func terminateProcedure(){
        NotificationCenter.default.removeObserver(self)
        _isLaunching = false
    }
    
    private func loadAssets() -> Bool {
        guard let stickConfig = gameConfig["joyStick"] as? [String:Any] else { return false }
        guard let components = stickConfig["components"] as? [[String:Any]] else { return false }
        //prepare assets Data
        var assetsDictionary:[String:Data] = [:]
        for component in components {
            if let imageKey = component[AssetsKey.Image.rawValue] as? String{
                guard let imageData = assetsProvider?.gameLauncher(self, assetsFor: imageKey) else {
                    debugLog("[Runner] prepare : image(\(imageKey)) data is not found")
                    self._isLaunching = false
                    return false
                }
                assetsDictionary[imageKey] = imageData
            }
        }
        
        //append icon data if set
        if let iconName = gameConfig[AssetsKey.GameIcon.rawValue] as? String {
            if let iconData = assetsProvider?.gameLauncher(self, assetsFor: iconName){
                assetsDictionary["gameIconKey"] = iconData
            }
        }
        
        syncDictionary = [
            "assetsCount":assetsDictionary.count,
            "assetsData":assetsDictionary
        ]
        return true
    }
    
    @objc private func onLaunchTimerUpdate(){
        launchTimeRemain -= 1
        delegate?.gameLauncher(self, timerUpdateWith: launchTimeRemain)
        if launchTimeRemain <= 0{
            delegate?.launchFailed(self, withError: 1)
            guard connector?.syncAll(.gamePrepareFailed, message: nil) ?? false else {
                debugLog("[GameLauncher] send game prepare failed to others failed")
                return
            }
            _isLaunching = false
            launchTimer?.invalidate()
        }
    }
    
    @objc
    private func onGamerDisconnected(_ notification:Notification){
        
        guard _isLaunching else { return }
        
        guard let gamer = notification.userInfo?[JtUserInfo.Key.Gamer] as? GameUser else { return }
        
        //gamer offline while launching
        
        for player in self.roomModel!.players{
            if player.user.uid == gamer.uid{
                delegate?.gameLauncher(self, onUpdateFor: player, state: .Offline)
                if self.playerState[player.playerId] == .PrepareComplete{
                    completedCount -= 1
                }
                self.playerState.removeValue(forKey: player.playerId)
            }
        }
        
        //if player is not enough for game then launch failed
        if self.playerState.keys.count < self.roomModel!.game.minPlayerCount{
            delegate?.launchFailed(self, withError: 2)
            guard connector?.syncAll(.gamePrepareFailed, message: nil) ?? false else {
                debugLog("[GameLauncher] send game prepare failed to others failed")
                return
            }
        }
        
        
    }
}


extension GameLauncher{
    
    
    @objc private func onGamerEchoArrive(_ notification:Notification){
        guard _isLaunching else { return }
        guard let gamer = notification.userInfo?[JtUserInfo.Key.Gamer] as? GameUser else { return }
        guard let data = notification.userInfo?[JtUserInfo.Key.Data] as? Data else { return }
        
        let Json = JSON(data)
        
        switch Json["type"].stringValue{
        case GameSync.Symbol.gameAssetsRequest.rawValue:
            for player in roomModel!.players{
                if player.user.uid == gamer.uid{
                    // send game assets
                    if !isAssetsLoaded {
                        guard loadAssets() else {
                            debugLog("[GameLauncher] load assets failed")
                            delegate?.launchFailed(self, withError: 3)
                            guard connector?.syncAll(.gamePrepareFailed, message: nil) ?? false else {
                                debugLog("[GameLauncher] send game prepare failed to others failed")
                                return
                            }
                            _isLaunching = false
                            return
                        }
                    }
                    guard let dataDictionary = syncDictionary["assetsData"] as? [String:Data] else {
                        debugLog("[GameLauncher] assets data dictionary is not define")
                        delegate?.launchFailed(self, withError: 3)
                        guard connector?.syncAll(.gamePrepareFailed, message: nil) ?? false else {
                            debugLog("[GameLauncher] send game prepare failed to others failed")
                            return
                        }
                        return
                    }
                    playerState[player.playerId] = .AssetsSync
                    guard connector?.syncTo(.gameAssetsSyncPrepare, player: player, message: [
                        "assetsCount":syncDictionary["assetsCount"]
                    ]) ?? false else {
                        debugLog("[GameLauncher] send game prepare assets info to player(\(player.user.nickName)) failed")
                        return
                    }
                    guard connector?.syncTo(.gameAssets, player: player, message: dataDictionary) ?? false else {
                        debugLog("[GameLauncher] send game prepare failed to others failed")
                        return
                    }
                    debugLog("[GameLauncher] sync assets to player(\(player.user.nickName))")
                    delegate?.gameLauncher(self, onUpdateFor: player, state: .AssetsSync)
                }
            }
        case GameSync.Symbol.initLayout.rawValue:
            for player in roomModel!.players{
                if player.user.uid == gamer.uid{
                    debugLog("[GameLauncher] player(\(player.user.nickName)) init layout")
                    playerState[player.playerId] = .InitLayout
                    delegate?.gameLauncher(self, onUpdateFor: player, state: .InitLayout)
                }
            }
        case GameSync.Symbol.gamePrepareDone.rawValue:
            for player in roomModel!.players{
                if player.user.uid == gamer.uid{
                    playerState[player.playerId] = .PrepareComplete
                    completedCount += 1
                    delegate?.gameLauncher(self, onUpdateFor: player, state: .PrepareComplete)
                    //if is all completed
                    if completedCount == playerState.keys.count{
                        guard connector?.syncAll(.gameStart, message: nil) ?? false else {
                            debugLog("[GameLauncher] sync game start failed")
                            return
                        }
                        debugLog("[GameLauncher] launch completed with players :\(completedCount)")
                        delegate?.launchCompleted()
                        _isLaunching = false
                    }
                }
            }
        case GameSync.Symbol.gamePrepareFailed.rawValue:
            for player in roomModel!.players{
                if player.user.uid == gamer.uid{
                    playerState[player.playerId] = .PrepareFailed
                    delegate?.gameLauncher(self, onUpdateFor: player, state: .PrepareFailed)
                    //if all player
                    debugLog("[GameLauncher] player(\(player.user.nickName)) prepare failed")
                    var finishedPlayerCount:Int = 0
                    
                    for pState in playerState.values{
                        if pState == .PrepareComplete || pState == .PrepareFailed{
                            finishedPlayerCount += 1
                        }
                    }
                    //if all player finished
                    if finishedPlayerCount == playerState.keys.count{
                        //if player is still enough
                        if completedCount >= gameProfile!.minPlayerCount{
                            //launch finished
                            debugLog("[GameLauncher] launch completed but some player prepare failed")
                            delegate?.launchCompleted()
                            _isLaunching = false
                        }
                        else{
                            debugLog("[GameLauncher] launch failed , player is not enough , sync others to terminate game")
                            guard connector?.syncExpect(.gamePrepareFailed, player: player, message: nil) ?? false else {
                                debugLog("[GameLauncher] tell other to terminate failed")
                                return
                            }
                            delegate?.launchFailed(self, withError: 2)
                        }
                    }
                    
                    
                }
            }
        default:
            break
        }
    }

    
}
