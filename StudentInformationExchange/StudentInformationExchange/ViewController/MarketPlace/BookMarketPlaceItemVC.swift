
import UIKit

class BookMarketPlaceItemVC: AccomodationDetailVC {

    @IBOutlet weak var fullName: UITextField?
    @IBOutlet weak var email: UITextField?
    @IBOutlet weak var phone: UITextField?

    override func viewDidLoad() {
        self.fullName?.text = UserDefaultsManager.shared.getName()
        self.email?.text = UserDefaultsManager.shared.getEmail()
        self.phone?.text = UserDefaultsManager.shared.getMobile()
        
        self.fullName?.isEnabled = false
        self.email?.isEnabled = false
        self.phone?.isEnabled = false
         
        imageSlideShow = (self.view.viewWithTag(13)! as! ImageSlideshow)
        
         (self.view.viewWithTag(10)! as! UILabel).text = selectedAccomodation.name! + "\n$\(selectedAccomodation.rentPrice ?? "")"
         (self.view.viewWithTag(11)! as! UILabel).text = selectedAccomodation.location!
        
      
        self.setupImageSlideShow()
        
    }
    
    
    @IBAction override func onApplyNow(_ sender: UIButton) {
       
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            let dateString = formatter.string(from: Date())
            
            
            let data: [String: Any] = [
                "applyedByName": UserDefaultsManager.shared.getName(),
                "applyedByEmail": UserDefaultsManager.shared.getEmail(),
                "applyedByMobile": UserDefaultsManager.shared.getMobile() ?? "",
                "applyedByDob": UserDefaultsManager.shared.getDob(),
                "status": "NA",
                "moveInDate": dateString,
                "propertyId": selectedAccomodation.documentId!,
                "applyedOn": Date().timeIntervalSince1970
            ]

            sender.isEnabled = false
            FireStoreManager.shared.applyMarketPlaceItem(data) { err in
                if let err = err {
                    sender.isEnabled = true
                    // Handle the error, e.g., show an alert to the user
                    print("Error adding document: \(err)")
                    showAlerOnTop(message: "Error applying item. Please try again.")
                } else {
                    sender.isEnabled = false
                    // Document added successfully
                    print("Document added successfully")
                    
                    
                    showOkAlertAnyWhereWithCallBack(message: "Market Place Item Booked successfully 😊 ") {
                        SceneDelegate.shared?.loginCheckOrRestart()
                    }

                    // Send email to the applyer
                    let email = UserDefaultsManager.shared.getEmail()
                    let currentDate = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
                    let emailBody = "Thank you for applying the Market Place Item. Your Market Place Item (\(selectedAccomodation.name!)) was applied successfully on \(currentDate)!"
                    let subject = "Market Place Item Applied successfully - Student Information Exchange App"
                    
                    ForgetPasswordManager.sendOtherEmail(emailTo: email, body: emailBody, subject: subject) { _ in
                        // Handle the email sending completion if needed
                    }
                    
                    
                    
                    
                    // Send email to the accommodation owner or recipient
                    let addedByEmail = selectedAccomodation.addedByEmail!

                    let applicantName = UserDefaultsManager.shared.getName()
                    let applicantEmail = UserDefaultsManager.shared.getEmail()
                    let applicantMobile = UserDefaultsManager.shared.getMobile()

                    let emailBody2 = """
                        \(applicantName) has applied for the item.
                        The Market Place Item (\(selectedAccomodation.name!)) was applied successfully on \(currentDate).
                        
                        Contact Details:
                        - Name: \(applicantName)
                        - Email: \(applicantEmail)
                        - Mobile: \(applicantMobile ?? "NA")
                        """
                    let subject2 = "Market Place Item Booked - Student Information Exchange App"

                    ForgetPasswordManager.sendOtherEmail(emailTo: addedByEmail, body: emailBody2, subject: subject2) { _ in
                        // Handle the email sending completion if needed
                    }
                    
                    
                }
            }
    }
    
    
    
//    @IBAction override func onApplyNow(_ sender: Any) {
//        
//        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "PaymentScreen" ) as! PaymentScreen
//        self.navigationController?.pushViewController(vc, animated: true)
//        
//        
//       
//
//    }

}
    
