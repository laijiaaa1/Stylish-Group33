//
//  UseCouponViewController.swift
//  STYLiSH
//
//  Created by laijiaaa1 on 2023/11/5.
//  Copyright © 2023 AppWorks School. All rights reserved.
//
import UIKit

protocol UseCouponDelegate: AnyObject {
    func didSelectCoupon(_ coupon: CouponObject?)
}

class UseCouponViewController: STTableViewController {
    private let couponProvider = CouponProvider.shared
    
    weak var delegate: UseCouponDelegate?
    var selectedCoupon: CouponObject?
    var allValidCoupons: [UseCouponTableCell] = []
    var selectedCouponIndex: Int?
    
    // MARK: - Subviews
    let backgroundView = UIView()
    let seperatorView = UIView()
    private let checkButton: UIButton = {
        let checkButton = UIButton()
        checkButton.setTitle("確定", for: .normal)
        checkButton.backgroundColor = .darkGray
        checkButton.tintColor = .white
        return checkButton
    }()
    // MARK: - View Load
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            allValidCoupons.forEach { $0.resetButton() }
        }
        tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        datas = [[]]
        navigationItem.title = "STYLiSH優惠券"
        tabBarController?.tabBar.isHidden = true
        backgroundView.backgroundColor = .white
        seperatorView.backgroundColor = .G1
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        tableView.backgroundColor = .C1
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12.0, right: 0)
        tableView.separatorStyle = .none
        tableView.register(UseCouponTableCell.self, forCellReuseIdentifier: UseCouponTableCell.useCouponCellIdentifier)
        setUpLayouts()
        
        tableView.reloadData()
        
    }

    private func setUpLayouts() {
        view.addSubview(tableView)
        view.addSubview(backgroundView)
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        backgroundView.addSubview(checkButton)
        backgroundView.addSubview(seperatorView)
        backgroundView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: backgroundView.topAnchor),
            
            backgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            seperatorView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            seperatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            seperatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            seperatorView.heightAnchor.constraint(equalToConstant: 1.0),
            
            checkButton.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 16),
            checkButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            checkButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            checkButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    // MARK: - MJ Refresher
    override func headerLoader() {
        allValidCoupons = []
        datas = [[]]
        resetNoMoreData()
        couponProvider.fetchValidCoupons(completion: { [weak self] result in
            self?.endHeaderRefreshing()
            switch result {
            case .success(let response):
                self?.datas = [response.data]
                
            case .failure:
                LKProgressHUD.showFailure(text: "請先登入")
            }
        })
    }
    // MARK: - Actions
  
    @objc func checkButtonTapped() {
        if let selectedCoupon = selectedCoupon {
            delegate?.didSelectCoupon(selectedCoupon)
        } else {
            delegate?.didSelectCoupon(nil)
        }
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - TableView Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: UseCouponTableCell.useCouponCellIdentifier,
            for: indexPath) as? UseCouponTableCell else { fatalError("Cannot create cell") }
        
        guard let coupon = datas[indexPath.section][indexPath.row] as? CouponObject else { return cell }
        
        cell.coupon = coupon
        // Return to selected state for already selected coupon
        if let selectedCoupon = selectedCoupon {
            if coupon.id == selectedCoupon.id {
                cell.radioButton.isSelected = true
            }
        }
        // Pass selected value from cell to UseCouponVC
        cell.selectedCouponHandler = { coupon in
            self.selectedCoupon = coupon
            guard let coupon = coupon else { return }
            let resetCells = self.allValidCoupons.filter { cell in
                return cell.coupon?.id != coupon.id
            }
            resetCells.forEach { $0.resetButton() }
        }
        allValidCoupons.append(cell)
        return cell
    }

}
class UseCouponTableCell: CouponViewCell {
    static let useCouponCellIdentifier = "UseCouponTableCell"
    var radioButton: UIButton = UIButton()
    var isToggled = false
    var selectedCouponHandler: ((CouponObject?) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpLayouts()
      //  updateUI()
    }
    private func setUpLayouts() {
        contentView.addSubview(radioButton)
        
        radioButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        radioButton.layer.cornerRadius = 15
        radioButton.setImage(UIImage(systemName: "smallcircle.fill.circle"), for: .selected)
        radioButton.setImage(UIImage(systemName: "circle"), for: .normal)
        radioButton.tintColor = .B2
        radioButton.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)
        
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            radioButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            radioButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -35),
            radioButton.heightAnchor.constraint(equalToConstant: 30),
            radioButton.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    @objc func radioButtonTapped(sender : UIButton) {
        radioButton.isSelected.toggle()
        if radioButton.isSelected == true {
            selectedCouponHandler?(coupon!)
        } else {
            selectedCouponHandler?(nil)
        }
    }
    func resetButton(){
        radioButton.isSelected = false
        radioButton.backgroundColor = .clear
        isToggled = false
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

