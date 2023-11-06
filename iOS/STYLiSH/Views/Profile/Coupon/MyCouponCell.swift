//  MyCouponCell.swift
//  STYLiSH
//
//  Created by laijiaaa1 on 2023/11/4.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

// L-coupon/MyCouponViewController: myCoupon Cell UI
import UIKit
import Foundation

enum CouponType {
    case discountActive
    case discountInactive
    case deliveryActive
    case deliveryInactive
    var image: UIImage {
        switch self{
        case .discountActive:
            return UIImage(named: "discount_active")!
        case .discountInactive:
            return UIImage(named: "discount_inactive")!
        case .deliveryActive:
            return UIImage(named: "delivery_active")!
        case .deliveryInactive:
            return UIImage(named: "delivery_inactive")!
        }
    }
}
class CouponViewCell: UITableViewCell {
    var couponImage: UIImageView!
    var couponTitle: UILabel!
    var couponDes: UILabel!
    var couponED: UILabel!
    var couponType: CouponType?
    var coupon: CouponObject? {
        didSet {
            guard let coupon = coupon else { return }
             if coupon.type == "折扣" {
                 couponType = .discountActive
            } else {
                couponType = .deliveryActive
            }
            couponTitle?.text = coupon.title
            couponTitle?.font = UIFont.systemFont(ofSize: 20)
            couponDes?.text = coupon.type
            couponDes?.font = UIFont.systemFont(ofSize: 13)
            couponED?.text = coupon.expiredDate
            couponED?.font = UIFont.systemFont(ofSize: 13)
            couponImage.contentMode = .scaleAspectFit
            couponImage.image = couponType?.image
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        couponImage = UIImageView()
        couponTitle = UILabel()
        couponDes = UILabel()
        couponED = UILabel()
        
        contentView.addSubview(couponImage)
        contentView.addSubview(couponTitle)
        contentView.addSubview(couponDes)
        contentView.addSubview(couponED)
        
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
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
