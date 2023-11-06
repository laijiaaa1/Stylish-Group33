//  MyCouponCell.swift
//  STYLiSH
//
//  Created by laijiaaa1 on 2023/11/4.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

// L-coupon/MyCouponViewController: myCoupon Cell UI
import UIKit
import Foundation

//need 
class CollectionViewCell: UICollectionViewCell{}

class TableViewCell: UITableViewCell {
    var couponImage: UIImageView!
    var couponTitle: UILabel!
    var couponDes: UILabel!
    var couponED: UILabel!
    var coupon: ShowCoupon? {
        didSet {
            guard let coupon = coupon else { return }
            couponTitle?.text = coupon.title
            couponTitle?.font = UIFont.systemFont(ofSize: 20)
            couponDes?.text = coupon.description
            couponDes?.font = UIFont.systemFont(ofSize: 13)
            couponED?.text = coupon.expiredDate
            couponED?.font = UIFont.systemFont(ofSize: 13)
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
        couponDes = UILabel()
        couponED = UILabel()
        
        couponImage.translatesAutoresizingMaskIntoConstraints = false
        couponTitle.translatesAutoresizingMaskIntoConstraints = false
        couponDes.translatesAutoresizingMaskIntoConstraints = false
        couponED.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(couponImage)
        contentView.addSubview(couponTitle)
        contentView.addSubview(couponDes)
        contentView.addSubview(couponED)
        
        NSLayoutConstraint.activate([
            couponImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            couponImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            couponImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            couponImage.widthAnchor.constraint(equalToConstant: 80),
            couponImage.heightAnchor.constraint(equalToConstant: 80),
            
            couponTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
            couponTitle.leadingAnchor.constraint(equalTo: couponImage.trailingAnchor, constant: 20),
            couponTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            couponDes.topAnchor.constraint(equalTo: couponTitle.bottomAnchor, constant: 15),
            couponDes.leadingAnchor.constraint(equalTo: couponImage.trailingAnchor, constant: 20),
            couponDes.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            couponED.topAnchor.constraint(equalTo: couponDes.bottomAnchor, constant: 5),
            couponED.leadingAnchor.constraint(equalTo: couponImage.trailingAnchor, constant: 20),
            couponED.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
