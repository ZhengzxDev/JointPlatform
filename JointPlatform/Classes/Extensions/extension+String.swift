//
//  extension+String.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2020/7/16.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit

extension String{
    
    
    static func rand(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar,length: 1) as String
        }
        return randomString
    }
    
    static func simplifyInt(_ number:Int)->String{
        var digit:Int = 0
        var tmp = number
        while(tmp >= 1){
            tmp /= 10
            digit += 1
        }
        let unit:[String] = ["K","M","G","T","P","E"]
        var level:Int = Int(digit / 3)
        if digit % 3 == 0 && digit != 0{
            level -= 1
        }
        if level == 0{
            return String(number)
        }
        else{
            var divisor:Double = 1
            for _ in 0 ..< level*3{
                divisor *= 10
            }
            let fixNum = Double(number)/divisor
            let strNum = String(fixNum)
            let strArray:[Substring] = strNum.split(separator: ".")
            if strArray[1].count > 2{
                let fixedDecimal = String(strArray[1].prefix(2))
                return String(strArray[0]) + "." + fixedDecimal + unit[level-1]
            }
            return strNum + unit[level-1]
        }
    }
    
    static func getHeight(_ text: String,width: CGFloat,font:UIFont)->CGFloat{
        let size = CGSize(width: width, height: CGFloat.infinity)
        let attributes = [NSAttributedString.Key.font: font]
        let labelSize = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return CGFloat(ceil(labelSize.height))
    }
    
    static func getWidth(_ text: String,height: CGFloat,font:UIFont)->CGFloat{
        let size = CGSize(width: CGFloat.infinity, height: height)
        let attributes = [NSAttributedString.Key.font: font]
        let labelSize = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return CGFloat(ceil(labelSize.width))
    }
    
    static func getHeight(_ text:String,width:CGFloat,attributes:[NSAttributedString.Key:Any])->CGFloat{
        let size = CGSize(width: width, height: CGFloat.infinity)
        let labelSize = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return CGFloat(ceil(labelSize.height))
    }
    
    static func getWidth(_ text:String,height:CGFloat,attributes:[NSAttributedString.Key:Any])->CGFloat{
        let size = CGSize(width: CGFloat.infinity, height: height)
        let labelSize = NSString(string: text).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return CGFloat(ceil(labelSize.width))
    }
    
    /**
     base64加密
     */
    static func base64Encode(str:String) -> String {
        let plainData = str.data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: .init(rawValue: 0))
        return base64String!
    }
    
    /**
     base64解密
     */
    static func base64Decode(encodeString:String) -> String{
        let decodedData = Data(base64Encoded: encodeString,options: Data.Base64DecodingOptions.init(rawValue: 0))
        let decodedString = String(data: decodedData! as Data, encoding: String.Encoding.utf8)! as String
        return decodedString
    }
    
    /**
     获取该字符串对应的本地化字符串
     */
    func localize()->String{
        return NSLocalizedString(self, comment: "")
    }
    
    /**
     是否是浮点数
     */
    func isFloat() -> Bool{
        let scanner = Scanner(string: self)
        var floatVal:Float = 0
        return scanner.scanFloat(&floatVal) && scanner.isAtEnd
    }

    
    /**
     转化成Double
     */
    func toDouble() -> Double?{
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    
}
