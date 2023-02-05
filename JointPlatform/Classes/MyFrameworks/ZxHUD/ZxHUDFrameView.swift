//
//  ZxHUDFrameView.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/19.
//

import UIKit


class ZxHUDFrameView:ZxPopWindowFrameView{
    
    override func setupAppearance() {
        super.setupAppearance()
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 7)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.06
        //self.layer.borderWidth = 2
        //self.layer.borderColor = UIColor(r: 0, g: 0, b: 0, a: 0.2).cgColor
    }
    
    override func layoutContentView(_ contentView: ZxPopContentView) {
        super.layoutContentView(contentView)
        
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(contentView.getSize())
        }
    }
    
    override func baseSize() -> CGSize {
        return self.contentView!.getSize().modify(40, 20)
    }
    
    
}
