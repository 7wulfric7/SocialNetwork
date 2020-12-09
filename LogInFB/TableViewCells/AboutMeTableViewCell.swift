//
//  AboutMeTableViewCell.swift
//  LogInFB
//
//  Created by Deniz Adil on 18.11.20.
//

import UIKit

class AboutMeTableViewCell: UITableViewCell {

    @IBOutlet weak var lblAboutMe: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblAboutMe.alpha = 0.8
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
