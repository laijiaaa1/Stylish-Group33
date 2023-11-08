//
//  STTableViewController
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/3/2.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import UIKit

class STTableViewController: STBaseViewController,
    UITableViewDataSource,
    UITableViewDelegate{

    var tableView: UITableView!
    var tableView2: UITableView?
    var datas: [[Any]] = [[]] {
        didSet {
            reloadData()
        }
    }
    var datas2: [[Any]] = [[]] {
        didSet {
            reloadData()
        }
    }

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cpdSetupTableView()
        tableView.beginHeaderRefreshing()
    }

    // MARK: - Private Method
    private func cpdSetupTableView() {
        if tableView == nil {
            let tableView = UITableView()
           // view.stickSubView(tableView)
            self.tableView = tableView
        }
      
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.addRefreshHeader(refreshingBlock: { [weak self] in
            self?.headerLoader()
        })
        tableView2?.dataSource = self
        tableView2?.delegate = self
        tableView2?.addRefreshHeader(refreshingBlock: { [weak self] in
            self?.headerLoader()
        })
    }

    // MARK: - Public Method: Manipulate table view and collection view
    private func reloadData() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.reloadData()
            }
            return
        }
        tableView.reloadData()
        tableView2?.reloadData()
    }

    func headerLoader() {
        tableView.endHeaderRefreshing()
        tableView2?.endHeaderRefreshing()
    }

    func footerLoader() {
        tableView.endFooterRefreshing()
        tableView2?.endFooterRefreshing()
    }

    func endHeaderRefreshing() {
        tableView.endHeaderRefreshing()
        tableView2?.endHeaderRefreshing()
    }

    func endFooterRefreshing() {
        tableView.endFooterRefreshing()
        tableView2?.endFooterRefreshing()
    }

    func endWithNoMoreData() {
        tableView.endWithNoMoreData()
        tableView2?.endWithNoMoreData()
    }

    func resetNoMoreData() {
        tableView.resetNoMoreData()
        tableView2?.resetNoMoreData()
    }
    // MARK: - Public Method: Change layout
    func showListView() {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }

    // MARK: - UITableViewDataSource. Subclass should override these method for setting properly.
    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(style: .default, reuseIdentifier: String(describing: STCompondViewController.self))
    }

}
