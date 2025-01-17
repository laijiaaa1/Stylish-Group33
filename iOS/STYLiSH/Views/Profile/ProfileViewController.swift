//
//  ProfileViewController.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/2/14.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit
import Hover


class ProfileViewController: UIViewController {

    @IBOutlet weak var imageProfile: UIImageView!
    
    @IBOutlet weak var labelName: UILabel!
    
    @IBOutlet weak var labelInfo: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }

    private let manager = ProfileManager()
    
    private let userProvider = UserProvider(httpClient: HTTPClient())
    
    private var user: UserProfile? {
        didSet {
            if let user = user {
                updateUser(user)
            }
        }
    }
    let getCouponButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
      
        getCouponButton.setImage(UIImage(named: "getCoupon"), for: .normal)

        view.addSubview(getCouponButton)
        getCouponButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            getCouponButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200),
            getCouponButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            getCouponButton.heightAnchor.constraint(equalToConstant: 80),
            getCouponButton.widthAnchor.constraint(equalToConstant: 80)
        ])

        getCouponButton.addTarget(self, action: #selector(getCouponButtonTapped), for: .touchUpInside)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
           getCouponButton.addGestureRecognizer(panGesture)
        
        tabBarController?.tabBar.isHidden = false
    
    }
   
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let getCouponButton = gesture.view as? UIButton else { return }

        let minX = getCouponButton.bounds.midX
        let maxX = view.bounds.maxX - getCouponButton.bounds.midX
        let minY = view.safeAreaInsets.top + getCouponButton.bounds.midY
        let maxY = view.bounds.maxY - getCouponButton.bounds.midY - view.safeAreaInsets.bottom

        switch gesture.state {
        case .began, .changed:
            let translation = gesture.translation(in: view)
            var newCenter = CGPoint(x: getCouponButton.center.x + translation.x, y: getCouponButton.center.y + translation.y)

            newCenter.x = min(maxX, max(minX, newCenter.x))
            newCenter.y = min(maxY, max(minY, newCenter.y))

            getCouponButton.center = newCenter
            gesture.setTranslation(.zero, in: view)

        case .ended:
            UIView.animate(withDuration: 0.5,
                           delay: 0.5,
                           usingSpringWithDamping: 0.4,
                           initialSpringVelocity: 0.3,
                           options: .curveEaseOut,
                           animations: {
                               var newCenter = getCouponButton.center
                               newCenter.x = min(maxX, max(minX, newCenter.x))
                               newCenter.y = min(maxY, max(minY, newCenter.y))
                               getCouponButton.center = newCenter
                           },
                           completion: nil)
        default:
            break
        }
    }


    @objc func getCouponButtonTapped() {

        let acquireCouponVC = AcquireCouponViewController()
        navigationController?.pushViewController(acquireCouponVC, animated: true)
    }

    // MARK: - Action
    private func fetchData() {
        userProvider.getUserProfile(completion: { [weak self] result in
            switch result {
            case .success(let user):
                self?.user = user
            case .failure:
                LKProgressHUD.showFailure(text: "讀取資料失敗！")
            }
        })
    }
    
    private func updateUser(_ user: UserProfile) {
        print(user.picture)
        imageProfile.loadImage(user.picture, placeHolder: .asset(.Icons_36px_Profile_Normal))
        labelName.text = user.name
        labelInfo.text = user.getUserInfo(userProfile: user)
        labelInfo.isHidden = false
    }
}

extension ProfileViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return manager.groups.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return manager.groups[section].items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ProfileCollectionViewCell.self),
            for: indexPath
        )
        guard let profileCell = cell as? ProfileCollectionViewCell else { return cell }
        let item = manager.groups[indexPath.section].items[indexPath.row]
        profileCell.layoutCell(image: item.image, text: item.title)
        return profileCell
    }
    // L-coupon/MyCouponViewController: push to coupon page
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let collectionVC = CollectionViewController()
            collectionVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(collectionVC, animated: true)
        } else if indexPath.section == 1 && indexPath.row == 1{
            let couponVC = MyCouponViewController()
            navigationController?.pushViewController(couponVC, animated: true)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: String(describing: ProfileCollectionReusableView.self),
                for: indexPath
            )
            guard let profileView = header as? ProfileCollectionReusableView else { return header }
            let group = manager.groups[indexPath.section]
            profileView.layoutView(title: group.title, actionText: group.action?.title)
            return profileView
        }
        return UICollectionReusableView()
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: UIScreen.width / 5.0, height: 60.0)
        } else if indexPath.section == 1 {
            return CGSize(width: UIScreen.width / 4.0, height: 60.0)
        }
        return CGSize.zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24.0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 24.0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: UIScreen.width, height: 48.0)
    }
}
