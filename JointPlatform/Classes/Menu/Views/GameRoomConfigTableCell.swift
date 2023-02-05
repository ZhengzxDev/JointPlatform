//
//  GameRoomConfigTableCell.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/4/23.
//

import UIKit

class GameRoomConfigTableCell: UITableViewCell {

    @IBOutlet weak var itemValueLabel: UILabel!
    @IBOutlet weak var itemTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        itemValueLabel.textColor = UIColor.white
        itemTitleLabel.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.4)
        itemTitleLabel.layer.cornerRadius = 5
        itemTitleLabel.textColor = UIColor.white
        itemTitleLabel.font = UIFont.systemFont(ofSize: 15,weight: .bold)
        itemTitleLabel.clipsToBounds = true
        itemValueLabel.font = UIFont.systemFont(ofSize: 17,weight: .bold)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    override func setup(model: Any?) {
        guard let pairs = model as? (String,String) else { return }
        self.itemTitleLabel.text = "  \(pairs.0)  "
        self.itemValueLabel.text = pairs.1
        self.layoutSubviews()
    }
    
}
