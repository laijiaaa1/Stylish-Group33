//
//  AcquireCouponViewController.swift
//  STYLiSH
//
//
//  Created by laijiaaa1 on 2023/11/5.
//

import UIKit

class AcquireCouponViewController: STCompondViewController {
    
    var getCouponAction: ((Int) -> Void)?
    
    var data: [CouponObject] = []
    var receivedCoupons: Set<Int> = []
    
    let getCouponButton = UIButton()
    let tableCellIdentifier = "tableCellIdentifier"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tabBarController?.tabBar.backgroundColor = .white
        data = [
        CouponObject(id: 123, type: "折扣", title: "9折", discount: 90, startDate: "2023/10/01", expiredDate: "2023/12/31", isUsed: 0),
        CouponObject(id: 456, type: "免運", title: "免運", discount: 0, startDate: "2023/10/01", expiredDate: "2023/12/31", isUsed: 0),
        CouponObject(id: 789, type: "折扣", title: "9折", discount: 90, startDate: "2023/10/01", expiredDate: "2023/12/31", isUsed: 0),
        CouponObject(id: 222, type: "折扣", title: "9折", discount: 90, startDate: "2023/10/01", expiredDate: "2023/12/31", isUsed: 0),
        CouponObject(id: 333, type: "折扣", title: "9折", discount: 90, startDate: "2023/10/01", expiredDate: "2023/12/31", isUsed: 0),
        CouponObject(id: 444, type: "折扣", title: "9折", discount: 90, startDate: "2023/10/01", expiredDate: "2023/12/31", isUsed: 0)
        ]
        
        tableView.register(AcquireCouponTableViewCell.self, forCellReuseIdentifier: tableCellIdentifier)
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.reloadData()
        
        navigationItem.title = "STYLiSH優惠券"
        if let receivedCouponIDs = UserDefaults.standard.array(forKey: "receivedCouponIDs") as? [Int] {
                   self.receivedCoupons = Set(receivedCouponIDs)
               }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as? AcquireCouponTableViewCell else { return UITableViewCell() }
        let couponTitle = data[indexPath.row]
        
        let isReceived = receivedCoupons.contains(couponTitle.id)
        
        let coupon = CouponObject(
            id: data[indexPath.row].id,
            type: data[indexPath.row].type,
            title: data[indexPath.row].title,
            discount: data[indexPath.row].discount,
            startDate: data[indexPath.row].startDate,
            expiredDate: data[indexPath.row].expiredDate,
            isUsed: data[indexPath.row].isUsed
        )
        cell.coupon = coupon
        cell.isCouponReceived = isReceived
        
        cell.getCouponButton.setTitle(isReceived ? "已领取" : "領取", for: .normal)
        if coupon.type == "免運"{
            cell.couponImage.image = isReceived ? UIImage(named: "delivery_inactive") : UIImage(named: "delivery_active")
        }else{
            cell.couponImage.image = isReceived ? UIImage(named: "discount_inactive") : UIImage(named: "discount_active")
        }
        cell.getCouponButton.backgroundColor = isReceived ? UIColor(
            red: 225 / 255.0,
            green: 213 / 255.0,
            blue: 205 / 255.0,
            alpha: 1.0
        ): UIColor(
            red: 202 / 255.0,
            green: 185 / 255.0,
            blue: 163 / 255.0,
            alpha: 1.0
        )
        
        
        cell.getCouponAction = { [weak self] couponID in
            self?.handleGetCouponAction(couponID)
        }
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func handleGetCouponAction(_ couponID: Int) {
           print("领取的: \(couponID)")
           receivedCoupons.insert(couponID)
           tableView.reloadData()

           UserDefaults.standard.set(Array(receivedCoupons), forKey: "receivedCouponIDs")
       }
    
}

class AcquireCouponTableViewCell: CouponViewCell {
    var getCouponAction: ((Int) -> Void)?
    let getCouponButton = UIButton()
    var indexPath: IndexPath?
    
    var isCouponReceived = false
    
    override var coupon: CouponObject? {
        didSet {
            updateCellUI()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        getCouponButton.layer.cornerRadius = 5
        contentView.addSubview(getCouponButton)
        getCouponButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            getCouponButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            getCouponButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            getCouponButton.heightAnchor.constraint(equalToConstant: 30),
            getCouponButton.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        getCouponButton.addTarget(self, action: #selector(getCouponButtonTapped), for: .touchUpInside)
    }
    
    @objc func getCouponButtonTapped() {
        if !isCouponReceived, let couponID = coupon?.id {
            getCouponAction?(couponID)
            isCouponReceived = true
            updateCellUI()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func updateCellUI() {
        if isCouponReceived {
            
            self.isUserInteractionEnabled = false
            self.alpha = 0.5
        } else {
            
            self.isUserInteractionEnabled = true
            self.alpha = 1.0
        }
    }
}
