//
//  CollectionViewCell.swift
//  STYLiSH
//
//  Created by Red Wang on 2023/11/5.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import UIKit

class CollectionProductCell: UICollectionViewCell {
    
    static let identifier = "CollectionProductCell"
    var removeHandler: (() -> Void)?
    var productId: Int?
    
    // MARK: - Subviews
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let priceLabel = UILabel()
    let collectionButton = UIButton()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionButton.setImage(UIImage(named: "heart_fill"), for: .normal)
        collectionButton.setImage(UIImage(named: "heart_hollow"), for: .selected)
        collectionButton.addTarget(self, action: #selector(removeProductCell), for: .touchUpInside)
    }
    private func setUpLayouts(){
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(collectionButton)
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
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
    // MARK: - Methods
    @objc private func removeProductCell() {
        removeHandler?()
    }
    func configureCell(image: String, title: String, price: Int) {
        imageView.loadImage(image, placeHolder: .asset(.Image_Placeholder))
        titleLabel.text = title
        priceLabel.text = "$NT \(price)"
    }
}
