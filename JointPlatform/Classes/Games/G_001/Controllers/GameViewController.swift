//
//  G_001_Controller.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/8.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: GameBaseController {
    
    var isGameRunning:Bool = false
    
    private var room:GameRoom!
    
    private let sceneHeight:CGFloat = 700
    
    private var gamePlayers:[InGamePlayer] = []
    
    private var playersInTeam:[Int:[InGamePlayer]] = [:]
    
    private var audioPlayer:AVAudioPlayer!
    
    private weak var gameScene:BaseScene?
    
    private var map:GameMap!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("[GameViewController] game controller init")
        
        NotificationCenter.customAddObserver(self, selector: #selector(onPlayerDisconnected(_:)), name: .PlayerExit, object: nil)
        
        self.view.frame = CGRect(origin: .zero, size: UIScreen.main.bounds.size)
        self.view.backgroundColor = UIColor.black
        PlayerControlCenter.shared.initialize()
        
        for player in gamePlayers {
            let team = player.team
            if playersInTeam[team] == nil{
                playersInTeam[team] = []
            }
            playersInTeam[team]!.append(player)
        }
        
        switch self.map{
        case .Forest:
            initScene(named:"TestScene")
        case .Lab:
            initScene(named: "LabScene")
        default:
            ZxHUD.shared.display(type: .Error, title: "地图不存在",duration: 2)
        }
        
    }
    
    deinit{
        debugLog("[GameViewController] game controller deinit")
        NotificationCenter.default.removeObserver(self)
        Server.instance.roomManager()?.stickCommander?.enable = false
    }
    
    override func initializeScene(_ map: GameMap) {
        self.map = map
    }
    
    
    override func initializePlayer(_ inGamePlayers: [InGamePlayer]) {
        self.gamePlayers = inGamePlayers
    }
    
    
    func initScene(named name:String){
        if let view = self.view as! SKView? {
            print("[GameViewController] try load game kit scene")
            if let scene = GKScene(fileNamed: name){
                if let sceneNode = scene.rootNode as? BaseScene{
                    sceneNode.initEntities(scene.entities)
                    sceneNode.graphs = scene.graphs
                    sceneNode.addPlayers(playersInTeam, players: gamePlayers)
                    sceneNode.gameController = self
                    sceneNode.scaleMode = .aspectFill
                    let screenSize = UIScreen.main.bounds.size
                    sceneNode.size = CGSize(width: sceneHeight * screenSize.width / screenSize.height, height: sceneHeight)
                    view.ignoresSiblingOrder = true
                    view.showsFPS = true
                    view.showsNodeCount = true
                    print("[GameViewController] scene present")
                    view.presentScene(sceneNode)
                    self.gameScene = sceneNode
                }
                else{
                    print("[GameViewController] root node is not base scene")
                }
            }
            else{
                print("[GameViewController] scene is not gkscene")
            }
        }
    }
    
    
    override func terminateGame() {
        guard Server.instance.roomManager()?.stickCommander?.syncAll(.Terminate, config: nil) ?? false else {
            debugLog("[GameViewContoller] sync all terminate failed")
            return
        }
        self.navigationController?.popToViewController(self.roomController!, animated: true)
        self.gameScene?.removeFromParent()
        self.gameScene = nil
    }
    
}

extension GameViewController{
    
    @objc
    private func onPlayerDisconnected(_ notification:Notification){
        
        guard let offlinePlayer = notification.userInfo?[JtUserInfo.Key.Value] as? GameRoomPlayer else { return }
        //refresh game logic remove player if needed. or make a symbol
        
        //check player is still enough
        for (index,gamePlayer) in self.gamePlayers.enumerated(){
            if gamePlayer.lanPlayer.playerId == offlinePlayer.playerId{
                var isFind = false
                //find which team it belong to.
                for teamSide in self.playersInTeam.keys{
                    guard !isFind else { break }
                    for (idx,teamPlayer) in self.playersInTeam[teamSide]!.enumerated(){
                        if teamPlayer.lanPlayer.playerId == gamePlayer.lanPlayer.playerId{
                            //find the team
                            self.playersInTeam[teamSide]!.remove(at: idx)
                            
                            //modify game logic ...
                            self.gameScene?.onPlayerOffline(teamPlayer)
                            
                            isFind = true
                            break
                        }
                    }
                }
                
                //must find
                self.gamePlayers.remove(at: index)
                guard let gameProfile = Server.instance.roomManager()?.room?.game else { break }
                if self.gamePlayers.count < gameProfile.minPlayerCount{
                    //player is not enough
                    //terminate game
                    guard Server.instance.roomManager()?.stickCommander?.syncAll(.Terminate, config: nil) ?? false else {
                        debugLog("[GameViewContoller] sync all terminate failed")
                        return
                    }
                    ZxHUD.shared.display(type: .Error, title: "玩家人数不足", duration: 2)
                    self.navigationController?.popToViewController(self.roomController!, animated: true)
                }
                
                break
            }
        }
        
    }
    
    
}

