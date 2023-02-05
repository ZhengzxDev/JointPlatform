//
//  BTGameRoomConnector.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/21.
//

import Foundation

class BTGameRoomConnector:NSObject,GameRoomConnector{
    
    
    var isConnected: Bool{
        get{
            return _isConnected
        }
    }
    
    private var _isConnected:Bool = false
    
    func initialize() {
        //
    }
    
    func setDataSource(_ target: GameRoomConnectorDataSource) {
        //
    }
    
    func disconnectTo(_ player: GameRoomPlayer) -> Bool {
        return false
    }
    
    func syncAll(_ type: GameSync.Symbol, message: Any?) -> Bool {
        return false
    }
    
    func syncTo(_ type: GameSync.Symbol, player: GameRoomPlayer, message: Any?)  -> Bool {
        return false
    }
    
    func syncExpect(_ type: GameSync.Symbol, player: GameRoomPlayer, message: Any?)  -> Bool {
        return false
    }
    
    func disconnectAll() {
        //
    }
    
    func allowNewConnection(_ value: Bool) {
        //
    }
    
    func startServer() -> Bool {
        return false
    }
    
    func terminalServer() {
        //
    }
    
    
}
