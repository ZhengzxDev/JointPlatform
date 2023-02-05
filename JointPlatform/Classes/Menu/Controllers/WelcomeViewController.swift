//
//  WelcomeViewController.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/4/19.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    private lazy var logoImageView:UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "game_logo")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var indicateLabel:UILabel = {
        let view = UILabel()
        view.text = "点击屏幕继续"
        view.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        view.textColor = UIColor.white
        return view
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.indicateLabel.alpha = 0
        GlobalSoundsManager.shared.playBgm(name: "bgm_welcome_view")
        UIView.animate(withDuration: 0.6, delay: 0, options: [.autoreverse,.repeat]) {
            [weak self] in
            self?.indicateLabel.alpha = 1
        } completion: { _ in
            //
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hex: "#e99900")!
        self.view.addSubview(logoImageView)
        self.view.addSubview(indicateLabel)
        logoImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 457, height: 100))
            make.centerX.equalToSuperview()
            make.top.equalTo(SCREEN_HEIGHT*0.3)
        }
        indicateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-SCREEN_HEIGHT*0.2)//.multipliedBy(0.2)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.navigationController?.pushViewController(GameRoomController(), animated: true)
    }
    

}
