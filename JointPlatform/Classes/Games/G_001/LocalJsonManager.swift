//
//  LocalJsonManager.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/22.
//

import Foundation
import SwiftyJSON

class LocalJsonManager:NSObject{
    
    enum JsonFileKey:String{
        case Weapon = "WeaponConfig"
        case Bullet = "BulletConfig"
    }
    
    static let shared:LocalJsonManager = {
        let manager = LocalJsonManager()
        return manager
    }()
    
    private var JsonCache:[String:JSON] = [:]
    
    private override init(){
        
    }
    
    func getJson(with key:JsonFileKey) -> JSON?{
        if JsonCache.keys.contains(key.rawValue){
            return JsonCache[key.rawValue]
        }
        let path = Bundle.main.path(forResource: key.rawValue, ofType: "json")
        let url = URL(fileURLWithPath: path!)
        do{
            let data = try Data(contentsOf: url)
            let Json = JSON(data)
            self.JsonCache[key.rawValue] = Json
            return Json
        }catch let error{
            debugLog("LocalJsonManager load Json failed : \(error.localizedDescription)")
            return nil
        }
    }
    
}
