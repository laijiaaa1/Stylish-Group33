//
//  ProductDetailViewController.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/3/2.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit

class ProductDetailViewController: STBaseViewController {
    
    private let collectionProvider = CollectionProvider.shared
    private struct Segue {
        static let picker = "SeguePicker"
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
        }
    }

    @IBOutlet weak var galleryView: LKGalleryView! {
        didSet {
            galleryView.frame.size.height = CGFloat(Int(UIScreen.width / 375.0 * 500.0))
            galleryView.delegate = self
        }
    }

    @IBOutlet weak var productPickerView: UIView!

    @IBOutlet weak var addToCarBtn: UIButton!
    
    @IBOutlet weak var baseView: UIView!

    private lazy var blurView: UIView = {
        let blurView = UIView(frame: tableView.frame)
        blurView.backgroundColor = .black.withAlphaComponent(0.4)
        return blurView
    }()
    private let collectionButton: UIButton = {
        let collectionButton = UIButton()
        collectionButton.setImage(UIImage(named: "heart_hollow"), for: .normal)
        collectionButton.setImage(UIImage(named: "heart_fill"), for: .selected)
        collectionButton.frame = CGRect(x: 350, y: 585, width: 25, height: 25)
        return collectionButton
    }()
    private let datas: [ProductContentCategory] = [
        .description, .color, .size, .stock, .texture, .washing, .placeOfProduction, .remarks
    ]

    var product: Product? {
        didSet {
            guard let product = product, let galleryView = galleryView else { return }
            galleryView.datas = product.images
        }
    }
    var isCollected: Bool?
    private var pickerViewController: ProductPickerController?

    override var isHideNavigationBar: Bool { return true }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setUpCollectionButton()
        guard let product = product else { return }
        guard let galleryView = galleryView else { return }
        galleryView.datas = product.images
    }
    private func setUpCollectionButton() {
        guard let product = product else { return }
        collectionButton.addTarget(self, action: #selector(collectionButtonTapped), for: .touchUpInside)
        let selectedState = UserDefaults.standard.bool(forKey: "\(product.id)")
        collectionButton.isSelected = selectedState
    }
    private func setupTableView() {
        
        guard let tableView = tableView else {
                return
            }
        
        tableView.addSubview(collectionButton)
        tableView.lk_registerCellWithNib(
            identifier: String(describing: ProductDescriptionTableViewCell.self),
            bundle: nil
        )
        tableView.lk_registerCellWithNib(
            identifier: ProductDetailCell.color,
            bundle: nil
        )
        tableView.lk_registerCellWithNib(
            identifier: ProductDetailCell.label,
            bundle: nil
        )
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.picker,
           let pickerVC = segue.destination as? ProductPickerController {
            pickerVC.delegate = self
            pickerVC.product = product
            pickerViewController = pickerVC
        }
    }
    // MARK: - Methods
    private func addCollection(with productId: Int, completion: @escaping (Bool) -> Void) {
        collectionProvider.addCollectionProducts(productId: productId, completion: { [weak self] result in
            switch result {
            case .success(let response):
                if response.success == true {
                    LKProgressHUD.showSuccess(text: "\(response.message)")
                    completion(true)
                } else {
                    LKProgressHUD.showFailure(text: "\(response.message)")
                    completion(false)
                }
                
            case .failure(let error):
                if let error = error as? STYLiSHSignInError {
                    LKProgressHUD.showFailure(text: "\(error.rawValue)")
                } else {
                    LKProgressHUD.showFailure(text: "無法收藏商品")
                }
                completion(false)
            }
        })
    }
    private func removeCollection(with productId: Int, completion: @escaping (Bool) -> Void) {
        collectionProvider.removeCollectionProducts(productId: productId, completion: { [weak self] result in
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
                LKProgressHUD.showFailure(text: "無法移除收藏")
                completion(true)
            }
        })
    }
    @objc func collectionButtonTapped(sender: UIButton) {
        guard let product = product else { return }
        if collectionButton.isSelected == false {
            addCollection(with: product.id) { result in
                UserDefaults.standard.set(result, forKey: "\(String(describing: product.id))")
                DispatchQueue.main.async {
                    self.collectionButton.isSelected = result
                }
            }
        } else {
            removeCollection(with: product.id) { result in
                UserDefaults.standard.set(result, forKey: "\(String(describing: product.id))")
                DispatchQueue.main.async {
                    self.collectionButton.isSelected = result
                }
            }
        }
    }
    @IBAction func didTouchAddToCarBtn(_ sender: UIButton) {
        if productPickerView.superview == nil {
            showProductPickerView()
        } else {
            guard
                let color = pickerViewController?.selectedColor,
                let size = pickerViewController?.selectedSize,
                let amount = pickerViewController?.selectedAmount,
                let product = product
            else {
                return
            }
            StorageManager.shared.saveOrder(
                color: color, size: size, amount: amount, product: product,
                completion: { result in
                    switch result {
                    case .success:
                        LKProgressHUD.showSuccess()
                        dismissPicker(pickerViewController!)
                    case .failure:
                        LKProgressHUD.showFailure(text: "儲存失敗！")
                    }
                }
            )
        }
    }

    func showProductPickerView() {
        let maxY = tableView.frame.maxY
        productPickerView.frame = CGRect(
            x: 0, y: maxY, width: UIScreen.width, height: 0.0
        )
        baseView.insertSubview(productPickerView, belowSubview: addToCarBtn.superview!)
        baseView.insertSubview(blurView, belowSubview: productPickerView)

        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                guard let self = self else { return }
                let height = 451.0 / 586.0 * self.tableView.frame.height
                self.productPickerView.frame = CGRect(
                    x: 0, y: maxY - height, width: UIScreen.width, height: height
                )
                self.isEnableAddToCarBtn(false)
            }
        )
    }

    func isEnableAddToCarBtn(_ flag: Bool) {
        if flag {
            addToCarBtn.isEnabled = true
            addToCarBtn.backgroundColor = .B1
        } else {
            addToCarBtn.isEnabled = false
            addToCarBtn.backgroundColor = .B4
        }
    }
}

// MARK: - UITableViewDataSource
extension ProductDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard product != nil else { return 0 }
        return datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let product = product else { return UITableViewCell() }
        return datas[indexPath.row].cellForIndexPath(indexPath, tableView: tableView, data: product)
    }
}

extension ProductDetailViewController: LKGalleryViewDelegate {

    func sizeForItem(_ galleryView: LKGalleryView) -> CGSize {
        return CGSize(width: Int(UIScreen.width), height: Int(UIScreen.width / 375.0 * 500.0))
    }
}

extension ProductDetailViewController: ProductPickerControllerDelegate {

    func dismissPicker(_ controller: ProductPickerController) {
        let origin = productPickerView.frame
        let nextFrame = CGRect(x: origin.minX, y: origin.maxY, width: origin.width, height: origin.height)

        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.productPickerView.frame = nextFrame
                self?.blurView.removeFromSuperview()
                self?.isEnableAddToCarBtn(true)
            },
            completion: { [weak self] _ in
                self?.productPickerView.removeFromSuperview()
            }
        )
    }

    func valueChange(_ controller: ProductPickerController) {
        guard
            controller.selectedColor != nil,
            controller.selectedSize != nil,
            controller.selectedAmount != nil
        else {
            isEnableAddToCarBtn(false)
            return
        }
        isEnableAddToCarBtn(true)
    }
}
