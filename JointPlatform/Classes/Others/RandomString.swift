//
//  RandomString.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/4.
//

import Foundation

class RandomString {
    let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    func get(length: Int) -> String {
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(characters.count)))
            let start = characters.index(characters.startIndex, offsetBy: index)
            let end = characters.index(characters.startIndex, offsetBy: index)
            ranStr.append(contentsOf: characters[start...end])
        }
        return ranStr
    }
    private init() {
        
    }
    static let sharedInstance = RandomString()
}
