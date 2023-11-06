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
    let discount: Int
    let startDate: String
    let expiredDate: String
    let isUsed: Int
}




