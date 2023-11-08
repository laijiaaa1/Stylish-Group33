//
//  UseCouponViewController.swift
//  STYLiSH
//
//  Created by laijiaaa1 on 2023/11/5.
//  Copyright © 2023 AppWorks School. All rights reserved.
//
//MARK: -L-useCoupon/useCoponViewController: All
import UIKit

protocol UseCouponDelegate: AnyObject {
    func didSelectCoupon(_ coupon: String?)
}

class UseCouponViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: UseCouponDelegate?
    var selectedCoupon: String?
    var couponSelectionHandler: ((String?, Int, String, Int, Int, String, String) -> Void)?
    var data: [CouponObject] = []
    var selectedCouponIndex: Int?
    
    // MARK: - Subviews
    let tableView = UITableView()
    let tableCellIdentifier = "tableCellIdentifier"
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
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "STYLiSH優惠券"
        tabBarController?.tabBar.isHidden = true
        seperatorView.backgroundColor = .G1
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .C1
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12.0, right: 0)
        tableView.separatorStyle = .none
        tableView.register(UseCouponTableCell.self, forCellReuseIdentifier: tableCellIdentifier)
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
    // MARK: - Actions
    @objc func checkButtonTapped() {
//        if let selectedCouponIndex = selectedCouponIndex {
//            let selectedCoupon = data[selectedCouponIndex]
//            couponSelectionHandler?(selectedCoupon.title, 
        //selectedCoupon.discount, selectedCoupon.type,
        //selectedCoupon.id, selectedCoupon.isUsed, selectedCoupon.startDate,
        //selectedCoupon.expiredDate)
//            navigationController?.popViewController(animated: true)
//        } else {
//            couponSelectionHandler?(nil, 0, "", 0, 0, "", "")
//            navigationController?.popViewController(animated: true)
//        }
    }
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as? UseCouponTableCell else { return UITableViewCell() }
        
        let coupon = CouponObject(
               id: data[indexPath.row].id,
               type: data[indexPath.row].type,
               title: data[indexPath.row].title,
               discount: data[indexPath.row].discount,
               startDate: data[indexPath.row].startDate,
               expiredDate: data[indexPath.row].expiredDate,
               amount: data[indexPath.row].amount,
               isUsed: data[indexPath.row].isUsed
           )
        
        cell.coupon = coupon
        cell.radioButton.isSelected = (indexPath.row == selectedCouponIndex)
        
        cell.useCouponAction = { [weak self] couponData in
            self?.handleGetCouponAction(couponData, at: indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func handleGetCouponAction(_ couponData: String, at index: Int) {
        for iiii in 0..<data.count {
            if iiii != index {
                let indexPath = IndexPath(row: iiii, section: 0)
                if let cell = tableView.cellForRow(at: indexPath) as? UseCouponTableCell {
                    cell.resetButton()
                }
            }
        }

        selectedCouponIndex = index
        let selectedCoupon = data[index]
        print("Selected Coupon: \(selectedCoupon)")
    }
}

class UseCouponTableCell: CouponViewCell {
    var useCouponAction: ((String) -> Void)?
    var radioButton: UIButton = UIButton()
    var isToggled = false

    override var coupon: CouponObject? {
        didSet {
            // Update the coupon's UI
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       setUpLayouts()
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
    @objc func radioButtonTapped() {
        radioButton.isSelected.toggle()
        
        if radioButton.isSelected {
//            radioButton.backgroundColor = UIColor(
//                red: 225 / 255.0,
//                green: 213 / 255.0,
//                blue: 205 / 255.0,
//                alpha: 1.0
//            )
        } else {
            radioButton.backgroundColor = .clear
        }
        
        useCouponAction?(coupon?.title ?? "")
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
