//
//  ForgotPasswordVC.swift
//  StudentInformationExchange
//
//  Created by Macbook-Pro on 21/11/23.

import UIKit

class ForgotPasswordVC: UIViewController {
    @IBOutlet weak var email: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func onSend(_ sender: Any) {
        if(email.text!.isEmpty) {
            showAlerOnTop(message: "Please enter your email id.")
            return
        }
        else{
            FireStoreManager.shared.getPassword(email: self.email.text!.lowercased(), password: "") { password in
                self.forgotPassword(password: password.base64Decoded())
            }
        }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func generateTemporaryPassword() -> String {
        let passwordLength = 6
        let allowedCharacters = "0123456789"
        var temporaryPassword = ""

        for _ in 0..<passwordLength {
            let randomIndex = Int(arc4random_uniform(UInt32(allowedCharacters.count)))
            let character = allowedCharacters[allowedCharacters.index(allowedCharacters.startIndex, offsetBy: randomIndex)]
            temporaryPassword.append(character)
        }

        return temporaryPassword
    }

    func forgotPassword(password: String) {
        let temporaryPassword = generateTemporaryPassword()

           let msg = "This is the Temporary password for your information exchange App: \(temporaryPassword). This password will expire in 2 minutes."

        let body = msg

        // Show a loading spinner
        let loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.style = .medium
        loadingIndicator.center =  self.view.center
        self.view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        
        // Call the sendEmail function and handle its response
        ForgetPasswordManager.sendEmail(emailTo: self.email.text ?? "", body: body) { success in
            DispatchQueue.main.async {
                loadingIndicator.stopAnimating()
                if success {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier:  "ForgotUpdatePasswordVC" ) as! ForgotUpdatePasswordVC
                    vc.tempPasswordSentOnEmail = temporaryPassword
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    showAlerOnTop(message: "Error sending email")
                }
            }
        }
    }
}
