import UIKit
import DropDown

struct Response: Codable {
    let data: [Product]?
}

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    var products: [Product] = []
    var dataFiltered: [Product] = []
    var dropButton = DropDown()
    let backView = UIView()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search"
        searchBar.barStyle = .default
        searchBar.barTintColor = .white
        searchBar.backgroundImage = UIImage()
//        searchBar.layer.borderWidth = 1
//        searchBar.layer.borderColor = UIColor.white.cgColor
//        searchBar.layer.cornerRadius = 8
        searchBar.clipsToBounds = true
        return searchBar
    }()
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.minimumLineSpacing = 20
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataFiltered = products
        navigationItem.title = "搜尋"
        dropButton.anchorView = searchBar
        dropButton.bottomOffset = CGPoint(x: 0, y: searchBar.frame.height)
        dropButton.backgroundColor = .clear
        dropButton.direction = .bottom

        dropButton.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
        }

        view.backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.91, alpha: 1.0)

        tableView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        
        tableView.layer.cornerRadius = 10

        view.addSubview(dropButton)
        view.addSubview(searchBar)
        view.addSubview(tableView)
//        tableView.addSubview(collectionView)

        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SearchProductCollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 40),

            dropButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            dropButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            dropButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            dropButton.heightAnchor.constraint(equalToConstant: 20),

            tableView.topAnchor.constraint(equalTo: dropButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200),

//            collectionView.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 10),
//            collectionView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20),
//            collectionView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -20),
//            collectionView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -20),
//            collectionView.heightAnchor.constraint(equalToConstant: 500),
//            collectionView.widthAnchor.constraint(equalToConstant: 500)
            
        ])

        setupSearchBarAppearance()
        
       
        backView.backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.91, alpha: 0.5)
        view.addSubview(backView)
//        view.sendSubviewToBack(backView)
        backView.addSubview(collectionView)
        backView.layer.cornerRadius = 10
        backView.layer.masksToBounds = true
        backView.isHidden = true
        backView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            backView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 120),
            collectionView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 200),
            collectionView.widthAnchor.constraint(equalToConstant: 200)
        ])
    
    }

    func setupSearchBarAppearance() {
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.layer.cornerRadius = 20
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.searchTextField.layer.borderWidth = 1
        searchBar.searchTextField.layer.borderColor = UIColor.lightGray.cgColor
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        URLSession.shared.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }

        if !searchText.isEmpty {
            fetchDataFromAPI(keyword: searchText)
        } else {
            dataFiltered = products
            tableView.reloadData()
            collectionView.reloadData()
        }
    }

    // MARK: - UITableView Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataFiltered.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataFiltered[indexPath.row].title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < dataFiltered.count else {
            return
        }

        let selectedProduct = dataFiltered[indexPath.row]
        if let selectedProductIndex = dataFiltered.firstIndex(where: { $0.id == selectedProduct.id }) {
            let selectedProductData = [selectedProduct]
            let indexPath = IndexPath(item: selectedProductIndex, section: 0)
                //show backview
            self.backView.isHidden = false
//            self.collectionView.reloadData()
//            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            collectionView.reloadData()
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    // MARK: - UICollectionView Data Source

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataFiltered.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? SearchProductCollectionViewCell ?? SearchProductCollectionViewCell()

        let product = dataFiltered[indexPath.row]

        if let imageURL = URL(string: product.mainImage) {
            if let imageData = try? Data(contentsOf: imageURL) {
                cell.productImageView.image = UIImage(data: imageData)
            }
        }
//        cell.titleLabel.text = product.title
//        cell.priceLabel.text = "Price: $\(product.price)"

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if indexPath.row < dataFiltered.count {
                let selectedProduct = dataFiltered[indexPath.row]
                navigateToProductDetail(for: selectedProduct)
            }
        }

    func navigateToProductDetail(for product: Product) {
        let storyboard = UIStoryboard(name: "Product", bundle: nil)

        if let productDetailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController {
            productDetailVC.product = product
            navigationController?.pushViewController(productDetailVC, animated: true)
        }
    }


    func fetchDataFromAPI(keyword: String) {
        if let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let apiUrl = URL(string: "http://35.72.177.254:3000/api/products/search?keyword=\(encodedKeyword)") {
                let task = URLSession.shared.dataTask(with: apiUrl) { [weak self] (data, response, error) in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }

                    if let data = data {
                        do {
                            let decoder = JSONDecoder()
                            let responseDict = try decoder.decode(Response.self, from: data)

                            if let products = responseDict.data {
                                DispatchQueue.main.async {
                                    self?.products = products
                                    self?.dataFiltered = products
                                    self?.tableView.reloadData()
                                    self?.collectionView.reloadData()
                                }
                            } else {
                                print("No data found in the response")
                            }
                        } catch {
                            print("Error decoding data: \(error)")
                        }
                    }
                }
                task.resume()
            }
        }
    }
}

class SearchProductCollectionViewCell: UICollectionViewCell {
    let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()

//    let titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont.boldSystemFont(ofSize: 14)
//        label.textColor = UIColor.black
//        label.textAlignment = .left
//        label.numberOfLines = 2
//        return label
//    }()
//
//    let priceLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont.systemFont(ofSize: 12)
//        label.textColor = UIColor.gray
//        label.textAlignment = .left
//        return label
//    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(productImageView)
//        addSubview(titleLabel)
//        addSubview(priceLabel)

        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: topAnchor),
            productImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            productImageView.bottomAnchor.constraint(equalTo: priceLabel.topAnchor),
            productImageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            productImageView.widthAnchor.constraint(equalToConstant: 100),
            productImageView.heightAnchor.constraint(equalToConstant: 100),

//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
//            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
//            titleLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 8),
//
//            priceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
//            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
//            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
