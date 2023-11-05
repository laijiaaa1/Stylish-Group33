//
//  Collection.swift
//  STYLiSH
//
//  Created by Red Wang on 2023/11/4.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import Foundation

struct CollectionProducts: Codable {
    let userId: String
    let products: [Product]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case products
    }
}

struct CollectionEditResponse: Codable {
    let success: Bool
    let message: String
    let id: Int
}
