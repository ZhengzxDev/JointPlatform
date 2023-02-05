//
//  GameUserConfig.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/4/24.
//

import UIKit


class GameUserConfig:NSObject,NSCoding{
    
    public static let global:GameUserConfig = {
        let config = GameUserConfig()
        let def = UserDefaults.standard
        if let data = def.object(forKey: "GameUserConfigData") {
            if let localConfigData = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? GameUserConfig{
                config.lobbyBgmVolume = localConfigData.lobbyBgmVolume
                config.effectVolume = localConfigData.effectVolume
                config.gameBgmVolume = localConfigData.gameBgmVolume
                debugLog("[GameUserConfig] get user game config by local")
            }

        }
        return config
    }()
    
    var lobbyBgmVolume:CGFloat = 0.4
    
    var effectVolume:CGFloat = 0.4
    
    var gameBgmVolume:CGFloat = 0.25
    
    private override init(){
        
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(lobbyBgmVolume,forKey: "lobbyBgmVolume")
        coder.encode(effectVolume,forKey: "effectVolume")
        coder.encode(gameBgmVolume,forKey: "gameBgmVolume")
    }
    
    
    required init?(coder: NSCoder) {
        lobbyBgmVolume = coder.decodeObject(forKey: "lobbyBgmVolume") as? CGFloat ?? 0.4
        effectVolume = coder.decodeObject(forKey: "effectVolume") as? CGFloat ?? 0.4
        gameBgmVolume = coder.decodeObject(forKey: "gameBgmVolume") as? CGFloat ?? 0.25
    }
    
    public func save(){
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        // 存储到本地文件
        let def = UserDefaults.standard
        def.set(data, forKey: "GameUserConfigData")
        def.synchronize()
        debugLog("[GameUserConfig] data saved")
    }
    
}
