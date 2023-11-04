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


class CollectionViewController: ProductListViewController {
    
    weak var collectionStatusDelegate: CollectionStatusDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("收藏", comment: "")
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "collectionCustomCellIdentifier")
        
        let yourData = [[Any]]()
        datas = yourData
        view.addSubview(collectionView)
        
    }
    
    override  func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "collectionCustomCellIdentifier", for: indexPath) as? CollectionViewCell else {
            fatalError("Unable to dequeue CollectionViewCell.")
        }

        cell.imageView.image = UIImage(named: "Image_Placeholder")
        cell.titleLabel.text = "Title"
        cell.priceLabel.text = "Price"
        
        cell.collectionButton.setImage(UIImage(named: "heart(fill)"), for: .normal)
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
    
    // remove from collection list
    
    @objc func removeFromCollection(_ sender: UIButton) {
        guard let cell = sender.superview as? CollectionViewCell,
              let collectionView = self.collectionView,
              let indexPath = collectionView.indexPath(for: cell),
              let product = datas[indexPath.section][indexPath.row] as? Product else {
            return
        }
        
        datas[indexPath.section].remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
        collectionStatusDelegate?.productStatusChanged(product: product, isCollected: false)
        
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
