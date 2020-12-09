//
//  FeedDetailTextTableViewCell.swift
//  LogInFB
//
//  Created by Deniz Adil on 2.12.20.
//

import UIKit

class FeedDetailTextTableViewCell: UITableViewCell {
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
