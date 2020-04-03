//
//  SeasonsTableViewController.swift
//  TVSeriesKiller
//
//  Created by Alperen Ünal on 2.04.2020.
//  Copyright © 2020 Alperen Unal. All rights reserved.
//

import UIKit
import SwiftSoup

class SeasonsTableViewController: UITableViewController {
    
    var currentTVSerie: TVSerie!
    var seasons = [Season]()
    var indicator = UIActivityIndicatorView()
    var willSendSeason: Season!

    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.backgroundColor = .white
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(currentTVSerie.link)
        fetchSeasons()
    }

}
// MARK: - Auxiliary methods
extension SeasonsTableViewController {
    func fetchSeasons() {
        tableView.separatorStyle = .none
        activityIndicator()
        indicator.startAnimating()
        indicator.backgroundColor = .white
        guard let url = URL(string: currentTVSerie.link) else { return }
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
            let els: Elements = try doc.select("script[type='application/ld+json']")
            for element in els.array() {
                
                if try element.className() == "" {
                    let json = element.data()
                    //Decode the json and reload table view
                    let data = Data(json.utf8)
                    let decodedData = try JSONDecoder().decode(Seasons.self, from: data)
                    seasons.append(contentsOf: decodedData.containsSeason)
                    DispatchQueue.main.async {
                        self.tableView.separatorStyle = .singleLine
                        self.indicator.stopAnimating()
                        self.indicator.hidesWhenStopped = true
                        self.tableView.reloadData()
                    }
                }
                
            }
        } catch Exception.Error(let type, let message) {
            print("Type: \(type) Message: \(message)")
        } catch {
            print("error")
        }
    }
}
// MARK: - Table view delegate methods
extension SeasonsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seasons.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSeason = seasons[indexPath.row]
        let cell = UITableViewCell()
        cell.textLabel?.text = "Season \(currentSeason.seasonNumber)"
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentSeason = seasons[indexPath.row]
        willSendSeason = currentSeason
        performSegue(withIdentifier: "goToEpisodes", sender: nil)
    }
}
// MARK: Prepare for Segue
extension SeasonsTableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? EpisodesTableViewController {
            destinationVC.currentSeason = willSendSeason
        }
    }
}
