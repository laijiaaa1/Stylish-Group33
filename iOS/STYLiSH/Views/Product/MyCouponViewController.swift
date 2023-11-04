//
//  MyCouponViewController.swift
//  
//
//  Created by laijiaaa1 on 2023/11/4.
//

// L-coupon/MyCouponViewController: myCoupon ViewController UI
import UIKit

struct Coupon: Codable {
    let couponId: Int
    let couponType: String
    let couponTitle: String
    let couponDiscount: Double
    let couponStartDate: String
    let couponExpiredDate: String
    let couponIsUsed: Bool
}

struct ShowCoupon {
    var title: String
    var expiredDate: String
    var image: UIImage
    var type: String?
    var isUsed: Bool?
}

enum CouponStatus: CaseIterable {
    case canUse
    case used
    case expired
}

protocol CouponDataProvider {
    func fetchCoupons(type: CouponStatus) -> [ShowCoupon]
}

class CouponAPI: CouponDataProvider {
    func fetchCoupons(type: CouponStatus) -> [ShowCoupon] {
        var coupons: [ShowCoupon] = []
        for couponIndex in 1...5 {
            let coupon = ShowCoupon(
                title: "\(type) Coupon \(couponIndex)",
                expiredDate: "ExpiredDate for \(type) Coupon \(couponIndex)",
                image: UIImage(named: "Image_Placeholder")!
            )
            coupons.append(coupon)
        }
        return coupons
    }
}

class MyCouponViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    let couponAPI = CouponAPI()
    
    var tabButton: [UIButton] = []
    var selectedTabButton = 0
    private var coupons = [ShowCoupon]()
    
    private var containerView: UIView!
    private var indicatorView: UIView!
    
    var collectionView: UICollectionView!
    var tableView1: UITableView!
    var tableView2: UITableView!
    var tableView3: UITableView!
    
    let collectionCellIdentifier = "CollectionCell"
    let tableCellIdentifier = "TableCell"
    
    var indicatorViewLeadingConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "我的優惠券"
        
        setupUI()
        tabBarController?.tabBar.backgroundColor = .white
        coupons = couponAPI.fetchCoupons(type: .canUse)
        createAllTableViews()
        tableView1.isHidden = false
        tableView1.reloadData()
    }
    
    private func setupUI() {
        createTabButtons()
        createIndicatorView()
        createCollectionView()
        createAllTableViews()
    }
    private func createAllTableViews() {
        tableView1 = UITableView()
        tableView2 = UITableView()
        tableView3 = UITableView()
        createTableView(tableView: tableView1)
        createTableView(tableView: tableView2)
        createTableView(tableView: tableView3)
    }
    
    private func createTabButtons() {
        let tabTitles = ["可使用", "已使用", "已失效"]
        
        for (index, title) in tabTitles.enumerated() {
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            button.tag = index
            tabButton.append(button)
        }
        
        let stackView = UIStackView(arrangedSubviews: tabButton)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func createIndicatorView() {
        indicatorView = UIView()
        indicatorView.backgroundColor = .black
        view.addSubview(indicatorView)
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorViewLeadingConstraint = indicatorView.leadingAnchor.constraint(equalTo: tabButton[0].leadingAnchor)
        indicatorViewLeadingConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 140),
            indicatorView.heightAnchor.constraint(equalToConstant: 2),
            indicatorView.widthAnchor.constraint(equalTo: tabButton[0].widthAnchor)
        ])
    }
    
    private func createCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func createTableView(tableView: UITableView) {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: tableCellIdentifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //switching between tableviews
    @objc private func tabButtonTapped(_ sender: UIButton) {
        selectedTabButton = sender.tag
        selectTabButton()
        
        switch selectedTabButton {
        case 0:
            coupons = couponAPI.fetchCoupons(type: .canUse)
        case 1:
            coupons = couponAPI.fetchCoupons(type: .used)
        case 2:
            coupons = couponAPI.fetchCoupons(type: .expired)
        default:
            break
        }
        
        if selectedTabButton == 0 {
            tableView1.reloadData()
        } else if selectedTabButton == 1 {
            tableView2.reloadData()
        } else if selectedTabButton == 2 {
            tableView3.reloadData()
        }
        
        tableView1.isHidden = selectedTabButton != 0
        tableView2.isHidden = selectedTabButton != 1
        tableView3.isHidden = selectedTabButton != 2
    }
    
    private func selectTabButton() {
        for (index, button) in tabButton.enumerated() {
            button.setTitleColor(index == selectedTabButton ? .black : .gray, for: .normal)
        }
        
        indicatorViewLeadingConstraint?.isActive = false
        indicatorViewLeadingConstraint = indicatorView.leadingAnchor.constraint(equalTo: tabButton[selectedTabButton].leadingAnchor)
        indicatorViewLeadingConstraint?.isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: UICollectionViewDataSource and UICollectionViewDelegate methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as? CollectionViewCell
        
        return cell ?? UICollectionViewCell()
    }
    
    // MARK: UITableViewDataSource and UITableViewDelegate methods for table views
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coupons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath) as? TableViewCell
        let coupon = coupons[indexPath.row]
        cell?.coupon = coupon
        
        if selectedTabButton == 1 || selectedTabButton == 2 {
            let passView = UIView()
            passView.backgroundColor = .white
            passView.alpha = 0.1
            passView.contentMode = .scaleAspectFill
            passView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            cell?.couponImage?.addSubview(passView)
            cell?.couponTitle?.alpha = 0.5
            cell?.couponDesc?.alpha = 0.5
        } else {
            cell?.couponImage?.alpha = 1
            cell?.couponTitle?.alpha = 1
            cell?.couponDesc?.alpha = 1
        }
        
        return cell ?? UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}

// Entry point
let couponVC = MyCouponViewController()
let navigationController = UINavigationController(rootViewController: couponVC)
