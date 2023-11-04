//
//  collectionViewController.swift
//  STYLiSH
//
//  Created by laijiaaa1 on 2023/11/3.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import UIKit

protocol CollectionStatusDelegate: AnyObject {
    func productStatusChanged(product: Product, isCollected: Bool)
}


// MARK: - CollectionViewController
class CollectionViewController: ProductListViewController {
    
    weak var collectionStatusDelegate: CollectionStatusDelegate?
    
    var sampleData: [[Any]] = [
        ["Product 1", 19.99, "Image_Placeholder"],
        ["Product 2", 29.99, "Image_Placeholder"],
        ["Product 3", 39.99, "Image_Placeholder"]
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("收藏", comment: "")
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "collectionCustomCellIdentifier")
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        datas = [sampleData]
        
        view.addSubview(collectionView)
        
    }
    
    override  func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sampleData.count
        
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "collectionCustomCellIdentifier", for: indexPath) as? CollectionViewCell else {
            fatalError("Unable to dequeue CollectionViewCell.")
        }
        let productData = sampleData[indexPath.row]
        
        if let name = productData[0] as? String,
           let price = productData[1] as? Double,
           let imageUrl = productData[2] as? String {
            cell.imageView.image = UIImage(named: "Image_Placeholder")
            cell.titleLabel.text = name
            cell.priceLabel.text = "Price: \(price)"
        }
        
        cell.collectionButton.setImage(UIImage(named: "heart(fill)"), for: .normal)
        cell.collectionButton.tag = indexPath.row
        cell.collectionButton.addTarget(self, action: #selector(removeFromCollection(_:)), for: .touchUpInside)
        
        return cell
    }
    // back to detailPage when click item
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let product = datas[indexPath.section][indexPath.row] as? Product else { return }
        let detailVC = ProductDetailViewController()
        detailVC.product = product
        navigationController?.pushViewController(detailVC, animated: true)
    }
    //L-collection/collectionPage: remove item
    @objc func removeFromCollection(_ sender: UIButton) {
        guard let collectionView = self.collectionView else {
            return
        }

        let indexPath = IndexPath(row: sender.tag, section: 0)

        if indexPath.row < sampleData.count {
            sampleData.remove(at: indexPath.row)
            collectionView.performBatchUpdates {
                collectionView.deleteItems(at: [indexPath])
            } completion: { finished in
                if finished {
                }
            }
        }
    }
}
class CollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let priceLabel = UILabel()
    let collectionButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(collectionButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            priceLabel.heightAnchor.constraint(equalToConstant: 20),
            collectionButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            collectionButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 30),
            collectionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            collectionButton.heightAnchor.constraint(equalToConstant: 20),
            collectionButton.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
