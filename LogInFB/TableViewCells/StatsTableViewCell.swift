//
//  StatsTableViewCell.swift
//  LogInFB
//
//  Created by Deniz Adil on 18.11.20.
//

import UIKit

protocol StatsTableViewDelegate: class {
   func didClickOnFollowing()
   func didClickOnFollowers()
}

class StatsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblMomentsNumbers: UILabel!
    @IBOutlet weak var lblFollowersNumbers: UILabel!
    @IBOutlet weak var lblFollowingNumbers: UILabel!
    @IBOutlet weak var lblMomentsText: UILabel!
    @IBOutlet weak var lblFollowersText: UILabel!
    @IBOutlet weak var lblFollowingText: UILabel!
    @IBOutlet weak var onFollowing: UIButton!
    @IBOutlet weak var onFollowers: UIButton!
    
    weak var delegate: StatsTableViewDelegate?
    
    var userId: String?
    var creatorId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setCounts()
        lblMomentsText.alpha = 0.5
        lblFollowersText.alpha = 0.5
        lblFollowingText.alpha = 0.5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCounts() {
        setFollowersCount()
        setFollowingCount()
    }
    
    private func setFollowersCount() {
        guard let userId = userId else {return}
        DataStore.shared.getFollowCount(userId: userId, isFollowers: true) { (count, error) in
            self.lblFollowersNumbers.text = "\(count)"
        }
    }
    
    private func setFollowingCount() {
        guard let userId = userId else {return}
        DataStore.shared.getFollowCount(userId: userId, isFollowers: false) { (count, error) in
            self.lblFollowingNumbers.text = "\(count)"
        }
    }
    
    @IBAction func onFollowing(_ sender: UIButton) {
        self.delegate?.didClickOnFollowing()
    }
    
    @IBAction func onFollowers(_ sender: UIButton) {
        self.delegate?.didClickOnFollowers()
    }
}
