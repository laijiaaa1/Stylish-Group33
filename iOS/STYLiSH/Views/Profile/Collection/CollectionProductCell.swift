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
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private let collectionButton: UIButton = {
        let collectionButton = UIButton()
        collectionButton.setImage(UIImage(named: "heart_fill"), for: .normal)
        collectionButton.setImage(UIImage(named: "heart_hollow"), for: .selected)
        return collectionButton
    }()
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .left
        titleLabel.font = .regular(size: 15)
        titleLabel.textColor = .B1
        return titleLabel
    }()
    private let priceLabel: UILabel = {
        let priceLabel = UILabel()
        priceLabel.textAlignment = .left
        priceLabel.font = .regular(size: 15)
        priceLabel.textColor = .B1
        return priceLabel
    }()
    // MARK: - View Load
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayouts()
     
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
            imageView.heightAnchor.constraint(equalToConstant: 220),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -29),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            collectionButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            collectionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
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
        priceLabel.text = "NT$\(price)"
    }
}
