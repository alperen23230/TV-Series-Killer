//
//  Seasons.swift
//  TVSeriesKiller
//
//  Created by Alperen Ünal on 2.04.2020.
//  Copyright © 2020 Alperen Unal. All rights reserved.
//

import Foundation

struct Seasons: Decodable {
    var containsSeason: [Season]
}
struct Season: Decodable {
    var seasonNumber: String
    var episode: [Episode]
}
struct Episode: Decodable {
    var episodeNumber: String
    var url: String
}
