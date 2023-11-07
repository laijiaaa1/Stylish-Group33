import UIKit
import DropDown

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var products: [Product] = []
    var dataFiltered: [Product] = []
    var dropButton = DropDown()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search"
        searchBar.barStyle = .default
        searchBar.barTintColor = .white
        searchBar.backgroundImage = UIImage()
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBar.layer.cornerRadius = 8
        searchBar.clipsToBounds = true
        return searchBar
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataFiltered = products
        
        dropButton.anchorView = searchBar
        dropButton.bottomOffset = CGPoint(x: 0, y: searchBar.frame.height)
        dropButton.backgroundColor = .white
        dropButton.direction = .bottom
        
        dropButton.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
        }
        
        view.addSubview(dropButton)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 40),
            
            dropButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            dropButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            dropButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            dropButton.heightAnchor.constraint(equalToConstant: 20),
            
            tableView.topAnchor.constraint(equalTo: dropButton.bottomAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        setupSearchBarAppearance()
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
        
        struct Response: Codable {
            let data: [Product]?
        }
    }
    
}
