//
//  GameConfig.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/8.
//

import UIKit


enum zPositionConfig:CGFloat{
    case GUI = 500
    case Effect = 120
    case Bullet = 115
    case PickableWeapon = 112
    case Weapon = 110
    case Hero = 100
    case Enemy = 80
    case Ground = -10
}


let gameConfig:[String:Any] = [
    "profile":GameProfile(id: "001", name: "元气小骑士", maxPlayerCount: 4, minPlayerCount: 1),
    "gameIcon":"project_game_icon",
    "assets":[
        "version":"1.0.0",
        "forceRefresh":false
    ],
    "joyStick":[
        "components":[
            [
                "description":"移动",
                "type":"knob",
                "tag":0,
            ],
            [
                "description":"射击",
                "type":"knob",
                "mode":"optimized",
                "tag":1,
            ],
            [
                "description":"切换武器",
                "type":"button",
                "tag":2,
                "imageName":"joy_stick_change",
            ],
            [
                "description":"拾取",
                "type":"button",
                "tag":3,
                "imageName":"joy_stick_grab",
            ],
            [
                "description":"跳跃",
                "type":"button",
                "tag":4,
                "imageName":"joy_stick_jump",
            ],
//            [
//                "description":"测试按钮",
//                "type":"button",
//                "tag":5,
//                "imageName":"joy_stick_test",
//            ]
        ],
        "layoutVersion":"test.1.1.0", // 1.0.3
        "orient":"landScape",
        "version":[
            "min":1.0,
            "max":1.0
        ]
    ]
]
