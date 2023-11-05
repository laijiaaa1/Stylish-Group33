//
//  CollectionProvider.swift
//  STYLiSH
//
//  Created by Red Wang on 2023/11/4.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import UIKit

typealias CollectionResponseWithPaging = (Result<STSuccessParser<[CollectionObject]>, Error>) -> Void
typealias CollectionResponse = (Result<UserResponse, Error>) -> Void

class CollectionProvider {
  
    let decoder = JSONDecoder()
    let httpClient: HTTPClientProtocol

    init(httpClient: HTTPClientProtocol) {
        self.httpClient = httpClient
    }
    // MARK: - Public Methods
    func fetchCollectionProducts(paging: Int, completion: @escaping CollectionResponseWithPaging) {
        guard let token = KeyChainManager.shared.token else {
            return completion(.failure(STYLiSHSignInError.noToken))
        }
        fetchCollection(request: STCollectionRequest.getCollection(token: token, paging: paging), completion: completion)
    }
    func addCollectionProducts(productId: Int, completion: @escaping CollectionResponse) {
        guard let token = KeyChainManager.shared.token else {
            return completion(.failure(STYLiSHSignInError.noToken))
        }
        editCollection(request: STCollectionRequest.addCollection(token: token, productId: productId), completion: completion)
    }
    func removeCollectionProducts(productId: Int, completion: @escaping CollectionResponse) {
        guard let token = KeyChainManager.shared.token else {
            return completion(.failure(STYLiSHSignInError.noToken))
        }
        editCollection(request: STCollectionRequest.removeCollection(token: token, productId: productId), completion: completion)
    }
    
    // MARK: - Private method
    private func fetchCollection(request: STCollectionRequest, completion: @escaping CollectionResponseWithPaging) {
       
        httpClient.request(request, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let response = try self.decoder.decode(STSuccessParser<[CollectionObject]>.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    private func editCollection(request: STCollectionRequest, completion: @escaping CollectionResponse) {
       
        httpClient.request(request, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let response = try self.decoder.decode(UserResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    
    
    
    
    
}
