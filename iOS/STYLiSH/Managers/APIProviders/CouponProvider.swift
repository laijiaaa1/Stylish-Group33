//
//  CouponProvider.swift
//  STYLiSH
//
//  Created by Red Wang on 2023/11/5.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import UIKit

typealias CouponResponse = (Result<STSuccessParser<[CouponObject]>, Error>) -> Void
typealias AcquireCouponResponse = (Result<UserResponse, Error>) -> Void

class CouponProvider {
    static let shared = CouponProvider(httpClient: HTTPClient())
    let decoder = JSONDecoder()
    let httpClient: HTTPClientProtocol

    init(httpClient: HTTPClientProtocol) {
        self.httpClient = httpClient
    }
    // MARK: - Public Methods
    func fetchAllCoupons(completion: @escaping CouponResponse) {
        guard let token = KeyChainManager.shared.token else {
            return completion(.failure(STYLiSHSignInError.noToken))
        }
        fetchCoupon(request: STCouponRequest.allCoupons(token: token), completion: completion)
    }
    func fetchInvalidCoupons(completion: @escaping CouponResponse) {
        guard let token = KeyChainManager.shared.token else {
            return completion(.failure(STYLiSHSignInError.noToken))
        }
        fetchCoupon(request: STCouponRequest.invalidCoupons(token: token), completion: completion)
    }
    func fetchValidCoupons(completion: @escaping CouponResponse) {
        guard let token = KeyChainManager.shared.token else {
            return completion(.failure(STYLiSHSignInError.noToken))
        }
        fetchCoupon(request: STCouponRequest.validCoupons(token: token), completion: completion)
    }
    func fetchUserCoupons(completion: @escaping CouponResponse) {
        guard let token = KeyChainManager.shared.token else {
            return completion(.failure(STYLiSHSignInError.noToken))
        }
        fetchCoupon(request: STCouponRequest.userCoupons(token: token), completion: completion)
    }
    func acquireCoupon(couponId: Int, completion: @escaping AcquireCouponResponse) {
        guard let token = KeyChainManager.shared.token else {
            return completion(.failure(STYLiSHSignInError.noToken))
        }
        acquireCoupon(request: STCouponRequest.acquireCoupon(token: token, couponId: couponId), completion: completion)
    }
    
    // MARK: - Private method
    private func fetchCoupon(request: STCouponRequest, completion: @escaping CouponResponse) {
        httpClient.request(request, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                do {
                    let response = try self.decoder.decode(STSuccessParser<[CouponObject]>.self, from: data)
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

    private func acquireCoupon(request: STCouponRequest, completion: @escaping AcquireCouponResponse) {
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
