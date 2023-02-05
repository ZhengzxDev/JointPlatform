//
//  ZxHUDStateView.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/19.
//

import UIKit

class ZxHUDStateView:ZxPopContentView{
    
    private let maxWidth:CGFloat = 200
    
    private var title:String = ""
    
    private var imageName:String = ""
    
    private var mySize:CGSize = .zero
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(r: 30, g: 30, b: 30, a: 1)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    
    private lazy var imageIndicator:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = UIColor.orange
        return view
    }()
    
    convenience init(title:String,imageName:String){
        self.init(frame: .zero)
        self.title = title
        self.imageName = imageName
        self.titleLabel.text = title
        self.addSubview(titleLabel)
        self.addSubview(imageIndicator)
        imageIndicator.image = UIImage(named: imageName)
        imageIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.top.equalTo(10)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageIndicator.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
        }
    }
    
    override func prepare() {
        super.prepare()
        
        let width = String.getWidth(title, height: 16, font: titleLabel.font)
        if width > maxWidth{
            let height = String.getHeight(title, width: maxWidth, font: titleLabel.font)
            mySize = CGSize(width: maxWidth, height: height + 40 + 35)
        }
        else{
            mySize = CGSize(width: max(width,90), height: 95)
        }
        
    }
    
    
    override func getSize() -> CGSize {
        return mySize
    }
    
    override func allocFrameView() -> ZxPopWindowFrameView {
        return ZxHUDFrameView(contentView: self)
    }
    
    
}

