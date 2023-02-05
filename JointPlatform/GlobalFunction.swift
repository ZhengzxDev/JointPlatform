//
//  GlobalFunction.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/9.
//

import UIKit

func debugLog(_ str:String){
    guard DEBUG_MODE else { return }
    print(str)
}
