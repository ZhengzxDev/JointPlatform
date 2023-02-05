//
//  NetworkStateListener.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/4/28.
//

import Foundation
import Reachability

class NetworkStateListener:NSObject{
    
    static let `default`:NetworkStateListener = {
        let listener  = NetworkStateListener()
        return listener
    }()
    
    public var connection:Reachability.Connection{
        get{
            guard _isListening else { return .unavailable }
            return reachability.connection
        }
    }
    
    public var isListening:Bool{
        get{
            return _isListening
        }
    }
    
    private let reachability:Reachability = try! Reachability()
    
    private var _isListening:Bool = false
    
    override private init(){
        super.init()
    }
    
    deinit{
        stopListening()
    }
    
    public func startListening(){
        NotificationCenter.default.addObserver(self, selector: #selector(onNetworkStateChanged(_:)), name: Notification.Name.reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
            _isListening = true
            debugLog("[NetworkStateListener] start listening")
        }
        catch let error{
            debugLog("[NetworkStateListener] start listening failed , due to : \(error.localizedDescription)")
        }
    }
    
    public func stopListening(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self)
        _isListening = false
        debugLog("[NetworkStateListener] stop listening")
    }
    
    @objc
    private func onNetworkStateChanged(_ notification:Notification){
        debugLog("[NetworkStateListener] state change to \(self.connection)")
        NotificationCenter.customPost(name: .NetworkStateChanged, object: nil, userInfo: nil)
    }
    
    
}
