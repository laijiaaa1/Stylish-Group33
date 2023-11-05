//
//  UserObject.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/3/7.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import Foundation

struct UserObject: Codable {
    let accessToken: String
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case user
        case accessToken = "access_token"
    }
}

struct User: Codable {
    let id: Int?
    let provider: String
    let name: String
    let email: String
    let picture: String
}

struct UserProfile: Codable {
    let id: Int
    let email: String
    let name: String
    let picture: String
}

struct Reciept: Codable {
    let number: String
}


struct UserResponse: Codable {
    let success: Bool
    let message: String
    let id: Int?
    let couponId: Int?
}
