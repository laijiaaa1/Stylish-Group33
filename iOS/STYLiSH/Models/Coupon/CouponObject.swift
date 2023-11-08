//
//  CouponObject.swift
//  STYLiSH
//
//  Created by Red Wang on 2023/11/5.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import Foundation

struct CouponObject: Codable {
    let id: Int
    let type: String
    let title: String
    let discount: Int?
    let startDate: String
    let expiredDate: String
    let amount: Int?
    let isUsed: Int?
}

extension String {
    func formatDate() -> String? {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        inputDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = inputDateFormatter.date(from: self) {
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "yyyy-MM-dd"
            
            return outputDateFormatter.string(from: date)
        }
        return nil
    }
}

enum CouponType {
    case discountActive
    case discountInactive
    case deliveryActive
    case deliveryInactive
    var image: UIImage {
        switch self{
        case .discountActive:
            return UIImage(named: "discount_active")!
        case .discountInactive:
            return UIImage(named: "discount_inactive")!
        case .deliveryActive:
            return UIImage(named: "delivery_active")!
        case .deliveryInactive:
            return UIImage(named: "delivery_inactive")!
        }
    }
    var type: String {
        switch self{
        case .discountActive, .discountInactive: return "折扣"
        case .deliveryActive, .deliveryInactive: return "免運"
        }
    }
    var textColor: UIColor {
        switch self{
        case .deliveryActive, .discountActive: return UIColor.B1!
        case .deliveryInactive, .discountInactive: return UIColor.G1!
        }
    }
}

