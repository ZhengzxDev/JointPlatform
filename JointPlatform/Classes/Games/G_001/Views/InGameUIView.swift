//
//  InGameUIView.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/25.
//

import UIKit

protocol InGameUIViewDelegate:NSObjectProtocol{
    
    func inGameUIViewDidPressRestart()
    
    func inGameUIViewDidPressExit()
    
}


class InGameUIView:UIView{
    
    weak var delegate:InGameUIViewDelegate?
    
    private var players:[InGamePlayer] = []
    
    private var stateViews:[Int:PlayerStateView] = [:]
    
    private var stateViewSize:CGSize = CGSize(width: 200, height: 100)
    
    private var exitButton:UIButton!
    
    private var restartButton:UIButton!
    
    convenience init(players:[InGamePlayer]){
        self.init(frame: CGRect.zero)
        self.players = players
        //for player in room.
        setupUI()
    }
    
    func setupUI(){
        
        var lastStateView:UIView?
        
        for player in self.players{
            let stateView = PlayerStateView()
            self.addSubview(stateView)
            stateView.snp.makeConstraints { make in
                if lastStateView == nil{
                    make.left.equalTo(15)
                }
                else{
                    make.left.equalTo(lastStateView!.snp.right).offset(10)
                }
                make.bottom.equalTo(-15)
                make.size.equalTo(stateViewSize)
            }
            lastStateView = stateView
            self.stateViews[player.index] = stateView
        }
        
        exitButton = UIButton()
        exitButton.setImage(UIImage(named: "gui_back_button"), for: .normal)
        self.addSubview(exitButton)
        exitButton.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.size.equalTo(CGSize(width: 72, height: 68))
        }
        exitButton.addTarget(self, action: #selector(onPressExit), for: .touchUpInside)
        
        restartButton = UIButton()
        restartButton.setImage(UIImage(named: "gui_button_restart"), for: .normal)
        self.addSubview(restartButton)
        restartButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-200)
            make.size.equalTo(CGSize(width: 108, height: 102))
        }
        restartButton.addTarget(self, action: #selector(onPressRestart), for: .touchUpInside)
        showRestartButtom(false)
    }
    
    func stateView(for player:InGamePlayer) -> PlayerStateView?{
        return stateViews[player.index]
    }
    
    func showRestartButtom(_ value:Bool){
        self.restartButton.isHidden = !value
    }
    
    @objc private func onPressRestart(){
        delegate?.inGameUIViewDidPressRestart()
    }
    
    @objc private func onPressExit(){
        delegate?.inGameUIViewDidPressExit()
    }
}
