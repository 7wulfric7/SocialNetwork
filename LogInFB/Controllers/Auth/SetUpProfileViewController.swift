//
//  SetUpProfileViewController.swift
//  LogInFB
//
//  Created by Deniz Adil on 11/11/20.
//

import UIKit
import Firebase
import SVProgressHUD
import FirebaseAuth

enum SetupProfileState {
    case register
    case signin
    case editProfile
}

class SetUpProfileViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var fullNameHolderView: UIView!
    @IBOutlet weak var dateOfBirthHoderView: UIView!
    @IBOutlet weak var genderHolderView: UIView!
    @IBOutlet weak var locationHolderView: UIView!
    @IBOutlet weak var aboutMeHolderiew: UIView!
    
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtDateOfBirth: UITextField!
    @IBOutlet weak var txtGender: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var txtAboutMe: UITextField!
    
    @IBOutlet weak var btnSave: UIButton!
    
    var state: SetupProfileState = .register
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Set Up Profile"
        setupBordersAndFileds()
        if state != .editProfile {
        reorderNavigation()
        } else if state == .editProfile {
            setupViewForEdit()
        }
        createDatePicker()
    }
    private func setupViewForEdit() {
        
        guard let localUser = DataStore.shared.localUser else { return }
        btnSave.setTitle("Save profile", for: .normal)
        txtFullName.text = localUser.fullName
        txtGender.text = localUser.gender
        txtLocation.text = localUser.location
        txtDateOfBirth.text = localUser.dob
        txtAboutMe.text = localUser.aboutMe
    }
    
    func createDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneBtnPressed))
        toolbar.setItems([doneBtn], animated: true)
        txtDateOfBirth.inputAccessoryView = toolbar
        txtDateOfBirth.inputView = datePicker
        datePicker.datePickerMode = .date
    }
    @objc func doneBtnPressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        txtDateOfBirth.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    func reorderNavigation() {
        var controllers = [UIViewController]()
        navigationController?.viewControllers.forEach({ (controller) in
            if !(controller is RegisterViewController) {
                controllers.append(controller)
            }
        })
        navigationController?.setViewControllers(controllers, animated: false)
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
    
    func setupBordersAndFileds() {
        fullNameHolderView.layer.borderWidth = 1.0
        fullNameHolderView.layer.borderColor = UIColor.gray.cgColor
        fullNameHolderView.layer.cornerRadius = 8
        txtFullName.delegate = self
        txtFullName.returnKeyType = .done
        
        dateOfBirthHoderView.layer.borderWidth = 1.0
        dateOfBirthHoderView.layer.borderColor = UIColor.gray.cgColor
        dateOfBirthHoderView.layer.cornerRadius = 8
        txtDateOfBirth.delegate = self
        txtDateOfBirth.returnKeyType = .done
        
        genderHolderView.layer.borderWidth = 1.0
        genderHolderView.layer.borderColor = UIColor.gray.cgColor
        genderHolderView.layer.cornerRadius = 8.0
        txtGender.delegate = self
        txtGender.returnKeyType = .done
        
        locationHolderView.layer.borderWidth = 1.0
        locationHolderView.layer.borderColor = UIColor.gray.cgColor
        locationHolderView.layer.cornerRadius = 8.0
        txtLocation.delegate = self
        txtLocation.returnKeyType = .done
        
        aboutMeHolderiew.layer.borderWidth = 1.0
        aboutMeHolderiew.layer.borderColor = UIColor.gray.cgColor
        aboutMeHolderiew.layer.cornerRadius = 8.0
        txtAboutMe.delegate = self
        txtAboutMe.returnKeyType = .done
    }
    func getUser() -> User? {
        guard let localUser = DataStore.shared.localUser else {
            return nil
        }
        return localUser
    }
    func createUser() -> User? {
        guard let user = Auth.auth().currentUser else { return nil }
        let localUser = User(id: user.uid)
        return localUser
    }
    
    private func saveUserProfile() {
        var user = getUser()
        var shouldUpdate = false
        if user?.fullName != txtFullName.text {
            shouldUpdate = true
            user?.fullName = txtFullName.text
        } else if user?.dob != txtDateOfBirth.text {
            shouldUpdate = true
            user?.dob = txtDateOfBirth.text
        } else if user?.aboutMe != txtAboutMe.text {
            shouldUpdate = true
            user?.aboutMe = txtAboutMe.text
        } else if user?.gender != txtGender.text {
            shouldUpdate = true
            user?.gender = txtGender.text
        } else if user?.location != txtLocation.text {
            shouldUpdate = true
            user?.location = txtLocation.text
        }
        saveUser(user: user!)
    }
    
    @IBAction func onGetSetGo(_ sender: UIButton) {
       
        var user: User?
        switch state {
        case .signin:
            user = createUser()
        case .register:
            user = getUser()
        case .editProfile:
            saveUserProfile()
        return
        }
        
        guard var localUser = user else {
            showErrorWith(title: "Error", msg: "User does not exist")
            navigationController?.popToRootViewController(animated: true)
            return
        }
        localUser.fullName = txtFullName.text
        localUser.aboutMe = txtAboutMe.text
        localUser.gender = txtGender.text
        localUser.dob = txtDateOfBirth.text
        localUser.location = txtLocation.text
        guard let fullName = txtFullName.text, fullName != "" else {
            showErrorWith(title: "Error", msg: "Please enter your full name")
            return
        }
        guard let dateOfBirth = txtDateOfBirth.text, dateOfBirth != "" else {
            showErrorWith(title: "Error", msg: "Please choose your date of birth")
            return
        }
        saveUser(user: localUser)
    }
    private func saveUser(user: User) {
        SVProgressHUD.show()
        DataStore.shared.setUserData(user: user) { (success, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if success {
                DataStore.shared.localUser = user
                if self.state != .editProfile {
                    self.performSegue(withIdentifier: "homeSegue", sender: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
//    func continueToHomescreen() {
//        performSegue(withIdentifier: "homeSegue", sender: nil)
//        navigationController?.popToRootViewController(animated: false)
//    }
//}
extension SetUpProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
