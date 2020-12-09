//
//  WelcomeViewController.swift
//  LogInFB
//
//  Created by Deniz Adil on 11/2/20.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SVProgressHUD

class WelcomeViewController: UIViewController {
    
    
    @IBOutlet weak var imageHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var createAccountBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emailHolderView: UIView!
    @IBOutlet weak var passwordHolderView: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = Auth.auth().currentUser {
            getLocalUserData(uid: user.uid)
            return
        }
        setConstraintsForSmallerDevices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setConstraintsForSmallerDevices() {
        if DeviceType.IS_IPHONE_6 {
            imageTopConstraint.constant = 60
            createAccountBottomConstraint.constant = 70
        } else if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            imageTopConstraint.constant = 40
            imageWidthConstraint.constant = imageWidthConstraint.constant / 2.0
            imageHightConstraint.constant = imageHightConstraint.constant / 2.0
            createAccountBottomConstraint.constant = 40
        }
    }
    func setupBordersAndFileds() {
        emailHolderView.layer.borderWidth = 1.0
        emailHolderView.layer.borderColor = UIColor.black.cgColor
        emailHolderView.layer.cornerRadius = 8
        txtEmail.delegate = self
        txtEmail.returnKeyType = .done

        passwordHolderView.layer.borderWidth = 1.0
        passwordHolderView.layer.borderColor = UIColor.black.cgColor
        passwordHolderView.layer.cornerRadius = 8
        txtPassword.delegate = self
        txtPassword.returnKeyType = .continue
    }
//    func showErrorWith(title: String?, msg: String?) {
//        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
//        let confirm = UIAlertAction(title: "OK", style: .default, handler: nil)
//
//        alert.addAction(confirm)
//        present(alert, animated: true, completion: nil)
//    } //ja ima funkcijata vo extension vo poseben file
    
    func userDidLogin(token: String) {
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let authResult = authResult {
                let user = authResult.user
                print(user)
                self.getLocalUserData(uid: user.uid)
            }
        }
    }
        func getLocalUserData(uid: String) {
            SVProgressHUD.show()
            DataStore.shared.getUser(uid: uid) { (user, error) in
                SVProgressHUD.dismiss()
                     if let error = error {
                    self.showErrorWith(title: "Error", msg: error.localizedDescription)
                    return
                }
                if let user = user {
                    DataStore.shared.localUser = user
                    self.continueToHomescreen()
                }
            }
            
        }
    
    func continueToHomescreen() {
        performSegue(withIdentifier: "homeSegue", sender: nil)
    }
    
    
    @IBAction func onFacebook(_ sender: UIButton) {
        let manager = LoginManager()
        
        manager.logIn(permissions: ["public_profile","email"], from: self) { (loginResults, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let result = loginResults, !result.isCancelled, let token = result.token {
                    self.userDidLogin(token: token.tokenString)
                } else {
                    print("User cancelled flow")
                }
            }
        }
    }
    
    @IBAction func onRegister(_ sender: UIButton) {
        performSegue(withIdentifier: "registerSegue", sender: nil)
    }
    
    @IBAction func onLogIn(_ sender: UIButton) {
        guard let email = txtEmail.text, email != "" else {
            showErrorWith(title: "Error", msg: "Please enter your e-mail")
            return
        }
        guard let password = txtPassword.text, password != "" else {
            showErrorWith(title: "Error", msg: "Please enter password")
            return
        }
        guard email.isValidEmail() else {
            showErrorWith(title: "Error", msg: "Please enter a valid e-mail")
            return
        }
        guard password.count >= 6 else {
            showErrorWith(title: "Error", msg: "Password must contain at least 6 characters")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            if let error = error {
                let specificError = error as NSError
                if specificError.code == AuthErrorCode.invalidEmail.rawValue {
                    self!.showErrorWith(title: "Error", msg: "Invalid E-mail address!")
                    return
                }
                if specificError.code == AuthErrorCode.wrongPassword.rawValue {
                    self!.showErrorWith(title: "Error", msg: "Invalid password!")
                    return
                }
                self!.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if let authResult = authResult {
                self!.continueToHomescreen()
            }
        }
    }
    
    @IBAction func onSIgnIn(_ sender: UIButton) {
        performSegue(withIdentifier: "signInSegue", sender: nil)
    }
}


extension WelcomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
