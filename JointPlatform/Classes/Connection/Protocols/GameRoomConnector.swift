//
//  LANRoomConnector.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/3.
//

import UIKit
import CocoaAsyncSocket

///同步标志位，用来判断同步的消息的类型
struct GameSync{
    enum Symbol:String{
        case gameStart = "gameStart"
        case gameTerminate = "gameTerminate"
        case gamePrepare = "gamePrepare"
        case gameAssets = "gameAssets"
        case gameAssetsSyncPrepare = "gameAssetsSyncPrepare"
        case gameAssetsRequest = "gameAssetsRequest"
        case assetsVersion = "assetsVersion"
        case initLayout = "initLayout"
        case gamePrepareDone = "gamePrepareDone"
        case gamePrepareFailed = "gamePrepareFailed"
        case roomDestroy = "roomDestroy"
        case userEnter = "userEnter"
        case userLeave = "userLeave"
        case userReady = "userReady"
        case userNotReady = "userNotReady"
        case normal = "normal"
        case playerStateUpdate = "playerStateUpdate"
        case joyStickUIUpdate = "joyStickUIUpdate"
        ///完成TCP连接后的身份信息交换
        case verify = "verify"
        case delayCheck = "delayCheck"
        case delayCheckEcho = "delayCheckEcho"
        ///身份信息交换完成
        case verifyProved = "verifyProved"
        case unknown = "unknown"
    }
}


protocol GameRoomConnectorDataSource:NSObjectProtocol{
    
    ///获取指定gamer的player模型
    func gameConnector(_ connector:GameRoomConnector,playerFor gamer:GameUser) -> GameRoomPlayer?
    
    ///获取当前connetor服务的Room的模型
    func gameConnectorTargetRoom() -> GameRoom
    
}




protocol GameRoomConnector:NSObjectProtocol{
    
    var isConnected:Bool { get }
    
    ///服务初始化
    func initialize()
    
    ///设置数据源
    func setDataSource(_ target:GameRoomConnectorDataSource)
    
    ///断开与指定成员的连接
    func disconnectTo(_ player:GameRoomPlayer) -> Bool
    
    ///向房间所有成员同步消息
    func syncAll(_ type:GameSync.Symbol,message:Any?) -> Bool
    
    ///向指定成员传送消息
    func syncTo(_ type:GameSync.Symbol,player:GameRoomPlayer,message:Any?) -> Bool
    
    ///除指定成员外都发送消息
    func syncExpect(_ type:GameSync.Symbol,player:GameRoomPlayer,message:Any?) -> Bool
    
    ///断开所有连接
    func disconnectAll()
    
    ///允许新连接
    func allowNewConnection(_ value:Bool)
    
    func startServer() -> Bool
    
    func terminalServer()
    
}


