//
//  CreateMomentViewController.swift
//  LogInFB
//
//  Created by Deniz Adil on 30.11.20.
//

import UIKit
import SVProgressHUD

protocol CreateMomentDelegate: class {
    func didPostItem(item: Feed)
}

class CreateMomentViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var captionHolderView: UIView!

    @IBOutlet weak var locationHolderView: UIView!
    
    @IBOutlet weak var tagPeopleHolderView: UIView!
    
    @IBOutlet weak var txtCaption: UITextField!
    @IBOutlet weak var txtPeople: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnPost: UIButton!
    
    var pickedImage: UIImage?
    
    weak var delegate: CreateMomentDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       setupViews()
    }
    

    private func setupViews() {
        
        txtCaption.delegate = self
        txtPeople.delegate = self
        txtLocation.delegate = self
        
        imageView.image = pickedImage
        
        btnSave.layer.borderWidth = 1.0
        btnSave.layer.borderColor = UIColor(named: "MainPink")?.cgColor
        btnSave.layer.cornerRadius = 8
        btnSave.layer.masksToBounds = true
        
        btnPost.layer.cornerRadius = 8
        btnPost.layer.masksToBounds = true
        
        tagPeopleHolderView.layer.borderColor = UIColor(hex: "#F1F1F1")?.cgColor
        tagPeopleHolderView.layer.borderWidth = 1
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setKeyboardObservers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    func setKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func keyboardDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
    }
    @objc func keyboardDidHide(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = .zero
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func onNewPost(_ sender: UIButton) {
        guard let caption = txtCaption.text?.trimmingCharacters(in: .whitespacesAndNewlines), caption != "" else {
            showErrorWith(title: "Error", msg: "Moment must have caption")
            return
        }
        guard let localUser = DataStore.shared.localUser else {
            return
        }
        
        guard let pickedImage = pickedImage else {
            showErrorWith(title: "Error", msg: "Image not found")
            return
        }
        var moment = Feed()
        moment.caption = caption
        moment.creatorId = localUser.id
        moment.createdAt = Date().toMiliseconds()
        SVProgressHUD.show()
        // To generate 128bit identifier
        let uuid = UUID().uuidString
        DataStore.shared.uploadImage(image: pickedImage, itemId: uuid, isUserImage: false) { (url, error) in
            if let error = error {
                SVProgressHUD.dismiss()
                print(error.localizedDescription)
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if let url = url {
                moment.imageUrl = url.absoluteString
                DataStore.shared.createFeedItem(item: moment) { (feer, error) in
                    if let error = error {
                        self.showErrorWith(title: "Error", msg: error.localizedDescription)
                        return
                    }
                    self.delegate?.didPostItem(item: moment)
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            SVProgressHUD.dismiss()
        }
    }
}
