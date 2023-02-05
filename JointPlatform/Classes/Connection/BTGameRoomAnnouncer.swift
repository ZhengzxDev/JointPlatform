//
//  BTGameRoomAnnouncer.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/21.
//

import Foundation


class BTGameRoomAnnouncer:NSObject,GameRoomAnnouncer{
    
    var announcing: Bool{
        get{
            return _announcing
        }
    }
    
    private var _announcing:Bool = false
    
    func setDataSource(_ dataSource: GameRoomAnnouncerDataSource) {
        //
    }
    
    func startServer() -> Bool {
        return false
    }
    
    func terminateServer() {
        //
    }
    
    
    
    
}
