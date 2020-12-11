//
//  MyFeedCollectionViewCell.swift
//  LogInFB
//
//  Created by Deniz Adil on 2.12.20.
//

import UIKit
import Kingfisher

class MyFeedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageHolder: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    
    var feedItem: Feed?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageHolder.layer.cornerRadius = 4
       
        userImage.layer.cornerRadius = 16
        userImage.layer.masksToBounds = true
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        userImage.image = nil
        lblUserName.text = nil
    }
    
    func setupCell(feedItem: Feed) {
        self.feedItem = feedItem
        imageHolder.kf.setImage(with: URL(string: feedItem.imageUrl!))
        setDate(feedItem: feedItem)
        fetchCreatorDetails(feedItem: feedItem)
        guard let localUser = DataStore.shared.localUser,
              let likedMoments = localUser.likedMoments else { return }
        let isLiked = likedMoments.contains(feedItem.id!)
        self.btnLike.isSelected = isLiked
    }
   
    func fetchCreatorDetails(feedItem: Feed) {
        guard let creatorId = feedItem.creatorId else { return }
        DataStore.shared.getUser(uid: creatorId) { (user, error) in
            if let user = user {
                self.lblUserName.text = user.fullName
                if let imageUrl = user.imageUrl {
                    self.userImage.kf.setImage(with: URL(string: imageUrl))
                } else {
                    self.userImage.image = UIImage(named: "userPlaceholder")
                }
            }
        }
    }
    func setDate(feedItem: Feed) {
        let date = Date(with: feedItem.createdAt!)
        lblTime.text = date?.timeAgoDisplay()
//        Dare: može i vaka:
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
//        let string = dateFormatter.string(from: date!)
    }
//    Deniz:
//    func getUserDataFor(feedItem: Feed) {
//        DataStore.shared.getAllUsers { (user, error) in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//            if let users = user {
//                for users in users {
//                    if feedItem.creatorId == users.id {
//                        self.lblUserName.text = users.fullName
//                        self.userImage.kf.setImage(with: URL(string: users.imageUrl!))
//                }
//            }
//        }
//    }
//}
    
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
        localUser?.save()
    }
}

