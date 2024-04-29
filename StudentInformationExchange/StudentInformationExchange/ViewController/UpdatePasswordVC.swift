//
//  UpdatePasswordVC.swift
//  StudentInformationExchange
//
//  Created by Macbook-Pro on 26/11/23.
//

import UIKit

class UpdatePasswordVC: UIViewController {
    @IBOutlet weak var oldpassword: UITextField!
    @IBOutlet weak var newpassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!

    var password = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        FireStoreManager.shared.getPassword(email: UserDefaultsManager.shared.getEmail(), password: "") { getpassword in
            self.password = getpassword.base64Decoded()
        }
        
    }
    
    @IBAction func onChangePassword(_ sender: Any) {
        if validate(){
            if(self.oldpassword.text! != self.password) {
                showAlerOnTop(message: "Please enter correct current password")
                return
            }
            else {
                let documentid = UserDefaults.standard.string(forKey: "documentId") ?? ""
                let userdata = ["password": (self.newpassword.text ?? "").base64Encoded()]
                FireStoreManager.shared.updatePassword(documentid: documentid, userData: userdata) { success in
                    if success {
                        showAlerOnTop(message: "Password Updated Successfully.")
                        
                        let body = "<h1>Your password has been changed</h1>";
        
                        let email = UserDefaultsManager.shared.getEmail()
                        
                        ForgetPasswordManager.sendPasswordChangedEmail(emailTo: email, body: body) { value in}
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func validate() ->Bool {
        
        if(self.oldpassword.text!.isEmpty) {
             showAlerOnTop(message: "Please enter current password.")
            return false
        }
        if(self.newpassword.text!.isEmpty) {
             showAlerOnTop(message: "Please enter new password.")
            return false
        }
        if(self.confirmPassword.text!.isEmpty) {
             showAlerOnTop(message: "Please enter confirm password.")
            return false
        }
        
           if(self.newpassword.text! != self.confirmPassword.text!) {
             showAlerOnTop(message: "Password doesn't match")
            return false
        }
        
        
        return true
    }
    
    
    @IBAction func onShowHidePassword(_ sender: UIButton) {
        
        if(sender.tag == 1) {
            let buttonImageName = oldpassword.isSecureTextEntry ? "eye" : "eye.slash"
                if let buttonImage = UIImage(systemName: buttonImageName) {
                    sender.setImage(buttonImage, for: .normal)
            }
            self.oldpassword.isSecureTextEntry.toggle()
        }
       
        if(sender.tag == 2) {
            let buttonImageName = newpassword.isSecureTextEntry ? "eye" : "eye.slash"
                if let buttonImage = UIImage(systemName: buttonImageName) {
                    sender.setImage(buttonImage, for: .normal)
            }
            self.newpassword.isSecureTextEntry.toggle()
        }
        
        if(sender.tag == 3) {
            let buttonImageName = confirmPassword.isSecureTextEntry ? "eye" : "eye.slash"
                if let buttonImage = UIImage(systemName: buttonImageName) {
                    sender.setImage(buttonImage, for: .normal)
            }
            self.confirmPassword.isSecureTextEntry.toggle()
        }
       
    }
    
    
}
