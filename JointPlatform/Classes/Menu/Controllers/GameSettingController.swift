//
//  GameSettingController.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/4/23.
//

import UIKit


class GameSettingController: WordsTransController {
    
    private let settingList:[[String:Any]] = [
        [
            "key":"bgmVolume",
            "id":"sliderCell",
            "title":"大厅背景音乐音量",
            "value":GameUserConfig.global.lobbyBgmVolume
        ],
        [
            "key":"effectVolume",
            "id":"sliderCell",
            "title":"效果音乐音量",
            "value":GameUserConfig.global.effectVolume
        ],
        [
            "key":"gameBgmVolume",
            "id":"sliderCell",
            "title":"游戏音乐音量",
            "value":GameUserConfig.global.gameBgmVolume
        ],
    ]

    
    
    
    override var backgroundFadeColor: UIColor{
        get{
            return UIColor(hex: "#dadada")!
        }
        set{ }
    }
    
    
    override var backgroundWordsImageName: String{
        get{
            return "back_words_game_setting"
        }
        set{ }
    }
    
    
    override var resetXOffset: CGFloat{
        get{
            return 910
        }
        set{ }
    }
    
    override var foregroundColor: UIColor{
        get{
            return UIColor(hex: "#9a9a9a")!
        }
        set{ }
    }
    
    private lazy var backButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "gui_back_button"), for: .normal)
        button.setTitle("", for: .normal)
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(onPressBack), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var settingTableView:UITableView = {
        let view = UITableView()
        view.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.3)
        view.layer.cornerRadius = 10
        view.delegate = self
        view.dataSource = self
        view.register(UINib(nibName: "GameSettingSlideTableCell", bundle: .main), forCellReuseIdentifier: "sliderCell")
        view.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 15, right: 0)
        view.separatorStyle = .none
        return view
    }()
    
    private let containerRatio:CGFloat = 55/88
    
    private var isModified:Bool = false
    
    deinit{
        debugLog("[GameSettingController] deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("[GameSettingController] init")
        let containerHeight = SCREEN_HEIGHT * (58/80)
        let containerWidth = containerHeight / containerRatio
        self.contentView.addSubview(backButton)
        self.contentView.addSubview(settingTableView)
        settingTableView.snp.makeConstraints { make in
            make.top.equalTo(0.2*SCREEN_HEIGHT)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: containerWidth, height: containerHeight))
        }
        backButton.snp.makeConstraints { make in
            make.left.equalTo(settingTableView)
            make.bottom.equalTo(settingTableView.snp.top).offset(-30)
            make.size.equalTo(CGSize(width: 72, height: 68))
        }
    }
    

    @objc private func onPressBack(){
        GlobalSoundsManager.shared.playEffect(name: "fx_gui_button",type: "wav")
        
        if isModified{
            ZxHUD.shared.display(type: .Loading, title: "正在保存..")
            //modify config
            GameUserConfig.global.save()
            GlobalSoundsManager.shared.setBgmVolume(value: GameUserConfig.global.lobbyBgmVolume)
            ZxHUD.shared.display(type: .Complete, title: "保存成功",duration: 1.5)
        }
        
        self.navigationController?.popViewController(animated: true)
    }

}


extension GameSettingController:UITableViewDataSource,UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = settingList[indexPath.row]["id"] as! String
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        cell.setup(model: settingList[indexPath.row])
        cell.selectionStyle = .none
        (cell as? GameSettingSlideTableCell)?.delegate = self
        return cell
    }
    
    
}


extension GameSettingController:GameSettingSlideTableCellDelegate{
    
    func settingSliderTableCell(_ tableCell: GameSettingSlideTableCell, didChangeValueTo progress: CGFloat) {
        guard let indexPath = settingTableView.indexPath(for: tableCell) else { return }
        guard let key = settingList[indexPath.row]["key"] as? String else { return }
        isModified = true
        switch key{
        case "bgmVolume":
            GameUserConfig.global.lobbyBgmVolume = progress
        case "effectVolume":
            GameUserConfig.global.effectVolume = progress
        case "gameBgmVolume":
            GameUserConfig.global.gameBgmVolume = progress
        default:
            break
        }
    }
    
    
}
