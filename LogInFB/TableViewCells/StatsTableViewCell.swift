//
//  StatsTableViewCell.swift
//  LogInFB
//
//  Created by Deniz Adil on 18.11.20.
//

import UIKit

class StatsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblMomentsNumbers: UILabel!
    @IBOutlet weak var lblFollowersNumbers: UILabel!
    @IBOutlet weak var lblFollowingNumbers: UILabel!
    @IBOutlet weak var lblMomentsText: UILabel!
    @IBOutlet weak var lblFollowersText: UILabel!
    @IBOutlet weak var lblFollowingText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblMomentsText.alpha = 0.5
        lblFollowersText.alpha = 0.5
        lblFollowingText.alpha = 0.5
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
