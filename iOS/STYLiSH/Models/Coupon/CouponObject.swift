//
//  CouponObject.swift
//  STYLiSH
//
//  Created by Red Wang on 2023/11/5.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import Foundation

struct CouponObject: Codable {
    let couponId: Int
    let couponType: String
    let couponTitle: String
    let couponExpiredDate: String
    let isUsed: Bool
}




