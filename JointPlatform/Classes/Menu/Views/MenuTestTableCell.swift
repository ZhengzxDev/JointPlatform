//
//  MenuTestTableCell.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/4.
//

import UIKit

class MenuTestTableCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setupWith(player:GameRoomPlayer){
        titleLabel.text = player.user.nickName
        switch Server.instance.connectMode{
        case .Lan:
            detailLabel.text = player.ip_v4_address
        default:
            break
        }
        
    }
    
}
