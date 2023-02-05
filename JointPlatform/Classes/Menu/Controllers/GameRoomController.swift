//
//  GameRoomController.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/2/13.
//

import UIKit

class GameRoomController: WordsTransController {
    
    override var backgroundFadeColor: UIColor{
        get{
            return UIColor(hex: "#e99900")!
        }
        set{ }
    }
    
    
    override var backgroundWordsImageName: String{
        get{
            return "back_words_game_room"
        }
        set{ }
    }
    
    
    override var resetXOffset: CGFloat{
        get{
            return 789
        }
        set{ }
    }
    
    private lazy var collectionLayout:UICollectionViewLayout = {
        let layout = GameRoomPlayerCollectionLayout()
        //layout.itemSize = CGSize(width: 8, height: 10)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        return layout
    }()
    
    private lazy var playerCollectionView:UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionLayout)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = UIColor.clear
        view.register(UINib(nibName: "GameRoomPlayerCollectionCell", bundle: .main), forCellWithReuseIdentifier: "playerCell")
        view.register(UINib(nibName: "GameRoomEmptyCollectionCell", bundle: .main), forCellWithReuseIdentifier: "emptyCell")
        
        return view
    }()
    
    
    private lazy var roomConfigView:UITableView = {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = UIColor.clear
        view.register(UINib(nibName: "GameRoomConfigTableCell", bundle: .main), forCellReuseIdentifier: "itemCell")
        view.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.3)
        view.layer.cornerRadius = 10
        view.separatorInset = UIEdgeInsets.zero
        return view
    }()
    
    private lazy var mapSelectView:GameRoomMapSelectView = {
        let mapView = GameRoomMapSelectView()
        return mapView
    }()
    
    private lazy var startGameButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setBackgroundImage(UIImage(named: "gui_button_start"), for: .normal)
        //button.setImage(UIImage(named: "gui_game_start"), for: .normal)
        //button.setTitleColor(.white, for: .normal)
        button.setTitle("", for: .normal)
        button.contentMode = .scaleAspectFill
        return button
    }()
    
    private lazy var settingButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "gui_button_setting"), for: .normal)
        button.setTitle("", for: .normal)
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(onPressSetting), for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "gui_back_button"), for: .normal)
        button.setTitle("", for: .normal)
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(onPressBack), for: .touchUpInside)
        return button
    }()
    
    private lazy var containerView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private lazy var roomStateTipsView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        return view
    }()
    
    
    private let containerRatio:CGFloat = 55/88
    
    private var room:GameRoom?
    
    private var gameProfile:GameProfile?
    
    private var inGamePlayers:[String:InGamePlayer] = [:]
    
    private var map:GameMap = .Forest
    
    private var isInit:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debugLog("[GameRoomController] init")
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        layoutGameUI()
        mapSelectView.setup(model: self.map)
        mapSelectView.delegate = self
        startGameButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        
        NotificationCenter.customAddObserver(self, selector: #selector(onPlayerEnter(_:)), name: .PlayerEnter, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onPlayerExit(_:)), name: .PlayerExit, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onPlayerReady(_:)), name: .PlayerReady, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onPlayerNotReady(_:)), name: .PlayerNotReady, object: nil)
        
    }
    
    private func layoutGameUI(){
        let containerHeight = SCREEN_HEIGHT * (58/80)
        let containerWidth = containerHeight / containerRatio
        self.contentView.addSubview(containerView)
        self.contentView.addSubview(roomStateTipsView)
        self.contentView.addSubview(backButton)
        containerView.addSubview(playerCollectionView)
        containerView.addSubview(mapSelectView)
        containerView.addSubview(startGameButton)
        containerView.addSubview(settingButton)
        containerView.addSubview(roomConfigView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(0.2*SCREEN_HEIGHT)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: containerWidth, height: containerHeight))
        }
        // 530/880
        playerCollectionView.snp.makeConstraints { make in
            //53/88
            make.width.equalToSuperview().multipliedBy(0.602)
            make.height.equalToSuperview()
            make.left.equalToSuperview()
        }
        mapSelectView.snp.makeConstraints { make in
            make.left.equalTo(playerCollectionView.snp.right).offset(20)
            make.right.top.equalToSuperview()
            //22/33
            make.height.equalTo(mapSelectView.snp.width).multipliedBy(0.667)
        }
        roomConfigView.snp.makeConstraints { make in
            make.left.equalTo(mapSelectView)
            make.right.equalToSuperview()
            make.top.equalTo(mapSelectView.snp.bottom).offset(20)
            make.bottom.equalTo(startGameButton.snp.top).offset(-20)
        }
        startGameButton.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
            make.right.equalTo(mapSelectView)
            //13/27
            make.width.equalTo(mapSelectView).multipliedBy(0.65)
            make.height.equalTo(startGameButton.snp.width).multipliedBy(0.5)
        }
        settingButton.snp.makeConstraints { make in
            make.left.equalTo(mapSelectView)
            make.height.equalTo(startGameButton)
            make.bottom.equalTo(startGameButton)
            make.right.equalTo(startGameButton.snp.left).offset(-10)
        }
        roomStateTipsView.snp.makeConstraints { make in
            make.bottom.equalTo(containerView.snp.top).offset(-35)
            make.right.equalTo(containerView)
            make.size.equalTo(CGSize(width: 192, height: 50))
        }
        backButton.snp.makeConstraints { make in
            make.left.equalTo(containerView)
            make.bottom.equalTo(containerView.snp.top).offset(-30)
            make.size.equalTo(CGSize(width: 72, height: 68))
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        roomStateTipsView.alpha = 0
        if GlobalSoundsManager.shared.currentBgmKey != "bgm_game_room"{
            GlobalSoundsManager.shared.playBgm(name: "bgm_game_room")
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var serverStart = false
        
        //start server
        if !isInit{
            ZxHUD.shared.display(type: .Loading, title: "正在初始化服务..")
            
            Server.instance.connectMode(.Lan)
            Server.instance.initComponent()
            if let profile = gameConfig["profile"] as? GameProfile {
                self.gameProfile = profile
                if !(Server.instance.roomManager()?.startServer(gameProfile: profile) ?? false){
                    debugLog("[Menu] start server failed")
                    ZxHUD.shared.display(type: .Error, title: "服务开启失败", duration: 2)
                }
                else{
                    room = Server.instance.roomManager()?.room
                    if !(Server.instance.roomManager()?.announcer?.startServer() ?? false){
                        debugLog("[Menu] announcer start failed")
                        ZxHUD.shared.display(type: .Error, title: "广播服务开启失败", duration: 2)
                    }
                    else{
                        ZxHUD.shared.dismiss()
                        isInit = true
                        serverStart = true
                    }
                    
                }
            }
            else{
                debugLog("[Menu] start server failed , profile not found")
                ZxHUD.shared.display(type: .Error, title: "游戏配置丢失", duration: 2)
            }
        }
        else{
            if !(Server.instance.roomManager()?.announcer?.startServer() ?? false){
                debugLog("[Menu] announcer start failed")
                ZxHUD.shared.display(type: .Error, title: "广播服务开启失败", duration: 2)
            }
            else{
                //self.titleLabel.text = "正在广播(ip:\(wifiIP))..."
                isInit = true
                serverStart = true
            }
        }
        Server.instance.roomManager()?.allowNewPlayerJoin(true)
        
        if serverStart {
            self.roomStateTipsView.image = UIImage(named: "gui_tips_room_state_announcing")
        }
        else{
            self.roomStateTipsView.image = UIImage(named: "gui_tips_room_state_failed_to_announce")
        }
        self.roomConfigView.reloadData()
        UIView.animate(withDuration: 0.6, delay: 0, options: [.autoreverse,.repeat]) {
            [weak self] in
            self?.roomStateTipsView.alpha = 1;
        } completion: { _ in
            //
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Server.instance.roomManager()?.announcer?.terminateServer()
    }
    
    deinit{
        debugLog("[GameRoomController] deinit")
        NotificationCenter.default.removeObserver(self)
        Server.instance.shutdown()
        Server.instance.connectMode(.None)
    }
    
    @objc func startGame(){
        GlobalSoundsManager.shared.playEffect(name: "fx_gui_button", type: "wav")
        let resultCode = Server.instance.roomManager()?.checkConditionForLaunch() ?? -1
        switch resultCode{
        case 0:
            //team player check
            var teamCounter:[Int:Int] = [:]
            var inGameplayers:[InGamePlayer] = []
            for gp in self.inGamePlayers.values{
                inGameplayers.append(gp)
                if teamCounter.keys.contains(gp.team){
                    teamCounter[gp.team]! += 1
                }
                else{
                    teamCounter[gp.team] = 1
                }
            }
            /*guard teamCounter.keys.count > 1 else {
                ZxHUD.shared.display(type: .Error, title: "至少包含两支队伍", duration: 2)
                return
            }*/
            //start launch
            Server.instance.roomManager()?.launcher?.setSyncConfig(gameConfig)
            let loadController = GameLoadController()
            
            loadController.setLoadingConfig(GameLoadController.LoadingRoomConfig(inGamePlayers: inGameplayers, map: self.map))
            loadController.roomController = self
            self.navigationController?.pushViewController(loadController, animated: true)
            break
        case 1:
            ZxHUD.shared.display(type: .Error, title: "有玩家未准备", duration: 2)
        case 2:
            ZxHUD.shared.display(type: .Error, title: "游戏人数不足", duration: 2)
        case 3:
            ZxHUD.shared.display(type: .Error, title: "服务未开启", duration: 2)
        default:
            ZxHUD.shared.display(type: .Error, title: "启动游戏失败", duration: 2)
        }
    }
    
    @objc private func onPressSetting(){
        GlobalSoundsManager.shared.playEffect(name: "fx_gui_button", type: "wav")
        self.navigationController?.pushViewController(GameSettingController(), animated: true)
    }

    @objc private func onPressBack(){
        GlobalSoundsManager.shared.playEffect(name: "fx_gui_button", type: "wav")
        self.navigationController?.popViewController(animated: true)
    }

}


extension GameRoomController{
    
    @objc private func onPlayerEnter(_ notification:Notification){
        guard room != nil else { return }
        guard let player = notification.userInfo?[JtUserInfo.Key.Value] as? GameRoomPlayer else { return }
        room?.players.append(player)
        room?.playerCount += 1
        playerCollectionView.reloadData()
    }
    
    
    @objc private func onPlayerExit(_ notification:Notification){
        guard room != nil else { return }
        guard let player = notification.userInfo?[JtUserInfo.Key.Value] as? GameRoomPlayer else { return }
        for (idx,p) in room!.players.enumerated(){
            if p.playerId == player.playerId{
                room!.players.remove(at: idx)
                room!.playerCount -= 1
                let _ = self.inGamePlayers.removeValue(forKey: p.playerId)
                playerCollectionView.reloadData()
                break
            }
        }
    }
    
    @objc private func onPlayerReady(_ notification:Notification){
        guard room != nil else { return }
        guard let player = notification.userInfo?[JtUserInfo.Key.Value] as? GameRoomPlayer else { return }
        debugLog("[GameRoomController] player(\(player.user.nickName)) is ready")
        for (idx,p) in room!.players.enumerated(){
            if p.playerId == player.playerId{
                room!.players[idx].isReady = true
                playerCollectionView.reloadData()
                break
            }
        }
    }
    
    @objc private func onPlayerNotReady(_ notification:Notification){
        guard room != nil else { return }
        guard let player = notification.userInfo?[JtUserInfo.Key.Value] as? GameRoomPlayer else { return }
        debugLog("[GameRoomController] player(\(player.user.nickName)) is not ready")
        for (idx,p) in room!.players.enumerated(){
            if p.playerId == player.playerId{
                room!.players[idx].isReady = false
                playerCollectionView.reloadData()
                break
            }
        }
    }

}



extension GameRoomController:UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell!
        
        if indexPath.row < self.room?.players.count ?? 0{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playerCell", for: indexPath)
            let player = room!.players[indexPath.row]
            if self.inGamePlayers.keys.contains(player.playerId){
                self.inGamePlayers[player.playerId]?.lanPlayer = player
                (cell as? GameRoomPlayerCollectionCell)?.setup(model: self.inGamePlayers[player.playerId])
            }
            else{
                let inGamePlayer = InGamePlayer(index: self.inGamePlayers.count, hero: .WoftMan, team: self.inGamePlayers.count, lanPlayer: player)
                self.inGamePlayers[player.playerId] = inGamePlayer
                (cell as? GameRoomPlayerCollectionCell)?.setup(model: self.inGamePlayers[player.playerId])
            }
            (cell as? GameRoomPlayerCollectionCell)?.delegate = self
        }
        else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCell", for: indexPath)
        }
        return cell
    }
    
    
}


extension GameRoomController:UICollectionViewDelegate{
    
}

extension GameRoomController:GameRoomPlayerCollectionCellDelegate{
    
    func playerCellOnPressNextHero(_ collectionCell: GameRoomPlayerCollectionCell) {
        guard let indexPath = self.playerCollectionView.indexPath(for: collectionCell) else { return }
        let player = room!.players[indexPath.row]
        guard var inGamePlayer = self.inGamePlayers[player.playerId] else { return }
        switch inGamePlayer.hero.index{
        case 0:
            inGamePlayer.hero = Hero.valueWith(index: 1)
        case 1:
            inGamePlayer.hero = Hero.valueWith(index: 0)
        default:
            break
        }
        self.inGamePlayers[player.playerId] = inGamePlayer
        self.playerCollectionView.reloadData()
    }
    
    func playerCellOnPressPreviousHero(_ collectionCell: GameRoomPlayerCollectionCell) {
        guard let indexPath = self.playerCollectionView.indexPath(for: collectionCell) else { return }
        let player = room!.players[indexPath.row]
        guard var inGamePlayer = self.inGamePlayers[player.playerId] else { return }
        switch inGamePlayer.hero.index{
        case 0:
            inGamePlayer.hero = Hero.valueWith(index: 1)
        case 1:
            inGamePlayer.hero = Hero.valueWith(index: 0)
        default:
            break
        }
        self.inGamePlayers[player.playerId] = inGamePlayer
        self.playerCollectionView.reloadData()
    }
    
    func playerCellOnPressNextTeam(_ collectionCell: GameRoomPlayerCollectionCell) {
        guard let indexPath = self.playerCollectionView.indexPath(for: collectionCell) else { return }
        let player = room!.players[indexPath.row]
        guard var inGamePlayer = self.inGamePlayers[player.playerId] else { return }
        inGamePlayer.team += 1
        if inGamePlayer.team >= 4{
            inGamePlayer.team = 0
        }
        self.inGamePlayers[player.playerId] = inGamePlayer
        self.playerCollectionView.reloadData()
    }
    
    func playerCellOnPressPreviousTeam(_ collectionCell: GameRoomPlayerCollectionCell) {
        guard let indexPath = self.playerCollectionView.indexPath(for: collectionCell) else { return }
        let player = room!.players[indexPath.row]
        guard var inGamePlayer = self.inGamePlayers[player.playerId] else { return }
        inGamePlayer.team -= 1
        if inGamePlayer.team < 0{
            inGamePlayer.team = 3
        }
        self.inGamePlayers[player.playerId] = inGamePlayer
        self.playerCollectionView.reloadData()
    }
    
    
}


extension GameRoomController:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        if indexPath.row == 0{
            switch Server.instance.connectMode{
            case .Lan:
                cell.setup(model: ("连接模式","Wi-Fi"))
            case .Bluetooth:
                cell.setup(model: ("连接模式","BlueTooth"))
            default:
                cell.setup(model: ("连接模式","Unknown"))
            }
        }
        else if indexPath.row == 1{
            switch Server.instance.connectMode{
            case .Lan:
                if NetworkStateListener.default.connection != .wifi {
                    cell.setup(model: ("主机","Unknown"))
                }
                else{
                    cell.setup(model: ("主机",room?.hoster.ip_v4_address ?? "unknown"))
                }
            case .Bluetooth:
                cell.setup(model: ("主机","local"))
            default:
                cell.setup(model: ("主机","Unknown"))
            }
        }
        else if indexPath.row == 2{
            if self.gameProfile == nil{
                cell.setup(model: ("游戏人数","Unknown"))
            }
            else{
                cell.setup(model: ("游戏人数","\(self.gameProfile!.minPlayerCount)~\(self.gameProfile!.maxPlayerCount)"))
            }
            
        }
        cell.selectionStyle = .none
        return cell
    }
    
    
}



extension GameRoomController:GameRoomMapSelectViewDelegate{
    
    func mapSelectViewOnPressNext(_ selectView: GameRoomMapSelectView) {
        GlobalSoundsManager.shared.playEffect(name: "fx_gui_select", type: "wav")
        let newMap = GameMap.init(rawValue: self.map.rawValue+1)
        if newMap == nil {
            self.map = .Forest
        }
        else{
            self.map = newMap!
        }
        selectView.setup(model: self.map)
    }
    
    func mapSelectViewOnPressPrevious(_ selectView: GameRoomMapSelectView) {
        GlobalSoundsManager.shared.playEffect(name: "fx_gui_select", type: "wav")
        let newMap = GameMap.init(rawValue: self.map.rawValue-1)
        if newMap == nil {
            self.map = .Lab
        }
        else{
            self.map = newMap!
        }
        selectView.setup(model: self.map)
    }
    
    
}
