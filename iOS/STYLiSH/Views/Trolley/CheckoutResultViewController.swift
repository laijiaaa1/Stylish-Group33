//
//  CheckoutResultViewController.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/7/31.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit

class CheckoutResultViewController: STBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    override func backToRoot(_ sender: Any) {
        backToRoot(completion: {
            let appdelegate = UIApplication.shared.delegate as? AppDelegate
            let root = appdelegate?.window?.rootViewController as? STTabBarViewController
            root?.selectedIndex = 0
        })
    }
}

//L-checkoutError/ErrorCheckoutResultViewController: Error page
class ErrorCheckoutResultViewController: CheckoutResultViewController {
    
}
