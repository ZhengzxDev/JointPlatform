//
//  GlobalBgmManager.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/4/21.
//

import Foundation
import AVFoundation

class GlobalSoundsManager:NSObject{
    
    
    
    static let shared:GlobalSoundsManager = {
        let manager = GlobalSoundsManager()
        return manager
    }()
    
    public var currentBgmKey:String{
        get{
            return _currentBgmName
        }
    }
    
    private var bgmAudioPlayer:AVAudioPlayer?
    private var audioPlayers:[String:AVAudioPlayer] = [:]
    private var _currentBgmName:String = ""
    
    private override init(){
        super.init()
    }
    
    public func setBgmVolume(value:CGFloat){
        self.bgmAudioPlayer?.volume = Float(value)
    }
    
    public func playBgm(name:String,vol:CGFloat = GameUserConfig.global.lobbyBgmVolume,type:String = "mp3"){
        bgmAudioPlayer?.stop()
        guard let path =  Bundle.main.path(forResource: name, ofType: type) else { return }
        
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setActive(true, options: .init())
            
            try session.setCategory(AVAudioSession.Category.playback)

            let url = URL(fileURLWithPath: path)
            
            try bgmAudioPlayer = AVAudioPlayer(contentsOf: url)
            bgmAudioPlayer!.prepareToPlay()
            bgmAudioPlayer!.volume = Float(vol)
            bgmAudioPlayer!.numberOfLoops = -1
            bgmAudioPlayer!.play()
            bgmAudioPlayer!.delegate = self
            
            _currentBgmName = name
            
        }
        catch let error{
            debugLog("[GlobalSoundsManager] player bgm failed :\(error.localizedDescription)")
        }
    
    }
    
    
    public func playEffect(name:String,vol:CGFloat = GameUserConfig.global.effectVolume,type:String = "mp3"){
        var player:AVAudioPlayer?
        if self.audioPlayers.keys.contains(name){
            player = self.audioPlayers[name]
        }
        do{
            let session = AVAudioSession.sharedInstance()
            try session.setActive(true, options: .init())
            try session.setCategory(AVAudioSession.Category.playback)
            guard let path =  Bundle.main.path(forResource: name, ofType: type) else { return }
            let url = URL(fileURLWithPath: path)
            if player == nil{
                try player = AVAudioPlayer(contentsOf: url)
            }
            player!.prepareToPlay()
            player!.volume = Float(vol)
            player!.numberOfLoops = 0
            player!.delegate = self
            self.audioPlayers[name] = player
            player!.play()
            
        }
        catch let error{
            debugLog("[GlobalSoundsManager] player effect failed :\(error.localizedDescription)")
        }
    }
    
    
}


extension GlobalSoundsManager:AVAudioPlayerDelegate{
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard player != self.bgmAudioPlayer else { return }
        for fileName in self.audioPlayers.keys{
            if audioPlayers[fileName] == player{
                self.audioPlayers.removeValue(forKey: fileName)
                break
            }
        }
    }
    
}
