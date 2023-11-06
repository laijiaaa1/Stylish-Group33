//
//  CouponRequest.swift
//  STYLiSH
//
//  Created by Red Wang on 2023/11/5.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import Foundation

enum STCouponRequest: STRequest {
    case allCoupons(token: String)
    case acquireCoupon(token: String, couponId: Int)
    case invalidCoupons(token: String)
    
    var headers: [String: String] {
        switch self {
        case .allCoupons(let token),
                .acquireCoupon(let token, _),
                .invalidCoupons(let token):
            return [
                STHTTPHeaderField.auth.rawValue: "Bearer \(token)",
                STHTTPHeaderField.contentType.rawValue: STHTTPHeaderValue.json.rawValue
            ]
            
        }
    }
    var body: Data? {
        switch self {
        case .acquireCoupon(_, let couponId):
            let dict = [
                "couponId": couponId
            ]
           return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        case .allCoupons, .invalidCoupons: return nil
        }
    }
    
    var method: String {
        switch self {
        case .allCoupons, .invalidCoupons:
            return STHTTPMethod.GET.rawValue
        case .acquireCoupon:
            return STHTTPMethod.POST.rawValue
        }
    }
    
    var endPoint: String {
        switch self {
        case .allCoupons, .acquireCoupon: return "/v1/coupons"
        case .invalidCoupons: return "/v1/invalid-coupons/"
        }
    }
}
