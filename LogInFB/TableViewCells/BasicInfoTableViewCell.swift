//
//  BasicInfoTableViewCell.swift
//  LogInFB
//
//  Created by Deniz Adil on 16.11.20.
//

import UIKit

protocol BasicinfoCellDelegate: class {
    func didClickOnEditImage()
    func didTapOnUserImage(user: User?, image: UIImage?)
    func didFollowUsers(user: User?, isFollowed: Bool)
}

class BasicInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblOtherInfo: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    
    var user: User?
    weak var delegate: BasicinfoCellDelegate?
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = 28
        profileImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(user: User) {
        self.user = user
        guard let localUser = DataStore.shared.localUser, let userId = user.id, let followedUsers = localUser.followingUsersID else {return}
        if followedUsers.contains(userId) {
            btnFollow.isSelected = true
            btnFollow.layer.backgroundColor = UIColor(named: "ThirdGray")?.cgColor
        } else {
            btnFollow.isSelected = false
            btnFollow.layer.backgroundColor = UIColor(named: "MainPink")?.cgColor
        }
//        guard let myID = localUser.id else {return}
//        DataStore.shared.getUser(uid: myID) { (user, error) in
//            if let user = user {
//                self.lblName.text = user.fullName
//                self.btnFollow.isHidden = true
//            }
//        }
    }
    
    @IBAction func oneditImage(_ sender: UIButton) {
        if let user = user, user.id == DataStore.shared.localUser?.id {
        delegate?.didClickOnEditImage()
        } else {
            delegate?.didTapOnUserImage(user: user, image: profileImage.image)
        }
    }
    
    @IBAction func onFollow(_ sender: UIButton) {
        guard let user = user else { return }
        if btnFollow.isSelected {
            delegate?.didFollowUsers(user: user, isFollowed: false)
            btnFollow.isSelected = false
        } else {
            delegate?.didFollowUsers(user: user, isFollowed: true)
            btnFollow.isSelected = true
        }
    }
}
