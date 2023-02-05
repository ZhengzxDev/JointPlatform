//
//  ConstValue.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/3.
//

import UIKit


let DEBUG_MODE:Bool = true


var SCREEN_HEIGHT:CGFloat{
    get{
        return UIScreen.main.bounds.height
    }
}

var SCREEN_WIDTH:CGFloat{
    get{
        return UIScreen.main.bounds.width
    }
}

var statusBarHeight:CGFloat{
    get{
        if #available(iOS 13, *){
            let manager = UIApplication.shared.windows.first?.windowScene?.statusBarManager
            return manager?.statusBarFrame.height ?? 0
        }
        else{
            return UIApplication.shared.statusBarFrame.height
        }
    }
}


///局域网UDP端口
let LANGamePort:UInt16 = 11571

///局域网TCP端口
let LANGammTcpPort:[UInt16] = [13210,13221,13222,13223]

///局域网游戏最大连接数
let LANGameMaxConnection:Int = 4

let LANRoomIDLength:Int = 16


/// WiFi获得的IP
var wifiIP:String?{
    var address: String?
    var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
    guard getifaddrs(&ifaddr) == 0 else {
        return nil
    }
    guard let firstAddr = ifaddr else {
        return nil
    }
    
    for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ifptr.pointee
        // Check for IPV4 or IPV6 interface
        let addrFamily = interface.ifa_addr.pointee.sa_family
        if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
            // Check interface name
            let name = String(cString: interface.ifa_name)
            if name == "en0" {
                // Convert interface address to a human readable string
                var addr = interface.ifa_addr.pointee
                var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(&addr,socklen_t(interface.ifa_addr.pointee.sa_len), &hostName, socklen_t(hostName.count), nil, socklen_t(0), NI_NUMERICHOST)
                address = String(cString: hostName)
            }
        }
    }
    
    freeifaddrs(ifaddr)
    return address
}


