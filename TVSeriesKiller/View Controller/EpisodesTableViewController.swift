//
//  EpisodesTableViewController.swift
//  TVSeriesKiller
//
//  Created by Alperen Ünal on 3.04.2020.
//  Copyright © 2020 Alperen Unal. All rights reserved.
//

import UIKit
import SwiftSoup
import AVFoundation
import AVKit

class EpisodesTableViewController: UITableViewController {
    
    var currentSeason: Season!
    var episodes = [Episode]()
    var videoPlayer = AVPlayer()
    var videoVC = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        episodes.append(contentsOf: currentSeason.episode)
        title = "Season \(currentSeason.seasonNumber)"
    }

}

// MARK: - Table view delegate methods
extension EpisodesTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentEpisode = episodes[indexPath.row]
        let cell = UITableViewCell()
        cell.textLabel?.text = "Episode \(currentEpisode.episodeNumber)"
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentEpisode = episodes[indexPath.row]
        getVideoURL(episode: currentEpisode)
    }
}
// MARK: - Auxiliary methods
extension EpisodesTableViewController {
    func getVideoURL(episode: Episode) {
        guard let url = URL(string: episode.url) else { return }
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
            let data: String = try doc.select("div#preroll").select("iframe").attr("src")
            let videoID = data.split(separator: "=")[1]
            getDownloadURL(videoID: String(videoID))
        } catch Exception.Error(let type, let message) {
            print("Type: \(type) Message: \(message)")
        } catch {
            print("error")
        }
    }
    func getDownloadURL(videoID: String) {
        let urlString = "https://fileru.net/download.php?v=\(videoID)"
        guard let url = URL(string: urlString) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        URLSession.shared.dataTask(with: urlRequest){(data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let data = data else { return }
                let htmlData = String(data: data, encoding: .utf8)!
                self.processVideoData(html: htmlData)
            }
        }.resume()
    }
    func processVideoData(html: String) {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let elements: Elements = try doc.select("div#downloadLinks").select("div").select("div.col-6")
            let downloadURL = try elements.array()[2].select("a").attr("href")
            DispatchQueue.main.async {
                let videoPlayer = self.prepareVideo(with: downloadURL)
                self.videoVC.player = videoPlayer
                self.present(self.videoVC, animated: true) {
                    videoPlayer.play()
                }
            }
        } catch Exception.Error(let type, let message) {
            print("Type: \(type) Message: \(message)")
        } catch {
            print("error")
        }
    }
    func prepareVideo(with videoUrl: String) -> AVPlayer {
        guard let url = URL(string: videoUrl) else { return AVPlayer() }
        
        videoPlayer = AVPlayer(url: url)
        
        return videoPlayer
    }
}
