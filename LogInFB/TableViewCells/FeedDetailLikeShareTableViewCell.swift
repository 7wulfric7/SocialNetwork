//
//  FeedDetailLikeShareTableViewCell.swift
//  LogInFB
//
//  Created by Deniz Adil on 2.12.20.
//

import UIKit

class FeedDetailLikeShareTableViewCell: UITableViewCell {

    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblLikeCount: UILabel!
    @IBOutlet weak var lblShareCount: UILabel!
    
    var feedItem: Feed?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setupCell(feedItem: Feed) {
        self.feedItem = feedItem
        guard let localUser = DataStore.shared.localUser,
              let likedMoments = localUser.likedMoments else { return }
        let isLiked = likedMoments.contains(feedItem.id!)
        self.btnLike.isSelected = isLiked
    }
    @IBAction func onLike(_ sender: UIButton) {
        
        guard let item = feedItem else { return }
        var localUser = DataStore.shared.localUser
        if btnLike.isSelected {
            guard let index = localUser?.likedMoments?.firstIndex(where: {$0 == item.id!}) else {
                return
            }
            localUser?.likedMoments?.remove(at: index)
            //already liked
        } else if !btnLike.isSelected {
            //first time likes
            if localUser?.likedMoments == nil {
                localUser?.likedMoments = []
            }
            
            localUser?.likedMoments?.append(item.id!)
        }
        btnLike.isSelected = !btnLike.isSelected
            //save user to firebase
        localUser?.save(completion: nil)
    }
}
