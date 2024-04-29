//
//  BookAccomodationVC.swift
//  StudentInformationExchange
//
//  Created by Macbook-Pro on 16/12/23.
//

import UIKit

class BookAccomodationVC: AccomodationDetailVC {

    @IBOutlet weak var fullName: UITextField?
    @IBOutlet weak var email: UITextField?
    @IBOutlet weak var phone: UITextField?
    @IBOutlet weak var dob: UITextField?
    @IBOutlet weak var expectedMoveInDate: UITextField?
    @IBOutlet weak var status: UITextField?
    @IBOutlet weak var agreeButton: UISwitch?
    
    
    override func viewDidLoad() {
        self.fullName?.text = UserDefaultsManager.shared.getName()
        self.email?.text = UserDefaultsManager.shared.getEmail()
        self.phone?.text = UserDefaultsManager.shared.getMobile()
        self.dob?.text = UserDefaultsManager.shared.getDob()
        
        
        self.fullName?.isEnabled = false
        self.email?.isEnabled = false
        self.phone?.isEnabled = false
        self.dob?.isEnabled = false 
        
        imageSlideShow = (self.view.viewWithTag(13)! as! ImageSlideshow)
        
         (self.view.viewWithTag(10)! as! UILabel).text = selectedAccomodation.name! + "\n$\(selectedAccomodation.rentPrice ?? "")"
         (self.view.viewWithTag(11)! as! UILabel).text = selectedAccomodation.location!
        
      
        self.setupImageSlideShow()
        
    }
    
    
    @IBAction func onExpectedMoveInDate(_ sender: Any) {
        let dateTimePicker = GlobalDateTimePicker()
        dateTimePicker.uIDatePickerMode = .date
        dateTimePicker.modalPresentationStyle = .overCurrentContext
        dateTimePicker.onDone = { date in
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            let dateString = formatter.string(from: date)
            self.expectedMoveInDate?.text = dateString
        }
        self.present(dateTimePicker, animated: true)
    }
    
    @IBAction func onStatus(_ sender: Any) {
        
        let picker = GlobalPicker()
        picker.stringArray = ["Bachelor", "Married", "Single", "Divorced", "Widowed"]

               picker.onDone = { selectedIndex in
                   self.status!.text = picker.stringArray[selectedIndex]
               }
        picker.modalPresentationStyle = .overCurrentContext
        present(picker, animated: true, completion: nil)
        
    }
    
    @IBAction override func onApplyNow(_ sender: UIButton) {
        
        
        if(self.status!.text!.isEmpty) {
            showAlerOnTop(message: "Please select status")
            return
        }
        
        
        if(self.expectedMoveInDate!.text!.isEmpty) {
            showAlerOnTop(message: "Please select move-in date")
            return
        }
        
        
        if(!self.agreeButton!.isOn) {
            showAlerOnTop(message: "Please accept terms and conditions")
            return
        }
        
        let data: [String: Any] = [
            "applyedByName": UserDefaultsManager.shared.getName(),
            "applyedByEmail": UserDefaultsManager.shared.getEmail(),
            "applyedByMobile": UserDefaultsManager.shared.getMobile() ?? "",
            "applyedByDob": UserDefaultsManager.shared.getDob(),
            "status": status!.text!,
            "moveInDate": self.expectedMoveInDate!.text!,
            "propertyId": selectedAccomodation.documentId!,
            "applyedOn": Date().timeIntervalSince1970
        ]

        
        
        self.applyNowButton?.isEnabled = false
        FireStoreManager.shared.applyAccommodation(data) { err in
            if let err = err {
                self.applyNowButton?.isEnabled = true
                // Handle the error, e.g., show an alert to the user
                print("Error adding document: \(err)")
                showAlerOnTop(message: "Error adding accommodation. Please try again.")
            } else {
                self.applyNowButton?.isEnabled = false
                // Document added successfully
                print("Document added successfully")
                
                
                showOkAlertAnyWhereWithCallBack(message: "Accommodation applied successfully") {
                    SceneDelegate.shared?.loginCheckOrRestart()
                }

                // Send email to the applyer
                let email = UserDefaultsManager.shared.getEmail()
                let currentDate = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
                let emailBody = "Thank you for applying the accommodation. Your Accommodation (\(selectedAccomodation.name!)) was applied successfully on \(currentDate)!"
                let subject = "Accommodation Applied successfully - Student Information Exchange App"
                
                ForgetPasswordManager.sendOtherEmail(emailTo: email, body: emailBody, subject: subject) { _ in
                    // Handle the email sending completion if needed
                }
                
                
                
                
                // Send email to the accommodation owner or recipient
                let addedByEmail = selectedAccomodation.addedByEmail!

                let applicantName = UserDefaultsManager.shared.getName()
                let applicantEmail = UserDefaultsManager.shared.getEmail()
                let applicantMobile = UserDefaultsManager.shared.getMobile()

                let emailBody2 = """
                    \(applicantName) has applied for the accommodation.
                    The Accommodation (\(selectedAccomodation.name!)) was applied successfully on \(currentDate).
                    
                    Contact Details:
                    - Name: \(applicantName)
                    - Email: \(applicantEmail)
                    - Mobile: \(applicantMobile ?? "NA")
                    - Status: \(self.status!.text!)
                    - Expected move in date: \(self.expectedMoveInDate!.text! )
                    """
                let subject2 = "Accommodation Application - Student Information Exchange App"

                ForgetPasswordManager.sendOtherEmail(emailTo: addedByEmail, body: emailBody2, subject: subject2) { _ in
                    // Handle the email sending completion if needed
                }
                
                
            }
        }

        
        
        
//
    }

}
    
