//
//  CreateNewPasswordViewController.swift
//  LogInFB
//
//  Created by Deniz Adil on 11/10/20.
//

import UIKit
import Firebase

class CreateNewPasswordViewController: UIViewController {
    
    @IBOutlet weak var newPasswordHolderView: UIView!
    @IBOutlet weak var confirmPasswordHolderView: UIView!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Create New Password"
        setupBordersAndFileds()
        
    }
    
    func setupBordersAndFileds() {
        newPasswordHolderView.layer.borderWidth = 1.0
        newPasswordHolderView.layer.borderColor = UIColor.gray.cgColor
        newPasswordHolderView.layer.cornerRadius = 8
        txtNewPassword.delegate = self
        txtNewPassword.returnKeyType = .done
        
        confirmPasswordHolderView.layer.borderWidth = 1.0
        confirmPasswordHolderView.layer.borderColor = UIColor.gray.cgColor
        confirmPasswordHolderView.layer.cornerRadius = 8
        txtConfirmPassword.delegate = self
        txtConfirmPassword.returnKeyType = .continue
    }
   
    @IBAction func onSave(_ sender: UIButton) {
        
        guard let newPassword = txtNewPassword.text, newPassword != "" else {
            showErrorWith(title: "Error", msg: "Please enter password")
            return
        }
        guard newPassword.count >= 6 else {
            showErrorWith(title: "Error", msg: "Password must contain at least 6 characters")
            return
        }
        guard let confirmPassword = txtConfirmPassword.text, confirmPassword != "" else {
            showErrorWith(title: "Error", msg: "Please enter the same password as above")
            return
        }
        
        performSegue(withIdentifier: "homeSegue", sender: nil)
    }
    


}
extension CreateNewPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
