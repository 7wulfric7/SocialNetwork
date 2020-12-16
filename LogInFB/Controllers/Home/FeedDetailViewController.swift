//
//  FeedDetailViewController.swift
//  LogInFB
//
//  Created by Deniz Adil on 3.12.20.
//

import UIKit
import SwiftPhotoGallery
import Kingfisher

enum FeedDetailTableData {
    case feedDetail
    case feedDetailImage
    case feedDetailText
    case feedDetailLikeShare
    case feedDetailComments(comments: [String])
    
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
        case .feedDetailComments:
            return "feedDetailsCommentsCell"
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
            case .feedDetailComments:
                return 58
            }
        }
    }

class FeedDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let tableData: [FeedDetailTableData] = [.feedDetail, .feedDetailImage, .feedDetailText, .feedDetailLikeShare, .feedDetailComments(comments: [""])]
    
    var feed: Feed?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableData.append(.feedDetailComments(comments: //fetchedContentOfComments))
        setupSharedButton()
        setupTableView()
    }
    
    private func setupSharedButton() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setImage(UIImage(named: "Shared"), for: .normal)
        button.addTarget(self, action: #selector(onShare), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        }
    @objc func onShare() {
        guard let feed = feed, let imageUrl = feed.imageUrl, let caption = feed.caption else {return}
        
        let items = [URL(string: imageUrl) as Any, caption] as [Any]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
        
    }
    func setupTableView() {
        tableView.register(UINib(nibName: "FeedDetailTableViewCell", bundle: nil), forCellReuseIdentifier: FeedDetailTableData.feedDetail.cellIdentifier)
        tableView.register(UINib(nibName: "FeedDetailImageTableViewCell", bundle: nil), forCellReuseIdentifier: FeedDetailTableData.feedDetailImage.cellIdentifier)
        tableView.register(UINib(nibName: "FeedDetailTextTableViewCell", bundle: nil), forCellReuseIdentifier: FeedDetailTableData.feedDetailText.cellIdentifier)
        tableView.register(UINib(nibName: "FeedDetailLikeShareTableViewCell", bundle: nil), forCellReuseIdentifier: FeedDetailTableData.feedDetailLikeShare.cellIdentifier)
        tableView.register(UINib(nibName: "FeedDetailCommentsTableViewCell", bundle: nil), forCellReuseIdentifier: FeedDetailTableData.feedDetailComments(comments: [""]).cellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(hex: "F1F1F1")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
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
//        guard let selectedFeed = feed else {
//                    return UITableViewCell()
//                }
        let data = tableData[indexPath.row]
        guard let moment = feed else { return UITableViewCell() }
        
        switch data {
        case .feedDetail:
            let cell = tableView.dequeueReusableCell(withIdentifier: "feedDetailCell") as! FeedDetailTableViewCell
            cell.setData(moment: moment)
            DataStore.shared.getUser(uid: moment.creatorId!) { (user, error) in
                if let error = error {
               self.showErrorWith(title: "Error", msg: error.localizedDescription)
               return
           }
                if let user = user {
                    self.title = user.fullName! + "'s Moment"
                }
                if let createdAt = moment.createdAt {
                    let date = Date(with: createdAt)
                    if let date = date {
                    cell.lblTime.text = date.timeAgoDisplay()
                    }
                }
            }
            cell.selectionStyle = .none
            return cell
            
        case .feedDetailImage:
            let cell = tableView.dequeueReusableCell(withIdentifier: "feedDetailImageCell") as! FeedDetailImageTableViewCell
            if let momentImage = moment.imageUrl {
                cell.imageHolder.kf.setImage(with: URL(string: momentImage))
            }
            cell.selectionStyle = .none
            return cell
            
        case .feedDetailText:
            let cell = tableView.dequeueReusableCell(withIdentifier: "feedDetailTextCell") as! FeedDetailTextTableViewCell
            cell.lblCaption.text = moment.caption
            if let createdAt = moment.createdAt {
                let date = Date(with: createdAt)
                if let date = date {
                cell.lblTime.text = date.timeAgoDisplay()
                }
            }
            cell.selectionStyle = .none
            return cell
            
        case .feedDetailLikeShare:
            let cell = tableView.dequeueReusableCell(withIdentifier: "feedDetailLikeShareCell") as! FeedDetailLikeShareTableViewCell
            cell.lblLikeCount.text = "\(moment.likeCount ?? 0)"
            cell.lblShareCount.text = "\(moment.shareCount ?? 0)"
            cell.selectionStyle = .none
            return cell
            
        case .feedDetailComments:
            let cell = tableView.dequeueReusableCell(withIdentifier: "feedDetailsCommentsCell") as! FeedDetailCommentsTableViewCell
            cell.selectionStyle = .none
            return cell
        }
//        let cell = tableView.dequeueReusableCell(withIdentifier: data.cellIdentifier)
//        return getCellFor(data: data, feed: selectedFeed, cell: cell)
    }
//    private func getCellFor(data: FeedDetailTableData, feed: Feed, cell: UITableViewCell?) -> UITableViewCell {
//
//        let date = Date(with: feed.createdAt!)
//        switch data {
//        case .feedDetail:
//            guard let feedDetailCell = cell as? FeedDetailTableViewCell else {
//                return UITableViewCell()
//            }
//            DataStore.shared.getUser(uid: feed.creatorId!) { (user, error) in
//                if let error = error {
//               self.showErrorWith(title: "Error", msg: error.localizedDescription)
//               return
//           }
//                if let user = user {
//                    self.title = user.fullName! + "'s Moment"
//                    feedDetailCell.lblUserName.text = user.fullName
//                    feedDetailCell.userImage.kf.setImage(with: URL(string: user.imageUrl!))
//                }
//            }
//            feedDetailCell.lblTime.text = date?.timeAgoDisplay()
//            feedDetailCell.selectionStyle = .none
//            return feedDetailCell
//
//        case .feedDetailImage:
//            guard let feedDetailImageCell = cell as? FeedDetailImageTableViewCell else {
//                return UITableViewCell()
//            }
//
//            if let imageUrl = feed.imageUrl {
//                feedDetailImageCell.imageHolder.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "userPlaceholder"))
//            }
//            feedDetailImageCell.selectionStyle = .none
//            return feedDetailImageCell
//
//        case .feedDetailText:
//            guard let feedDetailTextCell = cell as? FeedDetailTextTableViewCell else {
//                return UITableViewCell()
//            }
//            feedDetailTextCell.lblCaption.text = feed.caption
//            feedDetailTextCell.lblTime.text = date?.timeAgoDisplay()
//            feedDetailTextCell.selectionStyle = .none
//            return feedDetailTextCell
//
//        case .feedDetailLikeShare:
//            guard let feedDetailLikeShareCell = cell as? FeedDetailLikeShareTableViewCell else {
//                return UITableViewCell()
//            }
//            feedDetailLikeShareCell.lblLikeCount.text = "\(feed.likeCount ?? 0)"
//            feedDetailLikeShareCell.lblShareCount.text = "\(feed.shareCount ?? 0)"
//            feedDetailLikeShareCell.selectionStyle = .none
//            return feedDetailLikeShareCell
//
//        case .feedDetailComments:
//            guard let feedDetailCommentsCell = cell as? FeedDetailCommentsTableViewCell else {
//                return UITableViewCell()
//            }
//            DataStore.shared.getUser(uid: feed.creatorId!) { (user, error) in
//                if let error = error {
//               self.showErrorWith(title: "Error", msg: error.localizedDescription)
//               return
//           }
//                if let user = user {
//                    self.title = user.fullName! + "'s Moment"
//                    feedDetailCommentsCell.lblUserName.text = user.fullName
//                    feedDetailCommentsCell.userImage.kf.setImage(with: URL(string: user.imageUrl!))
//                }
//            }
//            feedDetailCommentsCell.lblTime.text = date?.timeAgoDisplay()
////            feedDetailCommentsCell.lblComment.text
//            feedDetailCommentsCell.selectionStyle = .none
//            return feedDetailCommentsCell
//        }
//    }
}
