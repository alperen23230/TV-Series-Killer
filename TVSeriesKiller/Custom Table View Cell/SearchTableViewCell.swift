//
//  SearchTableViewCell.swift
//  TVSeriesKiller
//
//  Created by Alperen Ünal on 1.04.2020.
//  Copyright © 2020 Alperen Unal. All rights reserved.
//

import UIKit
import SDWebImageWebPCoder

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var TVSerieImageView: UIImageView!
    @IBOutlet weak var TVSerieTitleLabel: UILabel!
    @IBOutlet weak var TVSerieDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setSerie(tvSerie: TVSerie) {
        TVSerieTitleLabel.text = tvSerie.name
        TVSerieDescriptionLabel.text = "\(String(tvSerie.description.prefix(80)))..."
        guard let url = URL(string: tvSerie.imageURL) else { return }
        TVSerieImageView.sd_setImage(with: url)
    }

}
