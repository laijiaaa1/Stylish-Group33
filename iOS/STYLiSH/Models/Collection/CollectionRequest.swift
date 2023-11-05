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
    case addCollection(token: String)
    case removeCollection(token: String)
    
    var headers: [String: String] {
        switch self {
        case .getCollection(let token, _),
             .addCollection(let token),
             .removeCollection(let token):
            return [
                STHTTPHeaderField.auth.rawValue: "Bearer \(token)",
                STHTTPHeaderField.contentType.rawValue: STHTTPHeaderValue.json.rawValue
            ]
        }
    }
    var body: Data? {
        switch self {
        case .getCollection, .addCollection, .removeCollection: return nil
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
        case .getCollection(_, let paging): return "/v1/collection?\(paging)"
        }
    }
}


