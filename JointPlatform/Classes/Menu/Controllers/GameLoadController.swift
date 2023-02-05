//
//  GameLoadController.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/2/13.
//

import UIKit
import SnapKit

class GameLoadController: WordsTransController {
    
    struct LoadingRoomConfig{
        
        var inGamePlayers:[InGamePlayer]!
        
        var map:GameMap!
        
    }
    
    enum PlayerLoadState{
        case Preparing
        case AssetsFetching
        case InitLayout
        case Done
        case Failed
        case Offline
    }
    
    struct LoadingRoomPlayer{
        var gamePlayer:InGamePlayer
        var state:PlayerLoadState
    }
    
    public weak var roomController:GameRoomController?
    
    private var loadPlayers:[LoadingRoomPlayer] = []
    
    private var loadConfig:LoadingRoomConfig!
    
    
    override var backgroundFadeColor: UIColor{
        get{
            return .init(hex: "#ee4747")!
        }
        set{
            
        }
    }
    
    
    override var backgroundWordsImageName: String{
        get{
            return "back_words_loading"
        }
        set{ }
    }
    
    
    override var resetXOffset: CGFloat{
        get{
            return 572
        }
        set{
            
        }
    }
    
    
    
    private lazy var playerInfoTableView:UITableView = {
        let view = UITableView()
        view.register(UINib(nibName: "GameLoadPlayerTableCell", bundle: .main), forCellReuseIdentifier: "playerCell")
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.3)
        view.layer.cornerRadius = 10
        view.separatorColor = .clear
        view.isScrollEnabled = false
        return view
    }()
    
    
    private lazy var bottomTipsLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        label.text = "正在加载..."
        label.textAlignment = .right
        return label
    }()
    
    private lazy var loadIndicator:CULoadingIndicator = CULoadingIndicator()
    
    private var tableViewSize:CGSize{
        get{
            let width = SCREEN_WIDTH * 0.4
            let height = width * 0.8
            return CGSize(width: width, height: height)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadIndicator.pause()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Server.instance.roomManager()?.allowNewPlayerJoin(false)
        guard Server.instance.roomManager()?.launcher?.startProcedure() ?? false else {
            ZxHUD.shared.display(type: .Error, title: "游戏加载失败", duration: 2)
            self.navigationController?.popViewController(animated: true)
            return
        }
    }
    
    deinit{
        debugLog("[GameLoadController] deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("[GameLoadController] init")
        self.contentView.addSubview(playerInfoTableView)
        self.contentView.addSubview(loadIndicator)
        self.contentView.addSubview(bottomTipsLabel)
        playerInfoTableView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(tableViewSize)
        }
        loadIndicator.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.bottom.equalTo(-UIApplication.shared.windows.first!.safeAreaInsets.bottom)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        bottomTipsLabel.snp.makeConstraints { make in
            make.right.equalTo(loadIndicator.snp.left).offset(-10)
            make.centerY.equalTo(loadIndicator)
            make.left.equalToSuperview()
        }
        loadIndicator.setSize(CGSize(width: 35, height: 35))
        loadIndicator.setStroke(color: .white)
        loadIndicator.play()
        
        Server.instance.roomManager()?.launcher?.setSyncConfig(gameConfig)
        Server.instance.roomManager()?.launcher?.delegate = self
        Server.instance.roomManager()?.launcher?.assetsProvider = self
        
    }
    
    func setLoadingConfig(_ config:LoadingRoomConfig){
        var loadGamers:[LoadingRoomPlayer] = []
        for p in config.inGamePlayers{
            loadGamers.append(LoadingRoomPlayer(gamePlayer: p, state: .Preparing))
        }
        self.loadPlayers = loadGamers
        self.loadConfig = config
    }
    

}

extension GameLoadController:UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadPlayers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "playerCell")!
        tableCell.setup(model: loadPlayers[indexPath.row].gamePlayer)
        (tableCell as? GameLoadPlayerTableCell)?.setLoading(state: loadPlayers[indexPath.row].state)
        tableCell.selectionStyle = .none
        return tableCell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewSize.height/4
    }
    
}


extension GameLoadController:GameLauncherDelegate{
    func launchFailed(_ launcher: GameLauncher, withError code: Int) {
        switch code{
        case 1:
            ZxHUD.shared.display(type: .Error, title: "游戏加载超时",duration: 1.5)
        case 2:
            ZxHUD.shared.display(type: .Error, title: "玩家不足",duration: 1.5)
        case 3:
            ZxHUD.shared.display(type: .Error, title: "资源加载失败",duration: 1.5)
        default:
            ZxHUD.shared.display(type: .Error, title: "未知错误",duration: 1.5)
            break
        }
        self.navigationController?.popViewController(animated: true)
    }
    

    
    func gameLauncher(_ launcher: GameLauncher, timerUpdateWith remain: Double) {
        self.bottomTipsLabel.text = "正在等待(\(Int(remain))).."
    }
    
    
    func gameLauncher(_ launcher: GameLauncher, onUpdateFor player: GameRoomPlayer, state: GameLauncher.LaunchState) {
        for (idx,loadPlayer) in self.loadPlayers.enumerated(){
            if loadPlayer.gamePlayer.lanPlayer.playerId == player.playerId{
                switch state{
                case .Prepare:
                    loadPlayers[idx].state = .Preparing
                case .AssetsSync:
                    loadPlayers[idx].state = .AssetsFetching
                case .InitLayout:
                    loadPlayers[idx].state = .InitLayout
                case .PrepareComplete:
                    loadPlayers[idx].state = .Done
                case .Offline:
                    ZxHUD.shared.display(type: .Error, title: "玩家(\(player.user.nickName))连接丢失",duration: 1.5)
                    loadPlayers[idx].state = .Offline
                case .PrepareFailed:
                    loadPlayers[idx].state = .Failed
                }
                self.playerInfoTableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .none)
                break
            }
        }
    }
    
    func launchCompleted() {
        let classType:AnyClass? = GameViewController.classForCoder()
        let viewControllerClass = classType as! GameBaseController.Type
        let controller = viewControllerClass.init(nibWithName: "GameBaseController", bundle: .main)
        controller!.initializeScene(loadConfig.map)
        controller!.initializePlayer(loadConfig.inGamePlayers)
        controller!.roomController = self.roomController
        self.bottomTipsLabel.text = "正在加载场景.."
        Server.instance.roomManager()?.stickCommander?.enable = true
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            [weak self] in
            self?.navigationController?.pushViewController(controller!, animated: true)
        }
    }
    
    
}


extension GameLoadController:GameLauncherAssetsProvider{
    func gameLauncher(_ launcher: GameLauncher, assetsFor key: String) -> Data? {
        return UIImage(named: key)?.pngData()
    }
}


