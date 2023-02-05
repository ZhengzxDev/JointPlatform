//
//  WordsTransController.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/4/19.
//

import UIKit

class WordsTransController: UIViewController {
    
    public var backgroundWordsImageName:String = "back_words_game_room"
    
    public var backgroundFadeColor:UIColor = UIColor(hex: "#e99900")!
    
    public var resetXOffset:CGFloat = 640
    
    public var foregroundColor:UIColor = UIColor.white
    
    public lazy var backgroundImageView:UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: backgroundWordsImageName)
        view.tintColor = foregroundColor
        view.contentMode = .scaleAspectFit
        view.layer.anchorPoint = .zero
        return view
    }()
    
    public let imageAlpha:CGFloat = 0.2
    
    public var contentView:UIView = UIView()
    
    private var moveAnimation:CABasicAnimation?
    
    private let moveSpeed:CGFloat = 50
    
    private var imageRatio:CGFloat = 1/2.1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1000 为 image 原图的高度
        let fixdOffset = (SCREEN_HEIGHT/1000)*resetXOffset
        
        moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation!.duration = fixdOffset/moveSpeed
        moveAnimation!.fromValue = CGPoint(x: -fixdOffset, y: 0)
        moveAnimation!.toValue = CGPoint(x: 0, y: 0)
        moveAnimation!.repeatCount = Float.infinity
        
        self.backgroundImageView.layer.add(moveAnimation!, forKey: "move")
        
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1) {
            [weak self] in
            guard let strongSelf = self else { return }
            self?.backgroundImageView.alpha = strongSelf.imageAlpha
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.backgroundImageView.layer.removeAllAnimations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = self.backgroundFadeColor
        self.view.addSubview(backgroundImageView)
        self.view.addSubview(contentView)
        let image = UIImage(named: backgroundWordsImageName)!
        backgroundImageView.image = image
        self.imageRatio = image.size.height/image.size.width
        backgroundImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.equalTo(SCREEN_HEIGHT/imageRatio)
            make.height.equalTo(SCREEN_HEIGHT)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        backgroundImageView.alpha = 0
    }
    

}
