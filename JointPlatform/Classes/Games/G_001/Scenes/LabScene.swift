//
//  LabScene.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/4/21.
//

import SpriteKit
import GameplayKit

class LabScene:BaseScene{
    
    
    private let spawnPosition:[CGPoint] = [
        CGPoint(x: -640, y: 170),
        CGPoint(x: -320, y: 170),
        CGPoint(x: 0, y: -160),
        CGPoint(x: 200, y: -160),
    ]
    
    var physicsDelegate = PhysicDetection()
    
    var cameraNode:SKCameraNode!
    
    var alivePlayers:[InGamePlayer] = []
    
    private var inGameUI:InGameUIView!
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        //self.size = CGSize(width: 400, height: 400)
        
        /*self.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: self.frame.origin, size: self.size))
        self.physicsBody?.categoryBitMask = ColliderType.MapBounds
        self.physicsBody?.contactTestBitMask = ColliderType.Bullet
        self.physicsBody?.collisionBitMask = ColliderType.Player | ColliderType.Enemy*/
        
        //add camera
        cameraNode = self.childNode(withName: "camera") as? SKCameraNode
        cameraNode.position = .zero
        cameraNode.setScale(1)
        
        self.camera = cameraNode
        
    }
    
    override func didMove(to view: SKView) {
        self.layoutGUI()
        super.didMove(to: view)
        self.physicsWorld.contactDelegate = physicsDelegate
        cameraNode.entity!.component(ofType: CameraControlComponent.self)!.setViewportSize(UIScreen.main.bounds.size)
        addTileMapPhysicsBody()
        //gameController?.playBgm(name: "bgm_fight_test_scene",vol: 0.25)
        GlobalSoundsManager.shared.playBgm(name: "bgm_fight_lab_scene", vol: GameUserConfig.global.gameBgmVolume)
        spawnRandomWeapons()
        
        
    }
    
    override func spawnHeros(){
        
        var posIndex:Int = players.count <= 2 ? 1 : 0
        
        for teamIndex in self.playersInTeam.keys{
            for teamPlayer in self.playersInTeam[teamIndex]!{
                guard let moveComponent = PlayerControlCenter.shared.allocComponent(for: teamPlayer.lanPlayer) else { return }
                let heroNode = HeroCharacterNode.init(gamePlayer: teamPlayer)
                self.addChild(heroNode)
                heroNode.addComponents(moveComponent: moveComponent)
                heroNode.setupWeapon(info:WeaponInfo.load(with: "0")!)
                heroNode.setupStateMechine()
                heroNode.setupPhysicsBody()
                heroNode.bind(to: inGameUI.stateView(for: teamPlayer))
                heroNode.updateStateView()
                if let cameraControl = cameraNode.entity?.component(ofType: CameraControlComponent.self){
                    cameraControl.addTarget(heroNode)
                }
                
                heroNode.position = spawnPosition[posIndex]
                self.heroNodeForIndex[teamPlayer.index] = heroNode
                posIndex += 1
            }
        }
    
        /*if let sandBag = self.childNode(withName: "sandBag_0") as? SandBagNode{
            
            sandBag.setupPhysicsBody()
            sandBag.setupAppearance()
        }
        
        if let sandBag = self.childNode(withName: "sandBag_1") as? SandBagNode{
            sandBag.setupPhysicsBody()
            sandBag.setupAppearance()
        }*/
    
        self.alivePlayers = self.players
    }

    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            for node in nodes(at: location){
                if let sprite = node as? MyGUINode{
                    sprite.touchesBegan(touches, with: event)
                }
            }
        }
    }
    
    
    func addTileMapPhysicsBody(){
        
        guard let tileMapNode = self.childNode(withName: "tileMap") as? SKTileMapNode else { return }
        tileMapNode.zPosition = zPositionConfig.Ground.rawValue
        var rects:[CGRect] = []
        let singleTileSize:CGSize = tileMapNode.tileSize
        var rowHorizontalNeighborRect:[Int:(Int,CGRect)] = [:]
        let tileMapNodeOrigin:CGPoint = CGPoint(x:  -tileMapNode.frame.width/2, y: -tileMapNode.frame.height/2)
        var rectCounter:Int = 0
        
        
        //^
        //|
        //|
        //------>
        for col in 0 ..< tileMapNode.numberOfColumns{
            
            var colRects:[CGRect] = []
            
            for row in 0 ..< tileMapNode.numberOfRows{
                guard let tileNodeDef =  tileMapNode.tileDefinition(atColumn: col, row: row) else { continue }
                if tileNodeDef.userData?["isEdge"] as? Bool == true{
                    
                    let tileNodeOrigin = tileMapNodeOrigin.offsetBy(dx: CGFloat(col)*singleTileSize.width, dy: CGFloat(row)*singleTileSize.height)
                    if colRects.isEmpty{
                        
                        
                        
                        // merge horizontal?
                        var included = false
                        if let horiNeighbor = rowHorizontalNeighborRect[row]{
                            if horiNeighbor.1.maxX == tileNodeOrigin.x{
                                rects[horiNeighbor.0].size.width += singleTileSize.width
                                rowHorizontalNeighborRect[row]?.1 = rects[horiNeighbor.0]
                                //print("enlarge horizontal vertical:\(rects[horiNeighbor.0])")
                                included = true
                                /*if tileMapNode.tileDefinition(atColumn: col+1, row: row)?.userData?["isEdge"] as? Bool == true {
                                    
                                }*/
                                
                                
                            }
                        }
                        if !included{
                            rowHorizontalNeighborRect[row] = (rectCounter,CGRect(origin: tileNodeOrigin, size: singleTileSize))
                            colRects.append(CGRect(origin: tileNodeOrigin, size: singleTileSize))
                            rectCounter += 1
                            //print("add col's first rect:\(CGRect(origin: tileNodeOrigin, size: singleTileSize))")
                        }
                    }
                    else{
                        //enlarge vertical first
                        if colRects.last!.maxY == tileNodeOrigin.y{
                            colRects[colRects.count-1].size.height += singleTileSize.height
                            //print("enlarge rect vertical:\(colRects[colRects.count-1])")
                            let lastNodeOrigin = tileMapNodeOrigin.offsetBy(dx: CGFloat(col)*singleTileSize.width, dy: CGFloat(row-1)*singleTileSize.height)
                            if rowHorizontalNeighborRect[row-1]?.1.origin == lastNodeOrigin{
                                //reset last row's horizontal adjacent if last node is recorded as last col's horizontal adjacent.
                                //print("remove hori neighbor \(rowHorizontalNeighborRect[row-1]!.1)")
                                rowHorizontalNeighborRect.removeValue(forKey: row-1)
                                
                            }
                        }
                        else{
                            //not vertical adjacent
                            //horizontal merge has higher priority.
                            var isIncluded:Bool = false
                            //merge vertical rects if needed
                            if let horiNeighbor = rowHorizontalNeighborRect[row]{
                                if horiNeighbor.1.maxX == tileNodeOrigin.x{
                                    //horizontal adjacent , then enlarge previous rect
                                    rects[horiNeighbor.0].size.width += singleTileSize.width
                                    //print("enlarge horizontal vertical:\(rects[horiNeighbor.0])")
                                    rowHorizontalNeighborRect[row]!.1 = rects[horiNeighbor.0]
                                    isIncluded = true
                                }
                            }
                            
                            if !isIncluded{
                                //is not be inclued by previous rect
                                //update this rect as this row's new horizontal adjacent.
                                rowHorizontalNeighborRect[row] = (rectCounter,CGRect(origin: tileNodeOrigin, size: singleTileSize))
                                colRects.append(CGRect(origin: tileNodeOrigin, size: singleTileSize))
                                rectCounter += 1
                                //print("add col rect:\(CGRect(origin: tileNodeOrigin, size: singleTileSize))")
                            }
                            
                            
                        }
                    }
                }
            }
            
            
            rects.append(contentsOf: colRects)
            
        }
        
        
        //add physicsBody
        for bodyBounds in rects{
            
            let node = SKSpriteNode(color: .clear, size: singleTileSize)
            node.anchorPoint = CGPoint(x: 0, y: 0)
            node.position = bodyBounds.origin
            //node.color = UIColor.red
            node.size = bodyBounds.size
            //node.setScale(0.9)
            node.physicsBody = SKPhysicsBody(rectangleOf: bodyBounds.size,center: CGPoint(x: bodyBounds.width/2, y: bodyBounds.height/2))
            
            node.physicsBody?.categoryBitMask = ColliderType.Ground
            node.physicsBody?.fieldBitMask = 0
            node.physicsBody?.allowsRotation = false
            node.physicsBody?.contactTestBitMask = ColliderType.GroundDetector
            node.physicsBody?.collisionBitMask = 0
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.restitution = 0

            tileMapNode.addChild(node)
            
        }
    }
    
    
    override func onPlayerDie(_ player: InGamePlayer,heroNode:HeroCharacterNode) {
        
        self.cameraNode.entity?.component(ofType: CameraControlComponent.self)!.removeTarget(heroNode)
        
        var isDifferentTeamAlive:Bool = false
        var team:Int?
        for (idx,ap) in self.alivePlayers.enumerated(){
            if ap.index == player.index{
                self.alivePlayers.remove(at: idx)
            }
            else{
                if team == nil{
                    team = ap.team
                }
                else{
                    if ap.team != team{
                        isDifferentTeamAlive = true
                    }
                }
            }
        }
        if !isDifferentTeamAlive{
            self.inGameUI.showRestartButtom(true)
        }
    }
    
    
   func layoutGUI(){
        
        inGameUI = InGameUIView(players: self.players)
        inGameUI.delegate = self
        self.view?.addSubview(inGameUI)
        inGameUI.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    func spawnRandomWeapons(){
        let positions:[CGPoint] = [
            CGPoint(x: -500, y:  250),
            CGPoint(x: -250, y:  250),
            CGPoint(x: -0, y:  250),
            CGPoint(x: 250, y:  250),
            CGPoint(x: 500, y:  250),
        ]
        for i in 0 ..< 5{
            let randIndex = Int.random(from: 1, to: 12)
            let weapon = WeaponInfo.load(with: "\(randIndex)")!
            let weaponNode = PickableWeaponNode(info: weapon)
            weaponNode.position = positions[i]
            self.addChild(weaponNode)
            self.addTempNode(weaponNode)
        }
    }
    
}


extension LabScene:InGameUIViewDelegate{
    
    
    func inGameUIViewDidPressExit() {
        GlobalSoundsManager.shared.playEffect(name: "fx_gui_button", type: "wav")
        let alert = UIAlertController(title: "提示", message: "确定退出当前游戏吗?", preferredStyle: .alert)
        
        alert.addAction(.init(title: "确定", style: .default, handler: { [weak self] action in
            self?.gameController?.terminateGame()
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(.init(title: "取消", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.gameController?.present(alert, animated: true, completion: nil)
    }
    
    
    func inGameUIViewDidPressRestart() {
        clearAllTempNode()
        self.alivePlayers = self.players
        self.inGameUI.showRestartButtom(false)
        var posIndex:Int = players.count <= 2 ? 1 : 0
        
        self.cameraNode.entity?.component(ofType: CameraControlComponent.self)!.removeAllTargets()
        
        for node in self.children{
            if let heroNode = node as? HeroCharacterNode{
                heroNode.health = 100
                heroNode.dead = false
                heroNode.size = CGSize(width: 28, height: 31)
                heroNode.setupWeapon(info: WeaponInfo.load(with: "0")!)
                heroNode.stateMachine?.enter(HeroNormalState.self)
                heroNode.setupPhysicsBody()
                heroNode.updateStateView()
                heroNode.position = spawnPosition[posIndex]
                posIndex += 1
                
                self.cameraNode.entity?.component(ofType: CameraControlComponent.self)!.addTarget(heroNode)
            }
        }
        
    }
    
    
    
    
}


