//
//  PlayerStateView.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/25.
//

import UIKit

class PlayerStateView:UIView,NibLoadable{
    
    private var contentView:UIView?
    @IBOutlet weak var healthIndicateView: UIView!
    @IBOutlet weak var bulletIndicateLabel: PixelTextLabel!
    @IBOutlet weak var playerIndicateLabel: PixelTextLabel!
    
    @IBOutlet weak var healthIndicateLabel: PixelTextLabel!
    @IBOutlet weak var heroIndicateImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = loadFromNib()
        self.addSubview(contentView!)
        contentView!.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        playerIndicateLabel.drawText()
        bulletIndicateLabel.setAlphabetSize(CGSize(width: 10, height: 20))
        healthIndicateLabel.setAlphabetSize(CGSize(width: 10, height: 20))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateWeaponInfo(_ info:WeaponInfo){
        
        var indicateText = ""
        if info.clipRemain == -1{
            indicateText = "∞"
        }
        else if info.spareClipRemian == -1{
            indicateText = "\(info.clipRemain)/∞"
        }
        else{
            indicateText = "\(info.clipRemain)/\(info.spareClipRemian)"
        }
        self.bulletIndicateLabel.setText(indicateText)
        self.bulletIndicateLabel.drawText()
    }
    
    func updateHealth(_ value:Double){
        var barWidth:CGFloat = min(140,140 * value/100)
        barWidth = max(0 ,barWidth)
        self.healthIndicateView.frame = CGRect(origin: .init(x: 5, y: 47), size: .init(width: barWidth, height: 19))
        self.healthIndicateLabel.setText("\(Int(value))%")
        self.healthIndicateLabel.drawText()
    }
    
    func updatePlayerInfo(_ player:InGamePlayer){
        
        self.playerIndicateLabel.setText("P\(player.index)")
        self.playerIndicateLabel.drawText()
        self.heroIndicateImage.image = UIImage(named: player.hero.rawValue+"_head")
    }
    
    
}
