//
//  Nibloadable.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/4.
//

import UIKit

protocol NibLoadable{
    func loadFromNib() -> UIView
}

extension NibLoadable{
    func loadFromNib(named name:String)->UIView?{
        return Bundle.main.loadNibNamed(name, owner: self)?[0] as? UIView
    }
    func loadFromNib() -> UIView{
        return Bundle.main.loadNibNamed(NSStringFromClass(type(of: self) as! AnyClass).split(separator: ".").last!.description, owner: self, options: nil)?[0] as! UIView
    }

}
