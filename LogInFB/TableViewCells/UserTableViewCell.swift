//
//  UserTableViewCell.swift
//  LogInFB
//
//  Created by Deniz Adil on 25.11.20.
//

import UIKit

protocol BlockUsersCellDelegate: class {
    func didBlockUser(user: User, isBlock: Bool)
//    isBlock = true if we block the user
//    isBlock = false if we unblock the user
}

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnBlock: UIButton!
    
    var user: User?
    weak var blockingDelegate: BlockUsersCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(user: User) {
        self.user = user
        lblName.text = user.fullName
        if let imageUrl = user.imageUrl {
            self.userImage.kf.setImage(with: URL(string: imageUrl))
        } else {
            self.userImage.image = UIImage(named: "userPlaceholder")
        }
        guard let localUser = DataStore.shared.localUser, let userId = user.id, let blockedUsers = localUser.blockedUsersID else {return}
        if blockedUsers.contains(userId) {
            btnBlock.isSelected = true
            btnBlock.layer.backgroundColor = UIColor(named: "ThirdGray")?.cgColor
        } else {
            btnBlock.isSelected = false
            btnBlock.layer.backgroundColor = UIColor(named: "MainPink")?.cgColor
        }
//        za da se skrati if-ot može vaka:
//        btnBlock.isSelected = blockedUsers.contains(userId)
    }
    
    @IBAction func btnBlock(_ sender: UIButton) {
        guard let user = user else { return }
        if btnBlock.isSelected {
            blockingDelegate?.didBlockUser(user: user, isBlock: false)
            btnBlock.isSelected = false
        } else {
            blockingDelegate?.didBlockUser(user: user, isBlock: true)
            btnBlock.isSelected = true
        }
//        blockingDelegate?.didBlockUser(user: user, isBlock: !btnBlock.isSelected)
//        btnBlock.isSelected = !btnBlock.isSelected
        
    }
}
