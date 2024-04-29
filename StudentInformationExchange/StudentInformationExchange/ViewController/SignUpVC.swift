//
//  SignUpVC.swift
//  StudentInformationExchange
//
//  Created by Macbook-Pro on 21/11/23.
//

import UIKit

class SignUpVC: UIViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var switchAgree: UISwitch!
    let datePicker = UIDatePicker()

    var switchBool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.maximumDate = Date()
        self.dob.inputView =  datePicker
        self.showDatePicker()
        self.switchAgree.addTarget(self, action: #selector(self.switchValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.switchAgree.isOn = true
            self.switchBool = true
        }else {
            self.switchAgree.isOn = false
            self.switchBool = false
        }
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        if validate(){
            
            if !self.phone.text!.isNumber {
                showAlerOnTop(message: "Phone no. not valid")
                       return
            }
            
            
            let userData = UserRegistrationModel(name: self.name.text?.lowercased() ?? "", email: self.email.text ?? "", dob: self.dob.text ?? "", mobile: self.phone.text ?? "", password: self.password.text?.base64Encoded() ?? "")
            
            FireStoreManager.shared.signUp(user: userData) { success in
                if success{
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }


    
    func validate() ->Bool {
        
        if(self.name.text!.isEmpty) {
             showAlerOnTop(message: "Please enter name.")
            return false
        }
        
        // Check for non-alphabetic characters using upper and lowercase sets
           
        // Check for non-alphabetic characters using CharacterSet
            let allowedCharacterSet = CharacterSet.letters
            let nameCharacterSet = CharacterSet(charactersIn: self.name.text!)
            if !allowedCharacterSet.isSuperset(of: nameCharacterSet) {
                showAlerOnTop(message: "Name should contain only alphabetical characters.")
                return false
            }
        
       
        if(self.email.text!.isEmpty) {
             showAlerOnTop(message: "Please enter email.")
            return false
        }
        
        if !email.text!.emailIsCorrect() {
            showAlerOnTop(message: "Please enter valid email id")
            return false
        }
        
        if(self.dob.text!.isEmpty) {
            showAlerOnTop(message: "Please enter dob.")
           return false
       }
        

        if(self.phone.text!.isEmpty) {
             showAlerOnTop(message: "Please enter phone.")
            return false
        }
        
        // Check if phone number contains only digits
            let phoneNumberCharacterSet = CharacterSet(charactersIn: self.phone.text!)
            let digitSet = CharacterSet.decimalDigits
            if !digitSet.isSuperset(of: phoneNumberCharacterSet) {
                showAlerOnTop(message: "Phone number should contain only digits.")
                return false
            }
        
        if(self.password.text!.isEmpty) {
             showAlerOnTop(message: "Please enter password.")
            return false
        }
        
        if(self.confirmPassword.text!.isEmpty) {
             showAlerOnTop(message: "Please enter confirm password.")
            return false
        }
        
           if(self.password.text! != self.confirmPassword.text!) {
             showAlerOnTop(message: "Password doesn't match")
            return false
        }
        
        if(self.password.text!.count < 5 || self.password.text!.count > 10 ) {
            
             showAlerOnTop(message: "Password  length shoud be 5 to 10")
            return false
        }
        
        if !switchBool {
            showAlerOnTop(message: "Please agree terms and condition")
           return false

        }
        
         
        
        return true
    }
}

extension SignUpVC {
        func showDatePicker() {
            //Formate Date
            datePicker.datePickerMode = .date
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
            } else {
                // Fallback on earlier versions
            }
            //ToolBar
            let toolbar = UIToolbar();
            toolbar.sizeToFit()
            
            //done button & cancel button
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneHolydatePicker))
            doneButton.tintColor = .black
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelDatePicker))
            cancelButton.tintColor = .black
            toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
            
            // add toolbar to textField
            dob.inputAccessoryView = toolbar
            // add datepicker to textField
            dob.inputView = datePicker
            
        }
        
        @objc func doneHolydatePicker() {
            //For date formate
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            dob.text = formatter.string(from: datePicker.date)
            //dismiss date picker dialog
            self.view.endEditing(true)
        }
        
        @objc func cancelDatePicker() {
            self.view.endEditing(true)
        }

}



