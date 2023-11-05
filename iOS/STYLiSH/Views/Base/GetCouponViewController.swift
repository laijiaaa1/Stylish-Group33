//
//  GetCouponViewController.swift
//  
//
//  Created by laijiaaa1 on 2023/11/5.
//

import UIKit

class GetCouponViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var getCouponAction: ((String) -> Void)?
        
    var data: [String] = []
    
    let getCouponButton = UIButton()
    let tableView = UITableView()
    let tableCellIdentifier = "tableCellIdentifier"
    
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as? GetCouponTableCell else { return UITableViewCell() }
        let coupon = ShowCoupon(
            title: data[indexPath.row],
            expiredDate: "Expiration Date for \(data[indexPath.row])",
            image: UIImage(named: "Image_Placeholder") ?? UIImage()
        )
        cell.coupon = coupon

        cell.getCouponButton.setTitle("領取", for: .normal)
        cell.getCouponButton.addTarget(self, action: #selector(getCouponButtonTapped), for: .touchUpInside)

        cell.getCouponAction = { [weak self] couponData in
            self?.handleGetCouponAction(couponData)
        }
        cell.indexPath = indexPath
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    @objc func getCouponButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview as? GetCouponTableCell, let indexPath = cell.indexPath else {
            return
        }
        
        let couponData = data[indexPath.row]
        getCouponAction?(couponData)
    }

    func handleGetCouponAction(_ couponData: String) {
        print("領取的數據: \(couponData)")
    }
}

class GetCouponTableCell: TableViewCell {
    var getCouponAction: ((String) -> Void)?
    let getCouponButton = UIButton()
    var indexPath: IndexPath?
    
    override var coupon: ShowCoupon? {
        didSet {
            // Update cell's UI with the 'coupon' data
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        getCouponButton.setTitle("領取", for: .normal)
        getCouponButton.backgroundColor = .orange
        getCouponButton.layer.cornerRadius = 5
        contentView.addSubview(getCouponButton)
        getCouponButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            getCouponButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            getCouponButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            getCouponButton.heightAnchor.constraint(equalToConstant: 30),
            getCouponButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        getCouponButton.addTarget(self, action: #selector(getCouponButtonTapped), for: .touchUpInside)
    }

    @objc func getCouponButtonTapped() {
        if let couponTitle = coupon?.title {
            getCouponAction?(couponTitle)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
