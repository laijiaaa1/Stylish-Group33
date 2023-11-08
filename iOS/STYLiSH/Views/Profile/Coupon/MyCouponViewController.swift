//
//  MyCouponViewController.swift
//
//
//  Created by laijiaaa1 on 2023/11/4.
//
import UIKit

enum CouponStatus: String, CaseIterable {
    case valid = "可使用"
    case invalid = "已失效"
}
protocol CouponDataProvider {
    func fetchCoupons(type: CouponStatus) -> [CouponObject]
}

class MyCouponViewController: STTableViewController {
    private let couponProvider = CouponProvider.shared
   
    var tabButton: [UIButton] = []
    var selectedTabButton = 0

    // MARK: - Subviews
    var indicatorViewLeadingConstraint: NSLayoutConstraint?
    let getCouponButton = UIButton()
    let topView = UIView()
    let indicatorView = UIView()
    let containerView = UIView()
    let seperatorView = UIView()
    let addButton: UIButton = {
        let addButton = UIButton()
        addButton.setTitle("領取優惠券 >", for: .normal)
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let attributedString = NSAttributedString(string: "領取優惠券 >", attributes: attributes)
        addButton.setAttributedTitle(attributedString, for: .normal)
        addButton.setTitleColor(.B1, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return addButton
    }()
    // MARK: - View Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        datas = [[]]
        datas2 = [[]]
        createTabButtons()
        setUpSubviews()
        
        
        tableView2 = UITableView()
        createTableView(tableView: tableView)
        createTableView(tableView: tableView2!)
        tableView.isHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationItem.title = "我的優惠券"
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
   
    private func createTabButtons() {
        let tabTitles = [CouponStatus.valid.rawValue, CouponStatus.invalid.rawValue]
        for (index, title) in tabTitles.enumerated() {
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(.B1, for: .normal)
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
    private func setUpSubviews() {
        topView.backgroundColor = .white
        indicatorView.backgroundColor = .B1
        seperatorView.backgroundColor = .G1
        addButton.addTarget(self, action: #selector(getCouponButtonTappedFromMyCoupon), for: .touchUpInside)
    
        topView.addSubview(seperatorView)
        topView.addSubview(addButton)
        topView.addSubview(indicatorView)
        view.addSubview(topView)
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        indicatorViewLeadingConstraint = indicatorView.leadingAnchor.constraint(equalTo: tabButton[0].leadingAnchor)
        indicatorViewLeadingConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: indicatorView.bottomAnchor),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 40),
            
            indicatorView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            indicatorView.heightAnchor.constraint(equalToConstant: 1),
            indicatorView.widthAnchor.constraint(equalTo: tabButton[0].widthAnchor),
            
            addButton.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 30),
            addButton.widthAnchor.constraint(equalToConstant: 100),
            seperatorView.bottomAnchor.constraint(equalTo: topView.bottomAnchor),
            seperatorView.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
            seperatorView.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
            seperatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    private func createTableView(tableView: UITableView) {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CouponViewCell.self, forCellReuseIdentifier: CouponViewCell.cellIdentifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.isHidden = true
        tableView.separatorStyle = .none
        tableView.backgroundColor = .C1
    }
    // MARK: - MJRefresher Methods
    override func headerLoader() {
        resetNoMoreData()
        if selectedTabButton == 0 {
            datas = [[]]
            couponProvider.fetchValidCoupons(completion: { [weak self] result in
                self?.endHeaderRefreshing()
                switch result {
                case .success(let response):
                    self?.datas = [response.data]
                case .failure(let error):
                    LKProgressHUD.showFailure(text: error.localizedDescription)
                }
            })
        } else {
            datas2 = [[]]
            couponProvider.fetchInvalidCoupons(completion: { [weak self] result in
                self?.endHeaderRefreshing()
                switch result {
                case .success(let response):
                    self?.datas2 = [response.data]
                case .failure(let error):
                    LKProgressHUD.showFailure(text: error.localizedDescription)
                }
            })
        }
    }
 
    // MARK: - Methods
    @objc func getCouponButtonTappedFromMyCoupon() {
        let getCouponVC = AcquireCouponViewController()
        navigationController?.pushViewController(getCouponVC, animated: true)
    }
    @objc private func tabButtonTapped(_ sender: UIButton) {
        selectedTabButton = sender.tag
        headerLoader()
        selectTabButton()
      
        tableView.isHidden = selectedTabButton != 0
        tableView2!.isHidden = selectedTabButton != 1
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
 
    // MARK: -    // MARK: UITableViewDataSource and UITableViewDelegate methods for table views
    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == tableView {
            return datas.count
        } else {
            return datas2.count
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableView {
            return datas[0].count
        } else {
            return datas2[0].count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CouponViewCell.cellIdentifier,
            for: indexPath) as? CouponViewCell else { fatalError("Cannot create cell") }
        
        switch tableView {
        case tableView:
            guard let coupon = datas[indexPath.section][indexPath.row] as? CouponObject else { return cell }
            cell.coupon = coupon
            return cell
        default:
            guard let coupon = datas2[indexPath.section][indexPath.row] as? CouponObject else { return cell }
            cell.coupon = coupon
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
  
}
