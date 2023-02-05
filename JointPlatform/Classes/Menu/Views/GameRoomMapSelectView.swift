//
//  GameRoomMapSelectView.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/4/15.
//

import UIKit


protocol GameRoomMapSelectViewDelegate:NSObjectProtocol{
    
    func mapSelectViewOnPressNext(_ selectView:GameRoomMapSelectView)
    
    func mapSelectViewOnPressPrevious(_ selectView:GameRoomMapSelectView)
    
}

class GameRoomMapSelectView:UIView,ModelSettable,NibLoadable{
    
    
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var mapNameLabel: UILabel!
    
    @IBOutlet weak var previousButton: CUButton!
    @IBOutlet weak var nextButton: CUButton!
    private var contentView:UIView?
    
    public weak var delegate:GameRoomMapSelectViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = loadFromNib()
        self.addSubview(contentView!)
        contentView!.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.mapImageView.contentMode = .scaleAspectFill
        self.mapImageView.backgroundColor = UIColor.black
        self.panelView.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.7)
        self.previousButton.setTitle("", for: .normal)
        self.nextButton.setTitle("", for: .normal)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup(model: Any?) {
        guard let map = model as? GameMap else { return }
        
        switch map {
        case .Forest:
            self.mapImageView.image = UIImage(named: "post_map_forest")
            self.mapNameLabel.text = "热带雨林"
        case .Lab:
            self.mapImageView.image = UIImage(named: "post_map_unknown")
            self.mapNameLabel.text = "太空实验室"
        default:
            self.mapImageView.image = UIImage(named: "post_map_unknown")
            self.mapNameLabel.text = "未知地图"
        }
    }
    

    @IBAction func onPressPreviousMap(_ sender: Any) {
        delegate?.mapSelectViewOnPressPrevious(self)
    }
    
    @IBAction func onPressNextMap(_ sender: Any) {
        delegate?.mapSelectViewOnPressNext(self)
    }
    
    
}
