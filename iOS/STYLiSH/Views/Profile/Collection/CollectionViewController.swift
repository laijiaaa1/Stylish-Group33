//
//  collectionViewController.swift
//  STYLiSH
//
//  Created by laijiaaa1 on 2023/11/3.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import UIKit

class CollectionViewController: STCompondViewController {

    private let collectionProvider = CollectionProvider.shared
    private var paging: Int? = 0
  
    // MARK: - View Load
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "收藏"
        
        collectionView.register(CollectionProductCell.self, forCellWithReuseIdentifier: CollectionProductCell.identifier)
        setUpCollectionViewLayout()
        showGridView()
    }
    private func setUpCollectionViewLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(
            width: Int(164.0 / 375.0 * UIScreen.width),
            height: Int(164.0 / 375.0 * UIScreen.width * 308.0 / 164.0)
        )
        flowLayout.sectionInset = UIEdgeInsets(top: 24.0, left: 16.0, bottom: 12.0, right: 16.0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 24.0
        collectionView.collectionViewLayout = flowLayout
    }
    // MARK: - MJRefresher Methods
    override func headerLoader() {
        paging = nil
        datas = []
        resetNoMoreData()
        
        collectionProvider.fetchCollectionProducts(paging: 0, completion: { [weak self] result in
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
        collectionProvider.fetchCollectionProducts(paging: paging, completion: { [weak self] result in
            self?.endFooterRefreshing()
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let originalData = self.datas.first else { return }
                let newDatas = response.data
                self.datas = [originalData + newDatas]
                self.paging = response.paging
                print(self.datas)
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
                print("Product:\(product)")
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
                    collectionView.performBatchUpdates {
                        self?.datas[indexPath.section].remove(at: indexPath.row)
                        print("New Data: \(self?.datas)")
                        collectionView.deleteItems(at: [indexPath])
                    }
                    
                }
                // POST API
                self?.collectionProvider.removeCollectionProducts(
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let product = datas[indexPath.section][indexPath.row] as? Product else { return }
        let detailVC = ProductDetailViewController()
        detailVC.product = product
        navigationController?.pushViewController(detailVC, animated: true)
    }

}


