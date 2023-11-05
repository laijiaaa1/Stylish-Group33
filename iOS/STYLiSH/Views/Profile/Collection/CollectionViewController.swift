//
//  collectionViewController.swift
//  STYLiSH
//
//  Created by laijiaaa1 on 2023/11/3.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import UIKit

class CollectionViewController: ProductListViewController {

    var collectionProvider: CollectionProvider?

    private var paging: Int? = 0

    // MARK: - View Load
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("收藏", comment: "")
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        collectionView.register(CollectionProductCell.self, forCellWithReuseIdentifier: CollectionProductCell.identifier)
        view.addSubview(collectionView)
    
    }
    // MARK: - MJRefresher Methods
    override func headerLoader() {
        paging = nil
        datas = []
        resetNoMoreData()
        collectionProvider?.fetchCollectionProducts(paging: 0, completion: { [weak self] result in
            self?.endHeaderRefreshing()
            switch result {
            case .success(let response):
                self?.datas = [response.data]
                self?.paging = response.paging
            case .failure(let error):
                LKProgressHUD.showFailure(text: error.localizedDescription)
            }
        })
    }

    override func footerLoader() {
        guard let paging = paging else {
            endWithNoMoreData()
            return
        }
        collectionProvider?.fetchCollectionProducts(paging: paging, completion: { [weak self] result in
            self?.endFooterRefreshing()
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let originalData = self.datas.first else { return }
                let newDatas = response.data
                self.datas = [originalData + newDatas]
                self.paging = response.paging
            case .failure(let error):
                LKProgressHUD.showFailure(text: error.localizedDescription)
            }
        })
    }
    // MARK: - Collection View Data Source
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CollectionProductCell.identifier, for: indexPath) as? CollectionProductCell else {
                fatalError("Unable to dequeue cell")
            }
            
            if let product = datas[indexPath.section][indexPath.row] as? Product {
                cell.productId = product.id
                cell.configureCell(
                    image: product.mainImage,
                    title: product.title,
                    price: product.price
                )
            }
            
            // Remove Cell
            cell.removeHandler = { [weak self] in
                if let indexPath = collectionView.indexPath(for: cell) {
                    self?.datas.remove(at: indexPath.row)
                    collectionView.performBatchUpdates {
                        collectionView.deleteItems(at: [indexPath])
                    }
                }
                // POST API
                self?.collectionProvider?.removeCollectionProducts(
                    productId: cell.productId!,
                    completion: { result in
                        switch result {
                        case .success(let response):
                            if response.success == true {
                                LKProgressHUD.showSuccess(text: "已移除")
                            } else {
                                LKProgressHUD.showSuccess(text: "已移除")
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    })
                
            }
            
            return cell
        }
    
    // MARK: - Collection View Delegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let product = datas[indexPath.section][indexPath.row] as? Product else { return }
        let detailVC = ProductDetailViewController()
        detailVC.product = product
        navigationController?.pushViewController(detailVC, animated: true)
    }

}


