//
//  StoreSearchViewController.swift
//  StoreSearch
//
//  Created by Thao Nguyen on 02/12/2020.
//

import UIKit

class StoreSearchViewController: UIViewController {

    // MARK: - Outlet variable
    @IBOutlet weak var searchBar : UISearchBar!
    @IBOutlet weak var tableView : UITableView!    
    // Variable
    var searchResults = [SearchResult]()
    // Search flag
    var hasSearch = false
    // Indicator flag
    var isLoading = false
    
    var dataTask : URLSessionDataTask?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        print("Segment changed: \(sender.selectedSegmentIndex)")
        performSearch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        var cellNib = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        // Nothing found cell
        cellNib = UINib(nibName: TableView.CellIdentifiers.nothingResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.nothingResultCell)
        
        cellNib = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - TableView.CellIdentifiers
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingResultCell = "NothingFoundCell"
            // LoadingCell indicator
            static let loadingCell = "LoadingCell"
        }
    }
    
    // MARK: - Helper Methods
    func iTunesURL(searchText : String, category : Int) -> URL{
        let kind : String
        switch category {
            case 1:
                kind = "musicTrack"
            case 2:
                kind = "software"
            case 3:
                kind = "ebook"
            default:
                kind = ""
        }
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=100&entity=%@", encodedText, kind)
        let url = URL(string: urlString)
        return url!
    }
    
    func performStoreRequest(with url : URL) -> Data?{
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Download Error: \(error.localizedDescription)")
            showNetworkError()
            return nil
        }
    }
    
    func parse(data : Data) -> [SearchResult]{
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        } catch{
            print("JSON Error: \(error)")
            return []
        }
    }
    
    func showNetworkError(){
        let alert = UIAlertController(title: "Whoops", message: "There was an error accessing the iTunes Store. Please tray again", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Search Bar Button Clicked
extension StoreSearchViewController : UISearchBarDelegate{
    func performSearch() {
        if !searchBar.text!.isEmpty{
            searchBar.resignFirstResponder()
            dataTask?.cancel()
            isLoading = true
            tableView.reloadData()
            hasSearch = true
            searchResults = []

            let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url, completionHandler: {
                data, response, error in
                if let error = error as NSError?, error.code == -999 {
                    print("Failure! \(error.localizedDescription)")
                    return
                }else if let httpResponse = response as? HTTPURLResponse,
                         httpResponse.statusCode == 200 {
                    if let data = data{
                        self.searchResults = self.parse(data: data)
                        self.searchResults.sort { $0 < $1 }
                        DispatchQueue.main.async {
                            // UPdate the UI in main queue
                            self.isLoading = false
                            self.tableView.reloadData()
                            print("============  UI On main thread?" + (Thread.current.isMainThread ? "Yes" : "No"))
                        }
                        print("============  Closure On main thread?" + (Thread.current.isMainThread ? "Yes" : "No"))
                        return
                    }
                    DispatchQueue.main.async {
                        self.hasSearch = false
                        self.isLoading = false
                        self.tableView.reloadData()
                        self.showNetworkError()
                    }
                }
                else{
                    print("Faillure! \(response!)")
                }
            })
            
        }
        dataTask?.resume()
        print("Result: \(searchResults)")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        performSearch()
    }
    
    // Extend the status bar area to the top.
    func position(for bar : UIBarPositioning) -> UIBarPosition{
        return .topAttached
    }
}

// MARK: - TableView
extension StoreSearchViewController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading{
            return 1
        }
        else if !hasSearch {
            return 0
        }
        else if searchResults.count == 0{
            return 1
        }
        else{
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading{
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        else if searchResults.count == 0{
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingResultCell, for: indexPath)
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading{
            return nil
        }
        else{
            return indexPath
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail"{
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            let searchResult = searchResults[indexPath.row]
            detailViewController.searchResult = searchResult
        }
    }
}
