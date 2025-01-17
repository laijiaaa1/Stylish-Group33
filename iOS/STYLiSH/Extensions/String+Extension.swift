//
//  String+Extension.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/7/29.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import Foundation

extension String {

    static let empty = ""
}

extension User {
    
    func getUserInfo() -> String {
        if email == "wayne.swchen@gmail.com" {
            return "AKA 小安老師"
        } else {
            return "Do you wanna build a snowman?"
        }
    }
}
extension UserProfile {
    
    func getUserInfo(userProfile: UserProfile) -> String {
        if email == "\(userProfile.email)" {
            return "帳號 ID : \(userProfile.id)"
        } else {
            return ""
        }
    }
}
