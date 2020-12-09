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


class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblNoResults: UILabel!
    @IBOutlet weak var btnPost: UIButton!
  
    var refreshControl = UIRefreshControl()
    var feedItems = [Feed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchFeedItems()
    }
    
    func setupCollectionView() {
        collectionView.register(UINib(nibName: "MyFeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyFeedCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: collectionView.frame.width, height: 200)
            layout.estimatedItemSize = CGSize(width: collectionView.frame.width, height: 200)
        }
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
//        Deniz:
//        collectionView.refreshControl = UIRefreshControl()
//        collectionView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
//    @objc private func didPullToRefresh() {
//        fetchFeedItems()
//    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        fetchFeedItems(isRefresh: true)
    }
    private func fetchFeedItems(isRefresh: Bool = false) {
        SVProgressHUD.show()
        if isRefresh {
            feedItems.removeAll()
        }
        DataStore.shared.fetchFeedItems { (feeds, error) in
            SVProgressHUD.dismiss()
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if let feeds = feeds {
                self.feedItems = feeds
                if feeds.count == 0 {
                    self.lblNoResults.isHidden = false
                } else {
                    self.lblNoResults.isHidden = true
                }
//   Deniz       self.feedItems.sort(by: {$0.createdAt! > $1.createdAt!})
                self.collectionView.refreshControl?.endRefreshing()
                self.sortAndReload()
            }
        }
    }
    private func openFeedFor(feed: Feed) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "FeedDetailViewController") as! FeedDetailViewController
        controller.feed = feed
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func sortAndReload() {
        self.feedItems.sort { (feedOne, feedTwo) -> Bool in
            guard let oneDate = feedOne.createdAt else { return false }
            guard let twoDate = feedTwo.createdAt else { return false }
            return oneDate > twoDate
        }
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyFeedCollectionViewCell", for: indexPath) as! MyFeedCollectionViewCell
        let feed = feedItems[indexPath.row]
        cell.setupCell(feedItem: feed)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let feed = feedItems[indexPath.row]
        openFeedFor(feed: feed)
    }
}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 200)
    }
}
