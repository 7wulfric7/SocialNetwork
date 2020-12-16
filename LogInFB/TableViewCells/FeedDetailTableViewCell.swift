//
//  FeedDetailTableViewCell.swift
//  LogInFB
//
//  Created by Deniz Adil on 2.12.20.
//

import UIKit
import Kingfisher

class FeedDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var userImageOne: UIImageView!
    @IBOutlet weak var userImageTwo: UIImageView!
    @IBOutlet weak var userImageThree: UIImageView!
    @IBOutlet weak var userImageFour: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImage.layer.cornerRadius = 16
        userImage.layer.masksToBounds = true
        userImageOne.layer.cornerRadius = 12
        userImageOne.layer.masksToBounds = true
        userImageTwo.layer.cornerRadius = 12
        userImageTwo.layer.masksToBounds = true
        userImageThree.layer.cornerRadius = 12
        userImageThree.layer.masksToBounds = true
        userImageFour.layer.cornerRadius = 12
        userImageFour.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    func setData(moment: Feed) {
        guard let creatorId = moment.creatorId else { return }
        DataStore.shared.getUser(uid: creatorId) { (user, error) in
            guard let user = user else { return }
            self.lblUserName.text = user.fullName
            if let imageUrl = user.imageUrl {
            self.userImage.kf.setImage(with: URL(string: imageUrl))
            }
        }
    }
}
