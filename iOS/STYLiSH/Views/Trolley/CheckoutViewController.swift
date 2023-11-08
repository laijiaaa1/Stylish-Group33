//
//  TestViewController.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/7/26.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit

class CheckoutViewController: STBaseViewController, UseCouponDelegate {
    var oldOder: Order?
    var newOrder: Order?
    var currentPrice: Int = 0
    
    var selectedCoupon: CouponObject?
    var stPaymentInfoTableViewCell: STPaymentInfoTableViewCell?
    
    // MARK: - UseCouponViewController Delegate
    func didSelectCoupon(_ coupon: CouponObject?) {
        selectedCoupon = coupon
        if let selectedCoupon = selectedCoupon {
            stPaymentInfoTableViewCell?.couponLabel.text = selectedCoupon.title
        } else {
            stPaymentInfoTableViewCell?.couponLabel.text = "未使用"
        }
        updatePrice()
    }
    private func updatePrice() {
        if let selectedCoupon = selectedCoupon {
          
            print(selectedCoupon)
            switch selectedCoupon.type {
            case CouponType.deliveryActive.type:
                newOrder?.freight = 0
                newOrder?.products = (oldOder?.products)!
                
            case CouponType.discountActive.type:
                newOrder?.freight = 60
                let beforeDiscount = (oldOder?.products)!
                let discount = (100 - Float(selectedCoupon.discount!)) / 100
                let discountProducts = beforeDiscount.map { item in
                    print("before: \(item.product!.price)")
                    let newPrice = Float(item.product!.price) * discount
                    print("newprice: \(newPrice)")
                    item.product!.price = Int64(newPrice)
                    print("after: \(item.product!.price)")
                    return item
                }
                print(discountProducts[0].product?.price)
               // self.newOrder?.products = discountProducts
            default: break
            }
        } else {
        }
            tableView.reloadData()
        print("orderprovider: \(orderProvider.order.products[0].product!.price)")
        print("newOrder: \(newOrder!.products[0].product!.price)")
        print("oldOrder: \(oldOder!.products[0].product!.price)")
    }
    private struct Segue {
        static let success = "SegueSuccess"
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var orderProvider: OrderProvider! {
        didSet {
            guard orderProvider != nil else {
                tableView.dataSource = nil
                tableView.delegate = nil
                return
            }
            setupTableView()
        }
    }
    
    private lazy var tappayVC: STTapPayViewController = {
        guard
            let tappayVC = UIStoryboard.trolley.instantiateViewController(
                withIdentifier: STTapPayViewController.identifier
            ) as? STTapPayViewController
        else {
            fatalError()
        }
        addChild(tappayVC)
        tappayVC.loadViewIfNeeded()
        tappayVC.didMove(toParent: self)
        tappayVC.cardStatusHandler = { [weak self] flag in
            self?.isCanGetPrime = flag
        }
        return tappayVC
    }()
    
    private var isCanGetPrime: Bool = false {
        didSet {
            updateCheckoutButton()
        }
    }
    
    private let userProvider = UserProvider(httpClient: HTTPClient())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stPaymentInfoTableViewCell?.delegate = self
        
        for orderProduct in orderProvider.order.products {
            if let product = orderProduct.product {
                
                currentPrice += Int(product.price) * Int(orderProduct.amount)
            }
        }
    }
    
    private func setupTableView() {
        guard orderProvider != nil else { return }
        loadViewIfNeeded()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.lk_registerCellWithNib(identifier: STOrderProductCell.identifier, bundle: nil)
        tableView.lk_registerCellWithNib(identifier: STOrderUserInputCell.identifier, bundle: nil)
        tableView.lk_registerCellWithNib(identifier: STPaymentInfoTableViewCell.identifier, bundle: nil)
        
        let headerXib = UINib(nibName: STOrderHeaderView.identifier, bundle: nil)
        tableView.register(headerXib, forHeaderFooterViewReuseIdentifier: STOrderHeaderView.identifier)
    }
    
    // MARK: - Action
    func checkout(_ cell: STPaymentInfoTableViewCell) {
        guard canCheckout() else { return }
        
        guard KeyChainManager.shared.token != nil else {
            return onShowLogin()
        }
        self.performSegue(withIdentifier: Segue.success, sender: nil)
        StorageManager.shared.deleteAllProduct(completion: { _ in })
//
//        if let selectedCoupon = selectedCoupon {
//            switch orderProvider.order.payment {
//            case .credit: checkoutWithTapPay(with: selectedCoupon.id)
//            case .cash: checkoutWithCash(with: selectedCoupon.id)
//            }
//        } else {
//            switch orderProvider.order.payment {
//            case .credit: checkoutWithTapPay()
//            case .cash: checkoutWithCash()
//            }
//        }
    }
    
    private func onShowLogin() {
        let logInVC = LogInViewController()
        logInVC.isModalInPresentation = true
        
        if #available(iOS 16.0, *) {
            if let sheetPresentationController = logInVC.sheetPresentationController {
                sheetPresentationController.preferredCornerRadius = 16
                sheetPresentationController.detents = [.custom(resolver: { _ in
                    350
                })]
            }
            present(logInVC, animated: true, completion: nil)
        }
    }
    
    private func checkoutWithCash(with couponId: Int? = nil) {
        self.userProvider.checkout(
            order: self.newOrder!,
            prime: "",
            couponId: couponId,
            completion: { result in
                LKProgressHUD.dismiss()
                switch result {
                case .success(let reciept):
                    print(reciept)
                    self.performSegue(withIdentifier: Segue.success, sender: nil)
                    StorageManager.shared.deleteAllProduct(completion: { _ in })
                case .failure(let error):
                    // Error Handle
                    self.handleCheckoutFailure()
                    print(error)
                }
            })
    }
    
    private func checkoutWithTapPay(with couponId: Int? = nil) {
        LKProgressHUD.show()
        tappayVC.getPrime(completion: { [weak self] result in
            switch result {
            case .success(let prime):
                guard let self = self else { return }
                self.userProvider.checkout(
                    order: (self.newOrder)!,
                    prime: prime,
                    couponId: couponId,
                    completion: { result in
                        LKProgressHUD.dismiss()
                        switch result {
                        case .success(let reciept):
                            print(reciept)
                            self.performSegue(withIdentifier: Segue.success, sender: nil)
                            StorageManager.shared.deleteAllProduct(completion: { _ in })
                        case .failure(let error):
                            // Error Handle
                            self.handleCheckoutFailure()
                            print(error)
                        }
                    })
            case .failure(let error):
                LKProgressHUD.dismiss()
                // Error Handle
                self?.handleCheckoutFailure()
                print(error)
            }
        })
    }
    private func handleCheckoutFailure() {
        DispatchQueue.main.async {
            let errorVC = ErrorCheckoutResultViewController()
            errorVC.modalPresentationStyle = .overCurrentContext
            self.present(errorVC, animated: false, completion: nil)
        }
    }
    func canCheckout() -> Bool {
        switch orderProvider.order.payment {
        case .cash: return orderProvider.order.isReady()
        case .credit: return orderProvider.order.isReady() && isCanGetPrime
        }
    }
}

extension CheckoutViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Section Count
    func numberOfSections(in tableView: UITableView) -> Int {
        return orderProvider.orderCustructor.count
    }
    
    // MARK: - Section Header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 67.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: STOrderHeaderView.identifier
            ) as? STOrderHeaderView
        else {
            return nil
        }
        headerView.titleLabel.text = orderProvider.orderCustructor[section].title()
        return headerView
    }
    
    // MARK: - Section Footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return .empty
    }
    
    // MARK: - Section Row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch orderProvider.orderCustructor[section] {
        case .products: return orderProvider.order.products.count
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch orderProvider.orderCustructor[indexPath.section] {
        case .products:
            return mappingCellWtih(order: orderProvider.order, at: indexPath)
        case .paymentInfo:
            return mappingCellWtih(payment: "", at: indexPath)
        case .reciever:
            return mappingCellWtih(reciever: orderProvider.order.reciever, at: indexPath)
        }
    }
    
    // MARK: - Layout Cell
    private func mappingCellWtih(order: Order, at indexPath: IndexPath) -> UITableViewCell {
        guard
            let orderCell = tableView.dequeueReusableCell(
                withIdentifier: STOrderProductCell.identifier,
                for: indexPath
            ) as? STOrderProductCell
        else {
            return UITableViewCell()
        }
        let order = orderProvider.order.products[indexPath.row]
        orderCell.layoutCell(data: STOrderProductCellModel(order: order))
        return orderCell
    }
    
    private func mappingCellWtih(reciever: Reciever, at indexPath: IndexPath) -> UITableViewCell {
        guard
            let inputCell = tableView.dequeueReusableCell(
                withIdentifier: STOrderUserInputCell.identifier,
                for: indexPath
            ) as? STOrderUserInputCell
        else {
            return UITableViewCell()
        }
        inputCell.layoutCell(
            name: reciever.name,
            email: reciever.email,
            phone: reciever.phoneNumber,
            address: reciever.address
        )
        inputCell.delegate = self
        return inputCell
    }
    
    private func mappingCellWtih(payment: String, at indexPath: IndexPath) -> UITableViewCell {
        guard
            let inputCell = tableView.dequeueReusableCell(
                withIdentifier: STPaymentInfoTableViewCell.identifier,
                for: indexPath
            ) as? STPaymentInfoTableViewCell
        else {
            return UITableViewCell()
        }
       
        stPaymentInfoTableViewCell = inputCell
        guard let newOrder = newOrder else { return UITableViewCell() }
            inputCell.creditView.stickSubView(tappayVC.view)
            inputCell.delegate = self
            inputCell.layoutCellWith(
                productPrice: orderProvider.order.productPrices,
                shipPrice: orderProvider.order.freight,
                productCount: orderProvider.order.amount,
                payment: orderProvider.order.payment.title(),
                isCheckoutEnable: canCheckout()
            )
            inputCell.checkoutBtn.isEnabled = canCheckout()
            return inputCell
    }
    
    func updateCheckoutButton() {
        guard
            let index = orderProvider.orderCustructor.firstIndex(of: .paymentInfo),
            let cell = tableView.cellForRow(
                at: IndexPath(row: 0, section: index)
            ) as? STPaymentInfoTableViewCell
        else {
            return
        }
        cell.updateCheckouttButton(isEnable: canCheckout())
    }
}

extension CheckoutViewController: STPaymentInfoTableViewCellDelegate {
    
    func goUseCoupon(_ cell: STPaymentInfoTableViewCell) {
        let useCouponVC = UseCouponViewController()
        useCouponVC.delegate = self
        if let selectedCoupon = selectedCoupon {
            useCouponVC.selectedCoupon = selectedCoupon
        }
        navigationController?.pushViewController(useCouponVC, animated: true)
    }
    
    func endEditing(_ cell: STPaymentInfoTableViewCell) {
        tableView.reloadData()
    }
    
    func didChangePaymentMethod(_ cell: STPaymentInfoTableViewCell, index: Int) {
        orderProvider.order.payment = orderProvider.payments[index]
        updateCheckoutButton()
    }
    
    func textsForPickerView(_ cell: STPaymentInfoTableViewCell) -> [String] {
        return orderProvider.payments.map { $0.title() }
    }
    
    func isHidden(_ cell: STPaymentInfoTableViewCell, at index: Int) -> Bool {
        switch orderProvider.payments[index] {
        case .cash: return true
        case .credit: return false
        }
    }
    
    func heightForConstraint(_ cell: STPaymentInfoTableViewCell, at index: Int) -> CGFloat {
        switch orderProvider.payments[index] {
        case .cash: return 44
        case .credit: return 118
        }
    }
}

extension CheckoutViewController: STOrderUserInputCellDelegate {
    
    func didChangeUserData(_ cell: STOrderUserInputCell, data: STOrderUserInputCellModel) {
        let newReciever = Reciever(
            name: data.username,
            email: data.email,
            phoneNumber: data.phoneNumber,
            address: data.address,
            shipTime: data.shipTime
        )
        orderProvider.order.reciever = newReciever
        updateCheckoutButton()
    }
}
