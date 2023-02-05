//
//  GameBaseController.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/8.
//

import UIKit
import SpriteKit
import GameplayKit

class GameBaseController: UIViewController {
    
    public weak var roomController:GameRoomController?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    required init?(nibWithName: String?, bundle: Bundle?) {
        super.init(nibName: nibWithName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view = SKView(frame: UIScreen.main.bounds)
    }
    
    func initializePlayer(_ inGamePlayers:[InGamePlayer]){
        
    }
    
    func initializeScene(_ map:GameMap){
        
    }
    
    func terminateGame(){
        
    }

}
