//
//  CollectionRequest.swift
//  STYLiSH
//
//  Created by Red Wang on 2023/11/4.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import UIKit

enum STCollectionRequest: STRequest {
    case getCollection(token: String, paging: Int)
    case addCollection(token: String, productId: Int)
    case removeCollection(token: String, productId: Int)
    
    var headers: [String: String] {
        switch self {
        case .getCollection(let token, _),
             .addCollection(let token, _),
             .removeCollection(let token, _):
            return [
                STHTTPHeaderField.auth.rawValue: "Bearer \(token)",
                STHTTPHeaderField.contentType.rawValue: STHTTPHeaderValue.json.rawValue
            ]
        }
    }
    var body: Data? {
        switch self {
        case .getCollection: 
            return nil
        case .addCollection(_, let productId):
           let dict = [
                "productId": productId,
                "method": "create"
           ] as [String : Any]
            return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        case .removeCollection(_, let productId):
            let dict = [
                 "productId": productId,
                 "method": "delete"
            ] as [String : Any]
             return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        }
    }
    
    var method: String {
        switch self {
        case .getCollection:
            return STHTTPMethod.GET.rawValue
        case .addCollection, .removeCollection:
            return STHTTPMethod.POST.rawValue
        }
    }
    
    var endPoint: String {
        switch self {
        case .addCollection, .removeCollection: return "/v1/collection"
        case .getCollection(_, let paging): return "/v1/collection?paging=\(paging)"
        }
    }
}


