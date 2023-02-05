//
//  PlayerControlComponent.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/14.
//

import SpriteKit

///用于处理所有玩家操作
///对所有的HeroComponent进行管理和单一控制
class PlayerControlCenter:NSObject{
    
    public static let shared:PlayerControlCenter = {
        let center = PlayerControlCenter()
        return center
    }()
    
    private var components:[String:HeroControlComponent] = [:]
    
    func initialize(){
        
        Server.instance.roomManager()?.stickCommander?.delegate = self
        
    }
    
    
    func allocComponent(for lanPlayer:GameRoomPlayer) -> HeroControlComponent?{
        let component = HeroControlComponent()
        self.components[lanPlayer.playerId] = component
        print("alloc component")
        return component
    }
}

extension PlayerControlCenter:GameStickCommanderDelegate{
    
    func stickCommander(_ commander: GameStickCommander, MovedWith vector: CGVector, degree: CGFloat, comTag: Int, player: GameRoomPlayer) {
        guard let component = components[player.playerId] else { return }
        component.follow([
            "type":"knob",
            "comTag":comTag,
            "vector":vector,
            "degree":degree,
        ])
    }
    
    func stickCommander(_ commander: GameStickCommander, PressdWith comTag: Int, player: GameRoomPlayer) {
        guard let component = components[player.playerId] else { return }
        component.follow([
            "type":"button",
            "comTag":comTag,
        ])
    }
    
    
    
    
}


