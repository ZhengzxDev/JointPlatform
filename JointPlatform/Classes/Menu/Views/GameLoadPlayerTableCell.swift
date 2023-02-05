//
//  GameLoadPlayerTableCell.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/2/13.
//

import UIKit

class GameLoadPlayerTableCell: UITableViewCell {
    
    private static let stateDescription:[GameLoadController.PlayerLoadState:String]=[
        GameLoadController.PlayerLoadState.Preparing:"正在准备..",
        GameLoadController.PlayerLoadState.AssetsFetching:"传输资源..",
        GameLoadController.PlayerLoadState.InitLayout:"初始化布局..",
        GameLoadController.PlayerLoadState.Offline:"连接丢失!",
        GameLoadController.PlayerLoadState.Failed:"初始化失败!"
    ]
    
    
    @IBOutlet weak var playerTagLabel: PixelTextLabel!
    @IBOutlet weak var playerNameLabel: UILabel!
    
    private var loadIndicator:UIActivityIndicatorView?
    private var loadLabel:UILabel?
    
    private var doneImageView:UIImageView?
    
    private var isLoading:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playerTagLabel.setTextColor(UIColor(r: 200, g: 200, b: 200, a: 1))
        playerNameLabel.textColor = UIColor.white
        playerNameLabel.font = UIFont.systemFont(ofSize: 20)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        loadIndicator = UIActivityIndicatorView(style: .medium)
        loadIndicator!.color = UIColor.white
        loadLabel = UILabel()
        loadLabel!.font = UIFont.systemFont(ofSize: 20)
        loadLabel!.textColor = UIColor.white
        loadLabel!.textAlignment = .right
        
        doneImageView = UIImageView(image: UIImage(named: "system_load_done"))
        doneImageView?.tintColor = UIColor.white
        self.addSubview(doneImageView!)
        doneImageView?.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        doneImageView?.isHidden = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setLoading(state:GameLoadController.PlayerLoadState){
        if state == .Done{
            self.setloading(false, describe: "")
        }
        else{
            self.setloading(true, describe: GameLoadPlayerTableCell.stateDescription[state] ?? "null")
        }
    }
    
    func setloading(_ value:Bool,describe:String){
        if value{
            self.doneImageView?.isHidden = true
            self.loadIndicator?.startAnimating()
            if !isLoading{
                self.addSubview(loadIndicator!)
                loadIndicator!.snp.makeConstraints { make in
                    make.right.equalTo(-10)
                    make.centerY.equalToSuperview()
                    make.size.equalTo(CGSize(width: 30, height: 30))
                }
                self.addSubview(loadLabel!)
                loadLabel!.snp.makeConstraints { make in
                    make.right.equalTo(loadIndicator!.snp.left).offset(-20)
                    make.centerY.equalToSuperview()
                    make.left.equalTo(playerNameLabel.snp.right)
                }
            }
            loadLabel!.text = describe
            isLoading = true
        }
        else{
            self.loadLabel?.removeFromSuperview()
            self.loadIndicator?.removeFromSuperview()
            self.loadIndicator?.stopAnimating()
            self.loadLabel?.snp.removeConstraints()
            self.loadIndicator?.snp.removeConstraints()
            self.doneImageView?.isHidden = false
        }
    }
    
    
    
    override func setup(model: Any?) {
        guard let player = model as? InGamePlayer else { return }
        self.playerTagLabel.setText("P\(player.index)")
        self.playerTagLabel.drawText()
        self.playerNameLabel.text = player.lanPlayer.user.nickName
    }
    
}
