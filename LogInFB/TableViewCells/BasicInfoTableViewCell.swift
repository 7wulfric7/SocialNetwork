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
}

class BasicInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblOtherInfo: UILabel!
    
    weak var delegate: BasicinfoCellDelegate?
   
    var user: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = 28
        profileImage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func oneditImage(_ sender: UIButton) {
        if let user = user, user.id == DataStore.shared.localUser?.id {
        delegate?.didClickOnEditImage()
        } else {
            delegate?.didTapOnUserImage(user: user, image: profileImage.image)
        }
    }
}
