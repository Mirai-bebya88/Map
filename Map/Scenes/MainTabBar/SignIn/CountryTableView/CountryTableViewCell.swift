//
//  CountryTableViewCell.swift
//  Map
//
//  Created by elene malakmadze on 23.12.25.
//

import UIKit

class CountryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var countryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with country: Country) {
        let commonName = country.name.common
        
        countryLabel.text = commonName
    }
}
