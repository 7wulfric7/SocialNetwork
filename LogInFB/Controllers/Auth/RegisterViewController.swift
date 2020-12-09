//
//  RegisterViewController.swift
//  LogInFB
//
//  Created by Deniz Adil on 11/4/20.
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var emailHolderView: UIView!
    @IBOutlet weak var passwordHolderView: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var confirmPasswordHolderView: UIView!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Create Account"
        setupBordersAndFileds()
        
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
        txtPassword.returnKeyType = .done
        
        confirmPasswordHolderView.layer.borderWidth = 1.0
        confirmPasswordHolderView.layer.borderColor = UIColor.gray.cgColor
        confirmPasswordHolderView.layer.cornerRadius = 8.0
        txtConfirmPassword.delegate = self
        txtConfirmPassword.returnKeyType = .continue
    }
    
    
    @IBAction func onProceed(_ sender: UIButton) {
        
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
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                let specificError = error as NSError
                if specificError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self.showErrorWith(title: "Error", msg: "E-mail already in use!")
                    return
                }
                if specificError.code == AuthErrorCode.weakPassword.rawValue {
                    self.showErrorWith(title: "Error", msg: "Your password is too weak!")
                    return
                }
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if let authResult = authResult {
                self.saveUser(uid: authResult.user.uid)
            }
        }
    }
    
    func saveUser(uid: String) {
        let user = User(id: uid)
        SVProgressHUD.show()
        DataStore.shared.setUserData(user: user) { (success, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if success {
//                self.continueToHomescreen()
                DataStore.shared.localUser = user
                self.continueToSetUpProfile()
            }
        }
    }
    
//    func continueToHomescreen() {
//        performSegue(withIdentifier: "homeSeque", sender: nil)
//        navigationController?.popToRootViewController(animated: false)
//    }
    func continueToSetUpProfile() {
        performSegue(withIdentifier: "setupProfileSegue", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setupProfileSegue" {
        let controller = segue.destination as! SetUpProfileViewController
            controller.state = .register
        }
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

