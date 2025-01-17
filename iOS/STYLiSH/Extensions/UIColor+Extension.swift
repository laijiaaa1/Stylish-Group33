//
//  UIColor+Extension.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/2/13.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit

private enum STColor: String {
    // swiftlint:disable identifier_name
    case B1
    case B2
    case B3
    case B4
    case B5
    case B6
    case G1
    case C1
    case O1
    // swiftlint:enable identifier_name
}

extension UIColor {

    // swiftlint:disable identifier_name
    static let B1 = STColor(.B1)
    static let B2 = STColor(.B2)
    static let B4 = STColor(.B4)
    static let B5 = STColor(.B6)
    static let G1 = STColor(.G1)
    static let C1 = STColor(.C1)
    static let O1 = STColor(.O1)
    // swiftlint:enable identifier_name
    
    private static func STColor(_ color: STColor) -> UIColor? {
        return UIColor(named: color.rawValue)
    }

    static func hexStringToUIColor(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return .gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
