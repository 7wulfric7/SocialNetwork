//
//  ProfileViewController.swift
//  LogInFB
//
//  Created by Deniz Adil on 16.11.20.
//

import UIKit
import Kingfisher
import CoreServices
import SwiftPhotoGallery
import SVProgressHUD

enum ProfileViewTableData: Equatable {
    case basicInfo
    case aboutMe
    case stats
    case myMoments
    
    var cellIdentifier: String {
        switch self {
        case .basicInfo:
            return "basicInfoCell"
        case .aboutMe:
            return "aboutMeCell"
        case .stats:
            return "statsCell"
        case .myMoments:
            return ""
        }
    }
    var cellHeight: CGFloat {
        switch self {
        case .basicInfo:
            return 95
        case .aboutMe:
            return 95
        case .stats:
            return 95
        case .myMoments:
            return 95
        }
    }
    
    static func == (lhs: ProfileViewTableData, rhs: ProfileViewTableData) -> Bool {
        switch (lhs, rhs) {
        case (.basicInfo, .basicInfo):
            return true
        case (.aboutMe, .aboutMe):
            return true
        case (.stats, .stats):
            return true
        case (.myMoments, .myMoments):
            return true
        default:
            return false
        }
    }
}

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let tableData: [ProfileViewTableData] = [.basicInfo, .aboutMe, .stats]
    private var pickedImage: UIImage?
    
    var user: User?
    private var galleryImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        if user == nil {
            setupNewPostButton()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: Notification.Name("ReloadAfterUserAction"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupNewPostButton() {
        let button = UIButton()
        button.setImage(UIImage(named: "NoteIcon"), for: .normal)
        button.setTitle(nil, for: .normal)
        button.addTarget(self, action: #selector(onEditProfile), for: .touchUpInside)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: button)]
        
       // navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    private func setupTableView() {
        tableView.register(UINib(nibName: "BasicInfoTableViewCell", bundle: nil), forCellReuseIdentifier: ProfileViewTableData.basicInfo.cellIdentifier)
        tableView.register(UINib(nibName: "AboutMeTableViewCell", bundle: nil), forCellReuseIdentifier: ProfileViewTableData.aboutMe.cellIdentifier)
        tableView.register(UINib(nibName: "StatsTableViewCell", bundle: nil), forCellReuseIdentifier: ProfileViewTableData.stats.cellIdentifier)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(hex: "F1F1F1")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets.zero
    }
    @objc func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            self.tableView.reloadData()

        }
    }
    @objc func onEditProfile() {
        let storyBoard = UIStoryboard(name: "Auth", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "SetUpProfileViewController") as! SetUpProfileViewController
        controller.state = .editProfile
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    private func openEditImageSheet() {
        let actionSheet = UIAlertController(title: "Edit image", message: "Plaese pick an image", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { _ in
            self.openImagePicker(sourceType: .camera)
        }
        let library = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(camera)
        actionSheet.addAction(library)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        if sourceType == .camera {
            imagePicker.cameraDevice = .front
        }
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    private func uploadImage(image: UIImage) {
        guard var user = DataStore.shared.localUser, let userId = user.id else {
            return
        }
        DataStore.shared.uploadImage(image: image, itemId: userId) { (url, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let url = url {
                user.imageUrl = url.absoluteString
                DataStore.shared.setUserData(user: user) { (_, _) in }
            }
        }
    }
}

extension ProfileViewController: BasicinfoCellDelegate {
    func reloadFollowCount() {
//        if let indec = tableData.firstIndex(where: { $0 == .stats }) {
//
//        }
        //because we have Equitable we can fetch index of object instead of comparing
        if let index = tableData.firstIndex(of: .stats) {
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
        
    }
    
//    func didFollowUsers(user: User?, isFollowed: Bool) {
//        guard var localUser = DataStore.shared.localUser, let userId = user?.id else {return}
//        if localUser.followingUsersID == nil {
//            localUser.followingUsersID = [String]()
//        }
//        if isFollowed {
//            localUser.followingUsersID?.append(userId)
//        } else {
//            localUser.followingUsersID?.removeAll(where: {$0 == user?.id})
//        }
//        localUser.save{ (_, _) in
//            self.tableView.reloadData()
//        NotificationCenter.default.post(name: Notification.Name("ReloadFeedAfterUserAction"), object: nil)
//        }
//    }

    func didClickOnEditImage() {
        openEditImageSheet()
    }
    
    func didTapOnUserImage(user: User?, image: UIImage?) {
        if let image = image {
            let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
            gallery.hidePageControl = true
            gallery.modalPresentationStyle = .fullScreen
            galleryImages.removeAll()
            galleryImages.append(image)
            present(gallery, animated: true, completion: nil)
        }
    }
}
extension ProfileViewController: SwiftPhotoGalleryDelegate, SwiftPhotoGalleryDataSource {
    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        gallery.dismiss(animated: true, completion: nil)
    }
    
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return galleryImages.count
    }
    
    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        let image = galleryImages[forIndex]
        return image
        // OR LIKE THIS:
//        return galleryImages[forIndex]
    }
}
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            self.pickedImage = image
            self.uploadImage(image: image)
            self.tableView.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .automatic)
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection selection: Int) -> Int {
        return tableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let localUser = DataStore.shared.localUser else {
            return UITableViewCell()
        }
        let data = tableData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: data.cellIdentifier)
        
      
        // IF method as follows:
//        if self.user != nil {
//            return getCellFor(data: data, user:self.user!, cell: cell)
//        } else {
//            return getCellFor(data: data, user:localUser, cell: cell)
//        }
        // short IF method as follows:
        return getCellFor(data: data, user: (self.user != nil ? self.user! : localUser), cell: cell)
    }
    private func getCellFor(data: ProfileViewTableData, user: User, cell: UITableViewCell?) -> UITableViewCell {
        switch data {
        case .basicInfo:
            guard let basicCell = cell as? BasicInfoTableViewCell else {
                return UITableViewCell()
            }
            DataStore.shared.getUser(uid: user.id!) { (user, error) in
                if let error = error {
               self.showErrorWith(title: "Error", msg: error.localizedDescription)
               return
           }
                let myID = user?.id
                let myself = DataStore.shared.localUser?.id
                if myID == myself {
                    self.title = "You"
                } else if let user = user {
                    self.title = user.fullName! + "'s Profile"
                }
            }
            basicCell.profileImage.image = pickedImage
            basicCell.selectionStyle = .none
            basicCell.delegate = self
            basicCell.setData(user: user)
            return basicCell
        case .aboutMe:
            guard let aboutCell = cell as? AboutMeTableViewCell else {
                return UITableViewCell()
            }
            aboutCell.lblAboutMe.text = user.aboutMe
            aboutCell.selectionStyle = .none
            return aboutCell
        case .stats:
            guard let statsCell = cell as? StatsTableViewCell else {
                return UITableViewCell()
            }
            
            statsCell.lblMomentsNumbers.text = "\(user.moments ?? 0)"
            statsCell.userId = user.id
            statsCell.setCounts()
//            statsCell.lblFollowersNumbers.text = "\(user.followers ?? 0)"
//            statsCell.lblFollowingNumbers.text = "\(user.followingUsersID?.count ?? 0)"
            statsCell.selectionStyle = .none
            statsCell.delegate = self
            return statsCell
        case .myMoments:
            return UITableViewCell()
        }
    }
}
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
}
extension ProfileViewController: StatsTableViewDelegate {
    func didClickOnFollowing() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SearchUsersViewController") as! SearchUsersViewController
        controller.state = .following
        controller.follow = FollowManager.shared.following
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didClickOnFollowers() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SearchUsersViewController") as! SearchUsersViewController
        controller.state = .followers
        controller.follow = FollowManager.shared.followers
        navigationController?.pushViewController(controller, animated: true)
    }
}
