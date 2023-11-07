//
//  GetCouponViewController.swift
//  
//
//  Created by laijiaaa1 on 2023/11/5.
//
//MARK: -L-getCoupon/getCoponViewController: All
import UIKit

class GetCouponViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var getCouponAction: ((String) -> Void)?
    
    var data: [String] = []
    var receivedCoupons: Set<String> = []
    
    let getCouponButton = UIButton()
    let tableView = UITableView()
    let tableCellIdentifier = "tableCellIdentifier"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        data = ["Coupon 1", "Coupon 2", "Coupon 3"]
        
        tableView.register(GetCouponTableCell.self, forCellReuseIdentifier: tableCellIdentifier)
        
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
        if let receivedCoupons = UserDefaults.standard.stringArray(forKey: "receivedCoupons") {
            self.receivedCoupons = Set(receivedCoupons)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as? GetCouponTableCell else { return UITableViewCell() }
        let couponTitle = data[indexPath.row]
        
        let isReceived = receivedCoupons.contains(couponTitle)
        
        let coupon = ShowCoupon(
            title: couponTitle,
            description: "des \(couponTitle)",
            expiredDate: "Expiration Date for \(couponTitle)",
            image: UIImage(named: "Image_Placeholder") ?? UIImage()
        )
        cell.coupon = coupon
        cell.isCouponReceived = isReceived
        
        cell.getCouponButton.setTitle(isReceived ? "已領取" : "領取", for: .normal)
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
        
        cell.getCouponAction = { [weak self] couponData in
            self?.handleGetCouponAction(couponData)
        }
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func handleGetCouponAction(_ couponData: String) {
        if !receivedCoupons.contains(couponData) {
            receivedCoupons.insert(couponData)
            tableView.reloadData()
             UserDefaults.standard.set(Array(receivedCoupons), forKey: "receivedCoupons")
        }
    }
}

class GetCouponTableCell: TableViewCell {
    var getCouponAction: ((String) -> Void)?
    let getCouponButton = UIButton()
    var indexPath: IndexPath?
    
    var isCouponReceived = false
    
    override var coupon: ShowCoupon? {
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
        if !isCouponReceived, let couponTitle = coupon?.title {
            getCouponAction?(couponTitle)
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
