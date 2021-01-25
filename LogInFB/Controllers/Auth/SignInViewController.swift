//
//  SignInViewController.swift
//  LogInFB
//
//  Created by Deniz Adil on 11/9/20.
//

import UIKit
import Firebase
import SVProgressHUD
import CoreServices
import SwiftPhotoGallery

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailHolderView: UIView!
    @IBOutlet weak var passwordHolderView: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign In"
        setupBordersAndFileds()
        setCustomBackButton()
    }
    
    func setCustomBackButton() {
        let back = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 30))
        back.setImage(UIImage(named: "BackButton"), for: .normal)
        back.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackButton"), style: .plain, target: self, action: #selector(onBack))
    }
    
    func setupBordersAndFileds() {
        emailHolderView.layer.borderWidth = 1.0
        emailHolderView.layer.borderColor = UIColor.gray.cgColor
        emailHolderView.layer.cornerRadius = 8
        txtEmail.delegate = self
        txtEmail.returnKeyType = .done
        
        passwordHolderView.layer.borderWidth = 1.0
        passwordHolderView.layer.borderColor = UIColor.gray.cgColor
        passwordHolderView.layer.cornerRadius = 8
        txtPassword.delegate = self
        txtPassword.returnKeyType = .continue
    }
    
    @objc func onBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onResetPassword(_ sender: UIButton) {
        performSegue(withIdentifier: "resetPasswordSegue", sender: nil)
    }
    
    @IBAction func onGoToFeed(_ sender: UIButton) {
        
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
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            SVProgressHUD.dismiss()
            if let error = error {
                let specificError = error as NSError
                
                if specificError.code == AuthErrorCode.invalidEmail.rawValue && specificError.code == AuthErrorCode.wrongPassword.rawValue {
                    self.showErrorWith(title: "Error", msg: "Incorrect e-mail or password")
                    return
                }
                if specificError.code == AuthErrorCode.userDisabled.rawValue {
                    self.showErrorWith(title: "Error", msg: "Your account was disabled!")
                    return
                }
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if let authResult = authResult {
                self.getLocalUserData(uid: authResult.user.uid)
                
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
                self.continueToHome()
                return
            }
            self.continueToSetUsetProfile()
        }
        
    }
    func continueToHome() {
        //MainTabBar
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "MainTabBar")
        present(controller, animated: true, completion: nil)
        navigationController?.popToRootViewController(animated: false)
    }
    
    func continueToSetUsetProfile() {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "SetUpProfileViewController") as! SetUpProfileViewController
        controller.state = .signin
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

