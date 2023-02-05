//
//  extension+UITableViewCell.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2020/7/15.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit

protocol ModelSettable {
    func setup(model:Any?)
}


extension UITableViewCell:ModelSettable{
    @objc
    func setup(model: Any?) {
        //model initialize
    }
    
    
}


extension UICollectionViewCell:ModelSettable{
    @objc
    func setup(model:Any?){
        //
    }
}
