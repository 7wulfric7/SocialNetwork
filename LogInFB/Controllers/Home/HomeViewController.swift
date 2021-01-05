//
//  HomeViewController.swift
//  LogInFB
//
//  Created by Deniz Adil on 11/2/20.
//

import UIKit
import Firebase
import CoreServices
import SVProgressHUD
import FirebaseFirestore

enum CollectionData: Equatable {
    case feedItems([Feed])
    case loading
    static func == (lhs: CollectionData, rhs: CollectionData) -> Bool {
        switch (lhs, rhs) {
        case (.feedItems(_), .feedItems(_)):
            return true
        case (.loading, .loading):
            return true
        default:
            return false
        }
    }
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblNoResults: UILabel!
    @IBOutlet weak var btnPost: UIButton!
  
    var refreshControl = UIRefreshControl()
    var feedItems = [Feed]()
    private var collectionData: [CollectionData] = [.feedItems([])]
    
    private var pageSize = 5
    private var lastFeedDocument: DocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        customizeButton(btnPost: btnPost)
        setupCollectionView()
        fetchFeedItems()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: Notification.Name("ReloadFeedAfterUserAction"), object: nil)
    }
    func customizeButton(btnPost: UIButton) {
        btnPost.layer.shadowColor = UIColor(red: 0.102, green: 0.102, blue: 0.102, alpha: 0.20).cgColor
        btnPost.layer.shadowOpacity = 0.9
        btnPost.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
    }
    func setupCollectionView() {
        collectionView.register(LoadingCollectionViewCell.self, forCellWithReuseIdentifier: "LoadingCollectionViewCell")
        collectionView.register(UINib(nibName: "MyFeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyFeedCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: collectionView.frame.width, height: 200)
            layout.estimatedItemSize = CGSize(width: collectionView.frame.width, height: 200)
        }
//        collectionView.refreshControl = refreshControl
//        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
//        Deniz:
//        collectionView.refreshControl = UIRefreshControl()
//        collectionView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
//    @objc private func didPullToRefresh() {
//        fetchFeedItems()
//    }
//
    @objc func reloadFeedNotification() {
        guard let localUser = DataStore.shared.localUser,
        let blockedUsers = localUser.blockedUsersID else { return }
        feedItems = feedItems.filter({ !blockedUsers.contains($0.creatorId!) })
        collectionView.reloadData()
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        fetchFeedItems(isRefresh: true)
    }
    private func fetchFeedItems(isRefresh: Bool = false) {
        SVProgressHUD.show()
        if isRefresh {
            lastFeedDocument = nil
            feedItems.removeAll()
        }
        DataStore.shared.fetchFeedItems(pageSize: pageSize, lastDocument: lastFeedDocument) { (feeds, error, lastDocument)  in
            SVProgressHUD.dismiss()
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            self.lastFeedDocument = lastDocument
            self.collectionData.removeAll()
            if let feeds = feeds {
                let filterFeeds = self.filterBlockedUsers(feeds: feeds)
                self.feedItems.append(contentsOf: filterFeeds)
                self.collectionData.append(.feedItems(self.feedItems))
                if self.feedItems.count == 0 {
                    self.lblNoResults.isHidden = false
                } else {
                    self.lblNoResults.isHidden = true
                }
                if feeds.count == self.pageSize {
                    self.collectionData.append(.loading)
                }
                self.collectionView.reloadData()
//                self.sortAndReload()
            }
        }
    }
    private func openFeedFor(feed: Feed) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FeedDetailViewController") as! FeedDetailViewController
        controller.feed = feed
        self.navigationController?.pushViewController(controller, animated: true)
    }
    private func filterBlockedUsers(feeds: [Feed]) -> [Feed] {
        guard let localUser = DataStore.shared.localUser else {
            return feeds
            
        }
        return feeds.filter { (feed) -> Bool in
            guard let creatorId = feed.creatorId else {return true}
            return !localUser.isBlockedUserWith(id: creatorId)
        }
    }
    func sortAndReload() {
        self.feedItems.sort { (feedOne, feedTwo) -> Bool in
            guard let oneDate = feedOne.createdAt else { return false }
            guard let twoDate = feedTwo.createdAt else { return false }
            return oneDate > twoDate
        }
        reloadFeedNotification()
        collectionView.reloadData()
    }
    
    @IBAction func onNewPost(_ sender: UIButton) {
        openImagePickerSheet()
    }
    
    private func openImagePickerSheet() {
        let actionSheet = UIAlertController(title: "Post moment", message: "Plaese pick an image for your moment", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.openImagePicker(sourceType: .camera)
            }
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
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        if sourceType == .camera {
            imagePicker.cameraDevice = .front
        }
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    private func openCreateMomentWith(image: UIImage) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CreateMomentViewController") as! CreateMomentViewController
        controller.pickedImage = image
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension HomeViewController: CreateMomentDelegate {
    func didPostItem(item: Feed) {
        feedItems.append(item)
        sortAndReload()
    }
}
extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            picker.dismiss(animated: true) {
                self.openCreateMomentWith(image: image)
            }
        }
    }
}
extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is LoadingCollectionViewCell {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              self.fetchFeedItems()
          }
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            let data = collectionData[section]
            switch data {
            case .loading:
                return 1
            case .feedItems(let feedItems):
                return feedItems.count
            }
        }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = collectionData[indexPath.section]
        switch data {
        case .feedItems(let items):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyFeedCollectionViewCell", for: indexPath) as! MyFeedCollectionViewCell
            let feed = items[indexPath.row]
            cell.setupCell(feedItem: feed)
            return cell
            
        case .loading:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.isHidden = false
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let feed = feedItems[indexPath.row]
        openFeedFor(feed: feed)
    }
}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = collectionData[indexPath.section]
        switch data {
        case .loading:
            return CGSize(width: collectionView.frame.width, height: 70)
        default:
            return CGSize(width: collectionView.frame.width, height: 200)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let feed = feedItems[indexPath.row]
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FeedDetailViewController") as! FeedDetailViewController
        controller.feed = feed
        navigationController?.pushViewController(controller, animated: true)
    }
}
