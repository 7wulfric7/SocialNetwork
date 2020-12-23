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
            btnFollow.backgroundColor = UIColor(named: "MainPink")?.withAlphaComponent(0.2)
        } else {
            btnFollow.isSelected = false
            btnFollow.backgroundColor = UIColor(named: "MainPink")
        }
        guard let myID = user.id, let user = DataStore.shared.localUser?.id else {return}
        if myID == user {
                self.btnFollow.isHidden = true
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
        if btnFollow.isSelected {
            delegate?.didFollowUsers(user: user, isFollowed: false)
            btnFollow.isSelected = false
        } else {
            delegate?.didFollowUsers(user: user, isFollowed: true)
            btnFollow.isSelected = true
        }
    }
}
