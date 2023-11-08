//  MyCouponCell.swift
//  STYLiSH
//
//  Created by laijiaaa1 on 2023/11/4.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

// L-coupon/MyCouponViewController: myCoupon Cell UI
import UIKit
import Foundation


class CouponViewCell: UITableViewCell {
    static let cellIdentifier = "CouponViewCell"
    var couponType: CouponType? {
        didSet {
            updateCellUI()
        }
    }
    var coupon: CouponObject? {
        didSet {
            guard let coupon = coupon else { return }
             if coupon.type == "折扣" {
                 couponType = .discountActive
            } else {
                couponType = .deliveryActive
            }
            layoutCell(coupon: coupon)
        }
    }
    // MARK: - Subviews
    var couponBackground: UIView = {
        var couponBackground = UIView()
        couponBackground.backgroundColor = .white
        return couponBackground
    }()
    var couponImage: UIImageView = {
        var couponImage = UIImageView()
        couponImage.contentMode = .scaleAspectFit
        couponImage.backgroundColor = .clear
        return couponImage
    }()
    var couponTitle: UILabel = {
        var couponTitle = UILabel()
        couponTitle.font = UIFont.systemFont(ofSize: 16)
        return couponTitle
    }()
    var couponDes: UILabel = {
        var couponDes = UILabel()
        couponDes.font = UIFont.systemFont(ofSize: 14)
        return couponDes
    }()
    var couponED: UILabel = {
        var couponED = UILabel()
        couponED.font = UIFont.systemFont(ofSize: 10)
        return couponED
    }()
    var couponSD: UILabel = {
        var couponSD = UILabel()
        couponSD.font = UIFont.systemFont(ofSize: 10)
        return couponSD
    }()
    // MARK: - View Load
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .C1
        setUpLayouts()
    }
    private func setUpLayouts() {
        contentView.addSubview(couponBackground)
        contentView.addSubview(couponImage)
        contentView.addSubview(couponTitle)
        contentView.addSubview(couponDes)
        contentView.addSubview(couponED)
        contentView.addSubview(couponSD)
        
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            couponBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            couponBackground.leadingAnchor.constraint(equalTo: couponImage.trailingAnchor),
            couponBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            couponBackground.heightAnchor.constraint(equalToConstant: 100),
            
            couponImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            couponImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            couponImage.widthAnchor.constraint(equalToConstant: 100),
            couponImage.heightAnchor.constraint(equalToConstant: 100),
            
            couponTitle.topAnchor.constraint(equalTo: couponBackground.topAnchor, constant: 10),
            couponTitle.leadingAnchor.constraint(equalTo: couponImage.trailingAnchor, constant: 20),
            
            couponDes.topAnchor.constraint(equalTo: couponTitle.bottomAnchor, constant: 5),
            couponDes.leadingAnchor.constraint(equalTo: couponImage.trailingAnchor, constant: 20),
            
            couponSD.leadingAnchor.constraint(equalTo: couponImage.trailingAnchor, constant: 20),
            couponSD.bottomAnchor.constraint(equalTo: couponED.topAnchor, constant: -2),
           
            couponED.leadingAnchor.constraint(equalTo: couponImage.trailingAnchor, constant: 20),
            couponED.bottomAnchor.constraint(equalTo: couponBackground.bottomAnchor, constant: -10)
        ])
    }
    // MARK: - Methods
    private func layoutCell(coupon: CouponObject) {
        couponTitle.text = coupon.title
        couponDes.text = coupon.type
        let expiredDate = coupon.expiredDate.formatDate()
        couponED.text = "有效期限：\(expiredDate!)"
        let startDate = coupon.startDate.formatDate()
        couponSD.text = "生效日期：\(startDate!)"
        
        updateCellUI()
    }
    private func updateCellUI() {
        couponImage.image = couponType?.image
        couponTitle.textColor = couponType?.textColor
        couponDes.textColor = couponType?.textColor
        couponED.textColor = couponType?.textColor
        couponSD.textColor = couponType?.textColor
    }
   
}
