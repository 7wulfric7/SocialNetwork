//
//  BasicInfoTableViewCell.swift
//  LogInFB
//
//  Created by Deniz Adil on 16.11.20.
//

import UIKit
import FirebaseFirestore

protocol BasicinfoCellDelegate: class {
    func didClickOnEditImage()
    func didTapOnUserImage(user: User?, image: UIImage?)
    func reloadFollowCount()
//    func didFollowUsers(user: User?, isFollowed: Bool)
}

class BasicInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblOtherInfo: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    
    var user: User?
    weak var delegate: BasicinfoCellDelegate?
    private let database = Firestore.firestore()
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnFollow.layer.cornerRadius = 4
        btnFollow.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 28
        profileImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(user: User) {
        self.user = user
        lblName.text = user.fullName
        lblOtherInfo.text = (user.gender ?? "") + ", " + (user.location ?? "") //Dokolku propertito e nil ke ja zeme desnata vrednost odnosno “defaultValue” (variable ?? defaultValue)
        if let imageUrl = user.imageUrl {
            profileImage.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "userPlaceholder"))
        } else {
            profileImage.image = UIImage(named: "userPlaceholder")
        }
        guard let localUser = DataStore.shared.localUser else { return }
        if user.id != localUser.id {
            btnFollow.isHidden = false
            if FollowManager.shared.following.contains(where: { $0.userId == user.id }) {
                setButtonTitle(title: "UNFOLLOW")
            } else {
                setButtonTitle(title: "FOLLOW")
            }
        } else {
            btnFollow.isHidden = true
        }
        
        //Deniz (star kod, so upotreba na array za following):
//        guard let localUser = DataStore.shared.localUser, let userId = user.id, let followedUsers = localUser.followingUsersID else {return}
//        if followedUsers.contains(userId) {
//            btnFollow.isSelected = true
//            btnFollow.backgroundColor = UIColor(named: "MainPink")?.withAlphaComponent(0.2)
//        } else {
//            btnFollow.isSelected = false
//            btnFollow.backgroundColor = UIColor(named: "MainPink")
//        }
//        guard let myID = user.id, let user = DataStore.shared.localUser?.id else {return}
//        if myID == user {
//                self.btnFollow.isHidden = true
//        }
    }
    func setButtonTitle(title: String) {
        btnFollow.setTitle(title, for: .normal)
        if title == "FOLLOW" {
            btnFollow.backgroundColor = UIColor(named: "MainPink")
            btnFollow.setTitleColor(UIColor.white, for: .normal)
        } else {
            btnFollow.backgroundColor = UIColor(named: "MainPink")?.withAlphaComponent(0.2)
            btnFollow.setTitleColor(UIColor(hex: "FF6265"), for: .normal)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { 
            self.delegate?.reloadFollowCount()
        }
        
    }
    @IBAction func onEditImage(_ sender: UIButton) {
        if let user = user, user.id == DataStore.shared.localUser?.id {
        delegate?.didClickOnEditImage()
        } else {
            delegate?.didTapOnUserImage(user: user, image: profileImage.image)
        }
    }
    
    @IBAction func onFollow(_ sender: UIButton) {
        guard let user = user else { return }
        
        if FollowManager.shared.following.contains(where: {$0.userId == user.id}) {
            //Already following this user
            unfollowUser(user)
            return
        }
       followUser(user)
//        if self.btnFollow.isSelected {
//            self.delegate?.didFollowUsers(user: user, isFollowed: false)
//            self.btnFollow.isSelected = false
//        } else {
//            self.delegate?.didFollowUsers(user: user, isFollowed: true)
//            self.btnFollow.isSelected = true
//        }
    }
    
    func followUser(_ user: User) {
        FollowManager.shared.followUser(user: user) { (success, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if success {
                self.setButtonTitle(title: "UNFOLLOW")
            }
        }
    }
    
    func unfollowUser(_ user: User) {
        FollowManager.shared.unfollowUser(user) { (success, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if success {
                self.setButtonTitle(title: "FOLLOW")
            }
        }
    }
}
