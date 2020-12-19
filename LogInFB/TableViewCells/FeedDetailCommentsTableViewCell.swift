//
//  FeedDetailCommentsTableViewCell.swift
//  LogInFB
//
//  Created by Deniz Adil on 14.12.20.
//

import UIKit

class FeedDetailCommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let adjustedFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        lblComment.adjustsFontForContentSizeCategory = true
        lblComment.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: adjustedFont)
        
        userImage.layer.cornerRadius = 12
        userImage.layer.masksToBounds = true
        
    }

    func setComents(comment: Comment) {
        lblComment.text = comment.body
        lblTime.text = Date(with: comment.createdAt!)?.timeAgoDisplay()
        guard let creatorId = comment.creatorId else { return }
        DataStore.shared.getUser(uid: creatorId) { (user, error) in
            guard let user = user else { return }
            self.lblUserName.text = user.fullName
            if let imageUrl = user.imageUrl {
                self.userImage.kf.setImage(with: URL(string: imageUrl))
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
