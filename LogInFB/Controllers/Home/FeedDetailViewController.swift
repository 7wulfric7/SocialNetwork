//
//  FeedDetailViewController.swift
//  LogInFB
//
//  Created by Deniz Adil on 3.12.20.
//

import UIKit
import SwiftPhotoGallery

enum FeedDetailTableData {
    case feedDetail
    case feedDetailImage
    case feedDetailText
    case feedDetailLikeShare
    
    var cellIdentifier: String {
        switch self {
        case .feedDetail:
            return "feedDetailCell"
        case .feedDetailImage:
            return "feedDetailImageCell"
        case .feedDetailText:
            return "feedDetailTextCell"
        case .feedDetailLikeShare:
            return "feedDetailLikeShareCell"
        }
    }
        var cellHeight: CGFloat {
            switch self {
            case .feedDetail:
                return 64
            case .feedDetailImage:
                return 375
            case .feedDetailText:
                return 80
            case .feedDetailLikeShare:
                return 56
            }
        }
    }

class FeedDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let tableData: [FeedDetailTableData] = [.feedDetail, .feedDetailImage, .feedDetailText, .feedDetailLikeShare]
    
    var feed: Feed?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: "FeedDetailTableViewCell", bundle: nil), forCellReuseIdentifier: FeedDetailTableData.feedDetail.cellIdentifier)
        tableView.register(UINib(nibName: "FeedDetailImageTableViewCell", bundle: nil), forCellReuseIdentifier: FeedDetailTableData.feedDetailImage.cellIdentifier)
        tableView.register(UINib(nibName: "FeedDetailTextTableViewCell", bundle: nil), forCellReuseIdentifier: FeedDetailTableData.feedDetailText.cellIdentifier)
        tableView.register(UINib(nibName: "FeedDetailLikeShareTableViewCell", bundle: nil), forCellReuseIdentifier: FeedDetailTableData.feedDetailLikeShare.cellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(hex: "F1F1F1")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets.zero
    }
}

extension FeedDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = tableData[indexPath.row]
        return data.cellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let selectedFeed = feed else {
            return UITableViewCell()
        }
        let data = tableData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: data.cellIdentifier)
        return getCellFor(data: data, feed: selectedFeed, cell: cell)
    }
    private func getCellFor(data: FeedDetailTableData, feed: Feed, cell: UITableViewCell?) -> UITableViewCell {
        let date = Date(with: feed.createdAt!)
        switch data {
        case .feedDetail:
            guard let feedDetailCell = cell as? FeedDetailTableViewCell else {
                return UITableViewCell()
            }
            DataStore.shared.getUser(uid: feed.creatorId!) { (user, error) in
                if let error = error {
               self.showErrorWith(title: "Error", msg: error.localizedDescription)
               return
           }
                if let user = user {
                    self.title = user.fullName! + "'s Moment"
                    feedDetailCell.lblUserName.text = user.fullName
                    feedDetailCell.userImage.kf.setImage(with: URL(string: user.imageUrl!))
                }
            }
            feedDetailCell.lblTime.text = date?.timeAgoDisplay()
            feedDetailCell.selectionStyle = .none
            return feedDetailCell
            
        case .feedDetailImage:
            guard let feedDetailImageCell = cell as? FeedDetailImageTableViewCell else {
                return UITableViewCell()
            }
            
            if let imageUrl = feed.imageUrl {
                feedDetailImageCell.imageHolder.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "userPlaceholder"))
            }
            feedDetailImageCell.selectionStyle = .none
            return feedDetailImageCell
            
        case .feedDetailText:
            guard let feedDetailTextCell = cell as? FeedDetailTextTableViewCell else {
                return UITableViewCell()
            }
            feedDetailTextCell.lblCaption.text = feed.caption
            feedDetailTextCell.lblTime.text = date?.timeAgoDisplay()
            feedDetailTextCell.selectionStyle = .none
            return feedDetailTextCell
            
        case .feedDetailLikeShare:
            guard let feedDetailLikeShareCell = cell as? FeedDetailLikeShareTableViewCell else {
                return UITableViewCell()
            }
            feedDetailLikeShareCell.lblLikeCount.text = "\(feed.likeCount ?? 0)"
            feedDetailLikeShareCell.lblShareCount.text = "\(feed.shareCount ?? 0)"
            feedDetailLikeShareCell.selectionStyle = .none
            return feedDetailLikeShareCell
        }
    }
}
