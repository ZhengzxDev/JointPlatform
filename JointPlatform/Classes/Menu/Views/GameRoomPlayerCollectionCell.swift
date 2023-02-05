//
//  GameRoomPLayerCollectionCell.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/2/13.
//

import UIKit


protocol GameRoomPlayerCollectionCellDelegate:NSObjectProtocol{
    func playerCellOnPressNextHero(_ collectionCell:GameRoomPlayerCollectionCell)
    func playerCellOnPressPreviousHero(_ collectionCell:GameRoomPlayerCollectionCell)
    func playerCellOnPressNextTeam(_ collectionCell:GameRoomPlayerCollectionCell)
    func playerCellOnPressPreviousTeam(_ collectionCell:GameRoomPlayerCollectionCell)
}

class GameRoomPlayerCollectionCell: UICollectionViewCell {

    @IBOutlet weak var indexLabel: PixelTextLabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var teamContainerView: UIView!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var heroArrowLeftButton: CUButton!
    @IBOutlet weak var readyImageView: UIImageView!
    
    @IBOutlet weak var heroArrowRightButton: CUButton!
    @IBOutlet weak var teamArrowLeftButton: CUButton!
    @IBOutlet weak var teamArrowRightButton: CUButton!
    
    
    
    public weak var delegate:GameRoomPlayerCollectionCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 15
        self.indexLabel.setTextColor(UIColor.darkGray)
        self.indexLabel.setAlphabetSize(CGSize(width: 15, height: 30))
        self.indexLabel.setAligment(vertical: .Middle, horizontal: .center)
        heroArrowLeftButton.setTitle("", for: .normal)
        heroArrowRightButton.setTitle("", for: .normal)
        teamArrowLeftButton.setTitle("", for: .normal)
        teamArrowRightButton.setTitle("", for: .normal)
        
        indexLabel.backgroundColor = UIColor.clear
        nameLabel.textColor = UIColor.black
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.035
        self.layer.shadowRadius = 3
        //self.clipsToBounds = false
        //self.layer.masksToBounds = false
    }
    
    override func setup(model: Any?) {
        guard let inGamePlayer = model as? InGamePlayer else { return }
        self.indexLabel.setText("P\(inGamePlayer.index)")
        self.nameLabel.text = inGamePlayer.lanPlayer.user.nickName
        self.readyImageView.isHidden = !inGamePlayer.lanPlayer.isReady
        
        setHero(inGamePlayer.hero)
        setTeam(inGamePlayer.team)
    }
    
    func setHero(_ hero:Hero){
        switch hero{
        case .WoftMan:
            self.heroImageView.image = UIImage(named: "woft_man_idle_0")
        case .Engineer:
            self.heroImageView.image = UIImage(named: "engineer_idle_0")
        default:
            self.heroImageView.image = UIImage(named: "gui_hero_unknown")
        }
    }
    
    func setTeam(_ index:Int){
        self.teamLabel.text = "队伍 \(index)"
        switch index{
        case 0:
            self.teamContainerView.backgroundColor = UIColor(hex: "#fe3406")!
        case 1:
            self.teamContainerView.backgroundColor = UIColor(hex: "#0685fe")!
        case 2:
            self.teamContainerView.backgroundColor = UIColor(hex: "#06ab23")!
        case 3:
            self.teamContainerView.backgroundColor = UIColor(hex: "#a408ce")!
        default:
            self.teamContainerView.backgroundColor = UIColor.darkGray
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.indexLabel.drawText()
    }
    
    

    @IBAction func onPressPreviousHero(_ sender: Any) {
        delegate?.playerCellOnPressPreviousHero(self)
    }
    
    @IBAction func onPressNextHero(_ sender: Any) {
        delegate?.playerCellOnPressNextHero(self)
    }
    
    @IBAction func onPressPreviousTeam(_ sender: Any) {
        delegate?.playerCellOnPressPreviousTeam(self)
    }
    
    @IBAction func onPressNextTeam(_ sender: Any) {
        delegate?.playerCellOnPressNextTeam(self)
    }
    
}

