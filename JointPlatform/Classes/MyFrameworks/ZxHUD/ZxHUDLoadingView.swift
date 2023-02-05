//
//  ZxHUDLoadingView.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/3/14.
//

import UIKit

class ZxHUDLoadingView:ZxPopContentView{
    
    private let maxWidth:CGFloat = 200
    
    private var title:String = ""
    
    private var mySize:CGSize = .zero
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(r: 30, g: 30, b: 30, a: 1)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    
    private lazy var loadIndicator:CULoadingIndicator = {
        let view = CULoadingIndicator()
        view.setStroke(width: 5)
        view.setStroke(color: UIColor.orange)
        return view
    }()
    
    convenience init(title:String){
        self.init(frame: .zero)
        self.title = title
        self.titleLabel.text = title
        self.addSubview(titleLabel)
        self.addSubview(loadIndicator)
        loadIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.top.equalTo(10)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(loadIndicator.snp.bottom).offset(15)
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
    
    override func willDisplay() {
        loadIndicator.play()
    }
    
    override func didHide(){
        loadIndicator.pause()
    }
    
    override func didDisplay() {
        //print("did display")
    }
    
    override func getSize() -> CGSize {
        return mySize
    }
    
    override func allocFrameView() -> ZxPopWindowFrameView {
        return ZxHUDFrameView(contentView: self)
    }
    
    
}
