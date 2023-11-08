//
//  AcquireCouponViewController.swift
//  STYLiSH
//
//
//  Created by laijiaaa1 on 2023/11/5.
//

import UIKit

class AcquireCouponViewController: STTableViewController {
    
    private let couponProvider = CouponProvider.shared

    var availableCoupons: [CouponObject]?
    var alreadyOwnCoupons: [CouponObject]?
    // MARK: - Subviews
    let getCouponButton = UIButton()
    // MARK: - View Load
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        datas = []
        tabBarController?.tabBar.backgroundColor = .white
        navigationItem.title = "優惠券"
        
        tableView.register(AcquireCouponTableViewCell.self, forCellReuseIdentifier: AcquireCouponTableViewCell.subIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .C1
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
     
    }
    // MARK: - MJRefresher Methods
    override func headerLoader() {
        datas = []
        resetNoMoreData()
        fetchCoupons { [weak self] result in
            self?.endHeaderRefreshing()
            switch result {
            // Filter the coupons user can get from two APIs
            case true:
                guard let availableCoupons = self?.availableCoupons,
                      !availableCoupons.isEmpty else { return }
                if let alreadyOwnCoupons = self?.alreadyOwnCoupons,
                   alreadyOwnCoupons.isEmpty == false{
                    let ownedCouponsId = Set(alreadyOwnCoupons.compactMap { $0.id })
                    let canGetCoupons = availableCoupons.compactMap { $0
                    }.filter { !ownedCouponsId.contains($0.id) && $0.amount != 0 }
                    self?.datas = [canGetCoupons]
                } else {
                    self?.datas = [availableCoupons]
                }
            case false:
                break
            }
        
        }
    }
    // MARK: - Methods
    private func fetchCoupons(completion: @escaping (Bool) -> Void) {
        // Fetch all available coupons
        couponProvider.fetchAllCoupons(completion: { [weak self] result in
            switch result {
            case .success(let response):
                self?.availableCoupons = response.data
                // Fetch user's all coupons
                self?.couponProvider.fetchUserCoupons(completion: { [weak self] result in
                    switch result {
                    case .success(let response):
                        self?.alreadyOwnCoupons = response.data
                        completion(true)
                    case .failure(let error):
                        LKProgressHUD.showFailure(text: error.localizedDescription)
                        completion(false)
                    }
                })
                
            case .failure(let error):
                LKProgressHUD.showFailure(text: error.localizedDescription)
               completion(false)
            }
        })
    }
    private func postCoupon(_ couponId: Int, completion: @escaping (Bool) -> Void) {
        print("領取的: \(couponId)")
       
        couponProvider.acquireCoupon(couponId: couponId, completion: { [weak self] result in
            switch result {
            case .success(let response):
                if response.success == true {
                    LKProgressHUD.showSuccess(text: "\(response.message)")
                    completion(true)
                } else {
                    LKProgressHUD.showFailure(text: "\(response.message)")
                    completion(false)
                }
            case .failure:
                LKProgressHUD.showFailure(text: "無法領取")
                completion(false)
            }
        })

    }
    
    // MARK: - TableView Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AcquireCouponTableViewCell.subIdentifier,
            for: indexPath) as? AcquireCouponTableViewCell else { fatalError("Cannot create cell") }
        
        guard let coupon = datas[indexPath.section][indexPath.row] as? CouponObject else { return cell }
            cell.coupon = coupon
            
            cell.getCouponHandler = { [weak self] couponId in
                self?.postCoupon(couponId, completion: { result in
                    switch result{
                    case true:
                        cell.isCouponReceived = true
                    case false:
                        cell.isCouponReceived = false
                    }
                })
                
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }

}

class AcquireCouponTableViewCell: CouponViewCell {
    static let subIdentifier = "AcquireCouponTableViewCell"
    var getCouponHandler: ((Int) -> Void)?
    var isCouponReceived = false {
        didSet {
            updateCellUI()
        }
    }
    // MARK: - Subview
    private let getCouponButton: UIButton = {
        let getCouponButton = UIButton()
        getCouponButton.backgroundColor = .O1
        getCouponButton.setTitle("领取", for: .normal)
        getCouponButton.setTitle("已领取", for: .selected)
        getCouponButton.titleLabel?.font = .regular(size: 12)
        return getCouponButton
    }()
 
    // MARK: - View Load
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       
       couponBackground.addSubview(getCouponButton)
        getCouponButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            getCouponButton.topAnchor.constraint(equalTo: couponBackground.topAnchor, constant: 10),
            getCouponButton.trailingAnchor.constraint(equalTo: couponBackground.trailingAnchor, constant: -10),
            getCouponButton.heightAnchor.constraint(equalToConstant: 24),
            getCouponButton.widthAnchor.constraint(equalToConstant: 45)
        ])
        
        getCouponButton.addTarget(self, action: #selector(getCouponButtonTapped), for: .touchUpInside)
    }
    // MARK: - Methods
    @objc func getCouponButtonTapped() {
        // POST API
        if let couponId = coupon?.id {
            getCouponHandler?(couponId)
        }
    }
    private func updateCellUI() {
        if isCouponReceived {
            self.isUserInteractionEnabled = false
            self.getCouponButton.backgroundColor = .G1
            if couponType == .deliveryActive {
                couponType = .deliveryInactive
            } else {
                couponType = .discountInactive
            }
        } 
    }
}
