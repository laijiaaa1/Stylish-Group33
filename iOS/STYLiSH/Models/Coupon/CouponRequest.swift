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
    case validCoupons(token: String)
    case invalidCoupons(token: String)
    case userCoupons(token: String)
   
    var headers: [String: String] {
        switch self {
        case .allCoupons(let token),
                .acquireCoupon(let token, _),
                .validCoupons(let token),
                .invalidCoupons(let token),
                .userCoupons(let token):
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
                "id": couponId
            ]
           return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        case .allCoupons, .validCoupons, .invalidCoupons, .userCoupons: return nil
        }
    }
    
    var method: String {
        switch self {
        case .allCoupons, .validCoupons, .invalidCoupons, .userCoupons:
            return STHTTPMethod.GET.rawValue
        case .acquireCoupon:
            return STHTTPMethod.POST.rawValue
        }
    }
    
    var endPoint: String {
        switch self {
        case .allCoupons, .acquireCoupon: return "/v1/coupons"
        case .validCoupons: return "/v1/valid-coupons"
        case .invalidCoupons: return "/v1/invalid-coupons"
        case .userCoupons: return "/v1/user-coupons"
        }
    }
}

