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
    var couponSelectionHandler: ((String?) -> Void)?
    
    var data: [CouponObject] = []
    var selectedCouponIndex: Int?
    
    let tableView = UITableView()
    let tableCellIdentifier = "tableCellIdentifier"
    let checkButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.title = "STYLiSH優惠券"
        tabBarController?.tabBar.isHidden = true
        
        data = [
        CouponObject(id: 123, type: "折扣", title: "9折", discount: 70, startDate: "2023/10/01", expiredDate: "2023/12/31", isUsed: 0),
        CouponObject(id: 123, type: "免運", title: "9折", discount: 70, startDate: "2023/10/01", expiredDate: "2023/12/31", isUsed: 0),
        CouponObject(id: 123, type: "折扣", title: "9折", discount: 70, startDate: "2023/10/01", expiredDate: "2023/12/31", isUsed: 0),
        CouponObject(id: 123, type: "折扣", title: "9折", discount: 70, startDate: "2023/10/01", expiredDate: "2023/12/31", isUsed: 0),
        CouponObject(id: 123, type: "折扣", title: "9折", discount: 70, startDate: "2023/10/01", expiredDate: "2023/12/31", isUsed: 0),
        CouponObject(id: 123, type: "折扣", title: "9折", discount: 70, startDate: "2023/10/01", expiredDate: "2023/12/31", isUsed: 0)
        ]
        
        tableView.register(UseCouponTableCell.self, forCellReuseIdentifier: tableCellIdentifier)
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.reloadData()
        
        checkButton.setTitle("確定", for: .normal)
        checkButton.backgroundColor = .darkGray
        checkButton.tintColor = .white
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(checkButton)
        NSLayoutConstraint.activate([
            checkButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            checkButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            checkButton.heightAnchor.constraint(equalToConstant: 60),
            checkButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as? UseCouponTableCell else { return UITableViewCell() }
        
        let coupon = ShowCoupon(
            title: data[indexPath.row],
            description: "des \(data[indexPath.row])",
            expiredDate: "ED for \(data[indexPath.row])",
            image: UIImage(named: "Image_Placeholder") ?? UIImage()
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
//                    cell.radioButton.isSelected = false
                }
            }
        }

        selectedCouponIndex = index
        let selectedCoupon = data[index]
        print("Selected Coupon: \(selectedCoupon)")
    }

    @objc func checkButtonTapped() {
        if let selectedCouponIndex = selectedCouponIndex {
            let selectedCoupon = data[selectedCouponIndex]
            couponSelectionHandler?(selectedCoupon)
            navigationController?.popViewController(animated: true)
        } else {
            couponSelectionHandler?(nil)
            navigationController?.popViewController(animated: true)
        }
    }

}

class UseCouponTableCell: CouponViewCell {
    var useCouponAction: ((String) -> Void)?
    var radioButton: UIButton = UIButton()
    var isToggled = false

    override var coupon: ShowCoupon? {
        didSet {
            // Update the coupon's UI
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(radioButton)

        radioButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        radioButton.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)

        radioButton.translatesAutoresizingMaskIntoConstraints = false
        radioButton.layer.cornerRadius = 15

        NSLayoutConstraint.activate([
            radioButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            radioButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            radioButton.heightAnchor.constraint(equalToConstant: 30),
            radioButton.widthAnchor.constraint(equalToConstant: 30)
        ])

        radioButton.setImage(UIImage(systemName: "smallcircle.fill.circle"), for: .selected)
        radioButton.tintColor = .black
        
        radioButton.setImage(UIImage(systemName: "circle"), for: .normal)
    }

    @objc func radioButtonTapped() {
        radioButton.isSelected.toggle()
        
        if radioButton.isSelected {
            radioButton.backgroundColor = UIColor(
                red: 225 / 255.0,
                green: 213 / 255.0,
                blue: 205 / 255.0,
                alpha: 1.0
            )
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
