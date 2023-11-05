//  MyCouponCell.swift
//  STYLiSH
//
//  Created by laijiaaa1 on 2023/11/4.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

// L-coupon/MyCouponViewController: myCoupon Cell UI
import UIKit
import Foundation

class CollectionViewCell: UICollectionViewCell { }

class TableViewCell: UITableViewCell {
    var couponImage: UIImageView!
    var couponTitle: UILabel!
    var couponDesc: UILabel!
    var coupon: ShowCoupon? {
        didSet {
            guard let coupon = coupon else { return }
            couponTitle?.text = coupon.title
            couponTitle?.font = UIFont.systemFont(ofSize: 20)
            
            couponDesc?.text = coupon.expiredDate
            couponDesc?.font = UIFont.systemFont(ofSize: 15)
            couponImage.contentMode = .scaleAspectFit
            if coupon.type == "折扣" {
                couponImage?.image = UIImage(named: "discount")
            } else {
                couponImage?.image = UIImage(named: "freeTransportation")
            }
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        couponImage = UIImageView()
        couponTitle = UILabel()
        couponDesc = UILabel()
        
        couponImage.translatesAutoresizingMaskIntoConstraints = false
        couponTitle.translatesAutoresizingMaskIntoConstraints = false
        couponDesc.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(couponImage)
        contentView.addSubview(couponTitle)
        contentView.addSubview(couponDesc)
        
        NSLayoutConstraint.activate([
            couponImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            couponImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            couponImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            couponImage.widthAnchor.constraint(equalToConstant: 80),
            couponImage.heightAnchor.constraint(equalToConstant: 80),
            
            couponTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            couponTitle.leadingAnchor.constraint(equalTo: couponImage.trailingAnchor, constant: 20),
            couponTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            couponDesc.topAnchor.constraint(equalTo: couponTitle.bottomAnchor, constant: 15),
            couponDesc.leadingAnchor.constraint(equalTo: couponImage.trailingAnchor, constant: 20),
            couponDesc.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            couponDesc.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
