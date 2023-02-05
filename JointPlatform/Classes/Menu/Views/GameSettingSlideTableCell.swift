//
//  GameSettingSlideTableCell.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/4/25.
//

import UIKit


protocol GameSettingSlideTableCellDelegate:NSObjectProtocol{
    
    func settingSliderTableCell(_ tableCell:GameSettingSlideTableCell, didChangeValueTo progress:CGFloat)
    
}

class GameSettingSlideTableCell: UITableViewCell {

    @IBOutlet weak var sliderView: JtSliderView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    public weak var delegate:GameSettingSlideTableCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sliderView.delegate = self
        self.itemTitleLabel.textColor = UIColor.white
        self.itemTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        self.sliderView.setBarSize(CGSize(width: 160, height: 10))
        self.sliderView.backgroundColor = UIColor.clear
        self.sliderView.setBarColor(.lightGray)
        self.sliderView.setDotColor(.white)
        self.sliderView.setDotSize(CGSize(width: 25, height: 25))
        self.containerView.backgroundColor = UIColor(r: 0, g: 0, b: 0, a: 0.3)
        self.containerView.layer.cornerRadius = 5
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setup(model: Any?) {
        guard let configList = model as? [String:Any] else { return }
        guard let title = configList["title"] as? String else { return }
        guard let value = configList["value"] as? CGFloat else { return }
        self.itemTitleLabel.text = title
        self.sliderView.setDefaultProgress(value)
    }
    
}

extension GameSettingSlideTableCell:JtSliderViewDelegate{
    func jtSlider(_ sliderView: JtSliderView, didChangeValueTo progress: CGFloat) {
        delegate?.settingSliderTableCell(self, didChangeValueTo: progress)
    }
}
