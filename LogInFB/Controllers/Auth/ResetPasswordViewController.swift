//
//  ResetPasswordViewController.swift
//  LogInFB
//
//  Created by Deniz Adil on 11/10/20.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailHolderView: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Reset Password"
        setupBordersAndFileds()
    }
    func setupBordersAndFileds() {
        emailHolderView.layer.borderWidth = 1.0
        emailHolderView.layer.borderColor = UIColor.gray.cgColor
        emailHolderView.layer.cornerRadius = 8
        txtEmail.delegate = self
        txtEmail.returnKeyType = .done
    }

    @IBAction func onSendLink(_ sender: UIButton) {
        guard let email = txtEmail.text, email != "" else {
            showErrorWith(title: "Error", msg: "Please enter your e-mail")
            return
        }
        guard email.isValidEmail() else {
            showErrorWith(title: "Error", msg: "Please enter a valid e-mail")
            return
        }
        self.continueToCreateNewPassword()
    }
    func continueToCreateNewPassword() {
        performSegue(withIdentifier: "createNewPasswordSegue", sender: nil)
    }
    
}
extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
