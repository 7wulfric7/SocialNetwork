//
//  FeedDetailImageTableViewCell.swift
//  LogInFB
//
//  Created by Deniz Adil on 2.12.20.
//

import UIKit


class FeedDetailImageTableViewCell: UITableViewCell {

    @IBOutlet weak var imageHolder: UIImageView!
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageHolder.layer.cornerRadius = 8

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
