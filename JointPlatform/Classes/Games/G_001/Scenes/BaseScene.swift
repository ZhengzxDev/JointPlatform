//
//  BaseScene.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/14.
//

import SpriteKit
import GameplayKit

class BaseScene:SKScene{
    
    private var entities:[GKEntity] = []
    var graphs:[String:GKGraph] = [:]
    weak var gameController:GameViewController?
    
    var players:[InGamePlayer] = []
    
    var playersInTeam:[Int:[InGamePlayer]] = [:]
    
    var heroNodeForIndex:[Int:SKSpriteNode] = [:]
    
    private var tempNodes:[SKNode] = []
    
    private var lastUpdateTime:TimeInterval = 0
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        //动态添加角色
    }
    
    override func didMove(to view: SKView) {
        spawnHeros()
        for subNode in self.children{
            if let heroNode = subNode as? HeroCharacterNode{
                heroNode.setupStateMechine()
                if let controlComponent = heroNode.entity?.component(ofType: HeroControlComponent.self){
                    controlComponent.initComponent(self)
                }
            }
        }
    }
    
    
    func spawnHeros(){
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if self.lastUpdateTime == 0{
            self.lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - self.lastUpdateTime
        
        for entity in self.entities{
            entity.update(deltaTime: deltaTime)
            for component in entity.components{
                component.update(deltaTime: deltaTime)
            }
        }
        
        self.lastUpdateTime = currentTime
    }
    
    
    func positionInCamera(_ node:SKNode) -> CGPoint{
        guard self.view != nil else { return .zero }
        return self.view!.convert(node.position, from: self)
    }
    
    func addPlayers(_ playersInTeam:[Int:[InGamePlayer]],players:[InGamePlayer]){
        self.playersInTeam = playersInTeam
        self.players = players
    }
    
    func onPlayerDie(_ player:InGamePlayer,heroNode:HeroCharacterNode){
        
    }
    
    func onPlayerOffline(_ player:InGamePlayer){
        guard self.heroNodeForIndex.keys.contains(player.index) else { return }
        guard let heroNode = self.heroNodeForIndex[player.index] as? HeroCharacterNode else { return }
        heroNode.setOffline(true)
    }
    
    func removeEntity(for node:SKNode){
        if let nodeEntity = node.entity {
            for (idx,e) in self.entities.enumerated(){
                if e == nodeEntity{
                    self.entities.remove(at: idx)
                    break
                }
            }
        }
    }
    
    func registerEntity(for node:SKNode) -> GKEntity{
        if node.entity != nil{
            self.entities.append(node.entity!)
            return node.entity!
        }
        else{
            let entity = GKEntity()
            node.entity = entity
            self.entities.append(entity)
            return entity
        }
    }
    
    func initEntities(_ entities:[GKEntity]){
        self.entities = entities
    }
    
    func removeTempNode(_ node:SKNode?){
        for (idx,tnode) in tempNodes.enumerated() {
            if node == tnode{
                tempNodes.remove(at: idx)
                break
            }
        }
    }
    
    func addTempNode(_ node:SKNode?){
        guard node != nil else { return }
        tempNodes.append(node!)
    }
    
    func clearAllTempNode(){
        let _ = self.tempNodes.map{
            $0.removeFromParent()
        }
        self.tempNodes = []
    }
    
}

