//
//  Collection.swift
//  STYLiSH
//
//  Created by Red Wang on 2023/11/4.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import Foundation

struct CollectionObject: Codable {
    let userId: String
    let products: [Product]
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case products
    }
}

