//
//  JtSliderView.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/4/24.
//

import UIKit

protocol JtSliderViewDelegate:NSObjectProtocol{
    
    func jtSlider( _ sliderView:JtSliderView, didChangeValueTo progress:CGFloat)
    
}


class JtSliderView:UIView{
    
    private lazy var dragDot:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220, a: 1)
        view.layer.cornerRadius = dragDotSize.height/2
        return view
    }()
    
    private var dragBar:UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.backgroundColor = UIColor(r: 100, g: 100, b: 100, a: 1)
        return view
    }()
    
    private var panRec:UIPanGestureRecognizer?
    
    private var dragBarSize:CGSize = CGSize(width: 250, height: 10)
    
    private var dragDotSize:CGSize = CGSize(width: 30, height: 30)
    
    private var minX:CGFloat = 0
    
    private var maxX:CGFloat = 0
    
    private var xDistance:CGFloat = 0
    
    private var yValue:CGFloat = 0
    
    private var touchXOffset:CGFloat = 0
    
    private var defaultProgress:CGFloat = 0
    
    public weak var delegate:JtSliderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(dragBar)
        self.addSubview(dragDot)
        dragBar.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(dragBarSize)
        }
        if panRec != nil{
            panRec?.removeTarget(self, action: #selector(onPanDot(_:)))
            dragDot.removeGestureRecognizer(panRec!)
        }
        panRec = UIPanGestureRecognizer(target: self, action: #selector(onPanDot(_:)))
        dragDot.addGestureRecognizer(panRec!)
        dragDot.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addSubview(dragBar)
        self.addSubview(dragDot)
        dragBar.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(dragBarSize)
        }
        if panRec != nil{
            panRec?.removeTarget(self, action: #selector(onPanDot(_:)))
            dragDot.removeGestureRecognizer(panRec!)
        }
        panRec = UIPanGestureRecognizer(target: self, action: #selector(onPanDot(_:)))
        dragDot.addGestureRecognizer(panRec!)
        dragDot.isUserInteractionEnabled = true
    }
    
    func setBarSize(_ size:CGSize){
        self.dragBarSize = size
        dragBar.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(dragBarSize)
        }
        dragBar.layer.cornerRadius = size.height/2
        self.layoutSubviews()
    }
    
    func setBarColor(_ color:UIColor){
        self.dragBar.backgroundColor = color
    }
    
    func setDotColor(_ color:UIColor){
        self.dragDot.backgroundColor = color
    }
    
    func setDotSize(_ size:CGSize){
        self.dragDotSize = size
        self.dragDot.layer.cornerRadius = size.height/2
        self.layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        minX = ( self.frame.width - self.dragBarSize.width - dragDotSize.width)/2
        maxX = ( self.frame.width + self.dragBarSize.width - dragDotSize.width)/2
        xDistance = maxX - minX
        yValue = (self.frame.height - self.dragDotSize.height)/2
        dragDot.frame = CGRect(x: minX + defaultProgress * xDistance, y: yValue, width: dragDotSize.width, height: dragDotSize.height)
    }
    

    
    func setDefaultProgress(_ value:CGFloat){
        assert(value >= 0 && value <= 1)
        self.defaultProgress = value
    }
    
    
    @objc private func onPanDot(_ rec:UIPanGestureRecognizer){
        let location = rec.location(in: self)
        if rec.state == .began{
            touchXOffset = location.x - dragDot.frame.origin.x
        }
        else if rec.state == .changed{
            var fixedX = max(minX,location.x - touchXOffset)
            fixedX = min(maxX,fixedX)
            dragDot.frame = CGRect(x:fixedX, y: yValue, width: dragDotSize.width, height: dragDotSize.height)
            delegate?.jtSlider(self, didChangeValueTo: (fixedX - minX) / xDistance)
        }
    }
    
}
