////
////  OtherUsersViewController.swift
////  LogInFB
////
////  Created by Deniz Adil on 26.11.20.
////
//
//import UIKit
//import Kingfisher
//import CoreServices
//import SwiftPhotoGallery
//
//class OtherUsersViewController: UIViewController {
//
//    @IBOutlet weak var tableView: UITableView!
//   
//    var otherUsers: User?
//    
//    private let tableData: [ProfileViewTableData] = [.basicInfo, .aboutMe, .stats]
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//       title = "Selected User Profile"
//        setupTableView()
//        
//    }
//    private func setupTableView() {
//        tableView.register(UINib(nibName: "OtherBasicInfoTableViewCell", bundle: nil), forCellReuseIdentifier: ProfileViewTableData.basicInfo.cellIdentifier)
//        tableView.register(UINib(nibName: "OtherAboutTableViewCell", bundle: nil), forCellReuseIdentifier: ProfileViewTableData.aboutMe.cellIdentifier)
//        tableView.register(UINib(nibName: "OtherStatsTableViewCell", bundle: nil), forCellReuseIdentifier: ProfileViewTableData.stats.cellIdentifier)
//        tableView.tableFooterView = UIView()
//        tableView.separatorColor = UIColor(hex: "F1F1F1")
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.separatorInset = UIEdgeInsets.zero
//    }
//}
//
//extension OtherUsersViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let data = tableData[indexPath.row]
//        return data.cellHeight
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return tableData.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let user = otherUsers else {
//            return UITableViewCell()
//        }
//        let data = tableData[indexPath.row]
//        let cell = tableView.dequeueReusableCell(withIdentifier: data.cellIdentifier)
//        return getCellFor(data: data, user: user, cell: cell)
//    }
//    private func getCellFor(data: ProfileViewTableData, user: User, cell: UITableViewCell?) -> UITableViewCell {
//        switch data {
//        case .basicInfo:
//            guard let basicCell = cell as? OtherBasicInfoTableViewCell else {
//                return UITableViewCell()
//            }
//
//            basicCell.otherUsersFullName.text = user.fullName
//            basicCell.otherUsersOtherInfo.text = (user.gender ?? "") + ", " + (user.location ?? "")
//            if let imageUrl = user.imageUrl {
//                basicCell.otherUsersImage.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "userPlaceholder"))
//            }
//            basicCell.selectionStyle = .none
//
//            return basicCell
//        case .aboutMe:
//            guard let aboutCell = cell as? OtherAboutTableViewCell else {
//                return UITableViewCell()
//            }
//            aboutCell.aboutOtherUsers.text = user.aboutMe
//            aboutCell.selectionStyle = .none
//            return aboutCell
//        case .stats:
//            guard let statsCell = cell as? OtherStatsTableViewCell else {
//                return UITableViewCell()
//            }
//            statsCell.otherMomentsNumbers.text = "\(user.moments ?? 0)"
//            statsCell.otherFollowersNumbers.text = "\(user.followers ?? 0)"
//            statsCell.otherFollowingNumners.text = "\(user.following ?? 0)"
//            
//            statsCell.selectionStyle = .none
//            return statsCell
//        case .myMoments:
//            return UITableViewCell()
//        }
//    }
//}
