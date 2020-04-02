//
//  SearchTableViewController.swift
//  TVSeriesKiller
//
//  Created by Alperen Ünal on 1.04.2020.
//  Copyright © 2020 Alperen Unal. All rights reserved.
//

import UIKit
import SwiftSoup

class SearchTableViewController: UITableViewController {
    
    var tvSeries = [TVSerie]()
    var willSendSerie: TVSerie!

    override func viewDidLoad() {
        super.viewDidLoad()
        setSearchBar()
    }

}
// MARK: Auxiliary Methods
extension SearchTableViewController {
    func setSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search TV Series"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    func fetchTVSeries(name: String) {
        let urlString = "https://dizilla.com/arsiv/?q=\(name)"
        guard let url = URL(string: urlString) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        URLSession.shared.dataTask(with: urlRequest){(data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let data = data else { return }
                let htmlData = String(data: data, encoding: .utf8)!
                self.processHtmlData(html: htmlData)
            }
        }.resume()
    }
    func processHtmlData(html: String) {
        do {
           let doc: Document = try SwiftSoup.parse(html)
            let els: Elements = try doc.select("div.results").select("div.row").select("div.col-lg-6").select("div.archiveBox")
            for element in els.array() {
                let name = try element.select("div.right").select("a").attr("title")
                let link = try element.select("div.right").select("a").attr("href")
                let imageURL = try element.select("div.left").select("a").select("img").attr("data-lazy-src")
                let description = try element.select("div.right").select("div.description").text()
                let tvSerie = TVSerie(name: name, description: description, imageURL: imageURL, link: link)
                tvSeries.append(tvSerie)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch Exception.Error(let type, let message) {
            print("Type: \(type) Message: \(message)")
        } catch {
            print("error")
        }
    }
}

// MARK: TableView Delegate Methods
extension SearchTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tvSeries.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSerie = tvSeries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        cell.setSerie(tvSerie: currentSerie)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentSerie = tvSeries[indexPath.row]
        willSendSerie = currentSerie
        performSegue(withIdentifier: "goToSeasons", sender: nil)
    }
}
// MARK: SearchBar Delegate Methods
extension SearchTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Fetch TV Series data and reload table view.
        tvSeries.removeAll()
        fetchTVSeries(name: searchBar.text ?? "")
        
        searchBar.endEditing(true)
    }
}
// MARK: Prepare for Segue
extension SearchTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SeasonsTableViewController {
            destinationVC.currentTVSerie = willSendSerie
        }
    }
}


