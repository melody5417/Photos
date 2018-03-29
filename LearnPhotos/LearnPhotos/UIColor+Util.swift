//
//  UIColor+Util.swift
//  LearnPhotos
//
//  Created by yiqiwang(王一棋) on 2018/3/29.
//

import Foundation
import UIKit

extension UIColor {

    convenience init(rgb: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }

    convenience init(hex: String, alpha: CGFloat = 1) {
        var cString: String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }

        var alpha = alpha
        if (cString as NSString).length >= 8 {
            let aString = (cString as NSString).substring(to: 2)
            cString = (cString as NSString).substring(from: 2)
            var a: CUnsignedInt = 0
            Scanner(string: aString).scanHexInt32(&a)
            alpha = CGFloat(a) / 255.0
        }

        var rString = "FF"
        if (cString as NSString).length >= 2 {
            rString = (cString as NSString).substring(to: 2)
            cString = (cString as NSString).substring(from: 2)
        }
        var gString = "FF"
        if (cString as NSString).length >= 2 {
            gString = (cString as NSString).substring(to: 2)
            cString = (cString as NSString).substring(from: 2)
        }
        var bString = "FF"
        if (cString as NSString).length >= 2 {
            bString = (cString as NSString).substring(to: 2)
        }

        var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        self.init(red:CGFloat(r) / 255.0, green:CGFloat(g) / 255.0, blue:CGFloat(b) / 255.0, alpha: alpha)
    }
}
