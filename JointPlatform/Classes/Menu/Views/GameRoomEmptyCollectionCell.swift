//
//  GameRoomEmptyCollectionCell.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/4/11.
//

import UIKit

class GameRoomEmptyCollectionCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.3)
        self.layer.cornerRadius = 15
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.035
        self.layer.shadowRadius = 3
        //self.clipsToBounds = false
        //self.layer.masksToBounds = false
    }

}
