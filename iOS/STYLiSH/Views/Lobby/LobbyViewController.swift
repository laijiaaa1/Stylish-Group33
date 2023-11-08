//
//  LobbyViewController.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/2/13.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit
import Hover
import DropDown

class LobbyViewController: STBaseViewController {


    @IBOutlet weak var lobbyView: LobbyView! {
        didSet {
            lobbyView.delegate = self
        }
    }

    private var datas: [PromotedProducts] = [] {
        didSet {
            lobbyView.reloadData()
        }
    }

    private let marketProvider = MarketProvider(httpClient: HTTPClient())

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = UIImageView(image: .asset(.Image_Logo02))
        
        lobbyView.beginHeaderRefresh()
        
        let searchButton = UIButton()
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.tintColor = .black
        searchButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        searchButton.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)

        let configuration = HoverConfiguration(image: UIImage(named: "add"), color: .gradient(top: .blue, bottom: .cyan))

        let items = [
            HoverItem(title: "Log out", image: UIImage(named: "logout")) {
                if KeyChainManager.shared.token != nil {
                    let alertController = UIAlertController(title: "確定要登出嗎？", message: nil, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                    let logoutAction = UIAlertAction(title: "登出", style: .destructive) { _ in
                        self.logout()
                    }
                    alertController.addAction(cancelAction)
                    alertController.addAction(logoutAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            },
            HoverItem(title: "Coupon", image: UIImage(named: "getCoupon")) {
            
                /// Push Native Login
                if KeyChainManager.shared.token == nil {
                    let logInVC = LogInViewController()
                    logInVC.isModalInPresentation = true
                    
                    if #available(iOS 16.0, *) {
                        if let sheetPresentationController = logInVC.sheetPresentationController {
                            sheetPresentationController.preferredCornerRadius = 16
                            sheetPresentationController.detents = [.custom(resolver: { _ in
                                350
                            })]
                        }
                        self.present(logInVC, animated: true, completion: nil)
                    }
                    return
                } else {
                    let acquireCouponViewController = AcquireCouponViewController()
                    self.navigationController?.pushViewController(acquireCouponViewController, animated: true)
                }
            },
            HoverItem(title: "Collection", image: UIImage(named: "heart_fill")) {
                if KeyChainManager.shared.token == nil {
                    let logInVC = LogInViewController()
                    logInVC.isModalInPresentation = true
                    
                    if #available(iOS 16.0, *) {
                        if let sheetPresentationController = logInVC.sheetPresentationController {
                            sheetPresentationController.preferredCornerRadius = 16
                            sheetPresentationController.detents = [.custom(resolver: { _ in
                                350
                            })]
                        }
                        self.present(logInVC, animated: true, completion: nil)
                    }
                    return
                }else{
                    let collectionViewController = CollectionViewController()
                    self.navigationController?.pushViewController(collectionViewController, animated: true)
                }
            }
        ]

        // Create an HoverView with the previous configuration & items
        let hoverView = HoverView(with: configuration, items: items)

        // Add to the top of the view hierarchy
        view.addSubview(hoverView)
        hoverView.translatesAutoresizingMaskIntoConstraints = false

        // Apply Constraints
        // Never constrain to the safe area as Hover takes care of that
        NSLayoutConstraint.activate(
            [
                hoverView.topAnchor.constraint(equalTo: view.topAnchor),
                hoverView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                hoverView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hoverView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ]
        )
    }
    @objc func searchButtonPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let searchVC = storyboard.instantiateViewController(withIdentifier: "searchViewController") as? SearchViewController {
            navigationController?.pushViewController(searchVC, animated: true)
        }
    }


    func logout() {
        KeyChainManager.shared.token = nil
        
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            let loginViewController = LogInViewController()
            UIApplication.shared.windows.first?.rootViewController = loginViewController
        }
    }

    // MARK: - Action
    private func fetchData() {
        marketProvider.fetchHots(completion: { [weak self] result in
            switch result {
            case .success(let products):
                self?.datas = products
            case .failure:
                LKProgressHUD.showFailure(text: "讀取資料失敗！")
            }
        })
    }
}

extension LobbyViewController: LobbyViewDelegate {
    
    func triggerRefresh(_ lobbyView: LobbyView) {
        fetchData()
    }

    // MARK: - UITableViewDataSource and UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: LobbyTableViewCell.self),
            for: indexPath
        )
        guard let lobbyCell = cell as? LobbyTableViewCell else { return cell }
        let product = datas[indexPath.section].products[indexPath.row]
        if indexPath.row % 2 == 0 {
            lobbyCell.singlePage(
                img: product.mainImage,
                title: product.title,
                description: product.description
            )
        } else {
            lobbyCell.multiplePages(
                imgs: product.images,
                title: product.title,
                description: product.description
            )
        }
        return lobbyCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 67.0 }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 258.0 }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 0.01 }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: String(describing: LobbyTableViewHeaderView.self)
            ) as? LobbyTableViewHeaderView else {
                return nil
        }
        headerView.titleLabel.text = datas[section].title
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let detailVC = UIStoryboard.product.instantiateViewController(
                withIdentifier: String(describing: ProductDetailViewController.self)
            ) as? ProductDetailViewController
        else {
            return
        }
        detailVC.product = datas[indexPath.section].products[indexPath.row]
        show(detailVC, sender: nil)
    }
}
