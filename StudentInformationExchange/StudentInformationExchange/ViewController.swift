 

import UIKit

class PaymentScreen: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var images = ["discover", "echeck", "master card", "pay pal"]
    @IBOutlet weak var selectedCard: UILabel!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var cvv: UITextField!
    @IBOutlet weak var paymentLabel: UILabel!
    var selectedCardText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
               layout.scrollDirection = .horizontal
               layout.minimumInteritemSpacing = 10
               layout.minimumLineSpacing = 10
               layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
               collectionView.setCollectionViewLayout(layout, animated: true)
        self.paymentLabel.text = "Pay $\(selectedAccomodation.rentPrice ?? "100")"
    }
    @IBAction func onPay(_ sender: UIButton) {
        let name = self.name.text!
        let number = self.number.text!
        let cvv = self.cvv.text!
        
        if name.isEmpty || number.isEmpty || cvv.isEmpty {
            showAlert(message: "Please enter all the details")
        } else if selectedCardText.isEmpty {
            showAlert(message: "Please select card")
        }else if !isValidCreditCardNumber(number) {
            showAlert(message: "Invalid credit card number. Please enter a 16-digit number.")
        }else if !isValidCVV(cvv) {
            showAlert(message: "Invalid CVV. Please enter a 3 or 4-digit number.")
        }  else {
            
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
                    
                    
                    showOkAlertAnyWhereWithCallBack(message: "Payment Success 😊 Market Place Item Booked successfully") {
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
    }
    
    // Function to check the validity of the credit card number based on the number of digits and digits-only
    func isValidCreditCardNumber(_ cardNumber: String) -> Bool {
        let cardNumberWithoutSpaces = cardNumber.replacingOccurrences(of: " ", with: "")
        
        // Assuming a valid credit card has 16 digits and contains only digits
        if cardNumberWithoutSpaces.count == 16, cardNumberWithoutSpaces.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
            return true
        } else {
            return false
        }
    }

    // Function to check the validity of the CVV based on the number of digits and digits-only
    func isValidCVV(_ cvv: String) -> Bool {
        let cvvWithoutSpaces = cvv.replacingOccurrences(of: " ", with: "")
        
        // Assuming a valid CVV has 3 or 4 digits and contains only digits
        if cvvWithoutSpaces.count == 3 || cvvWithoutSpaces.count == 4, cvvWithoutSpaces.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
            return true
        } else {
            return false
        }
    }
    func showAlert(message:String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
        cell.cardImage.image = UIImage(named: images[indexPath.row])
        cell.cardImage.contentMode = .scaleAspectFit
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCardText = images[indexPath.row]
        self.selectedCard.text = images[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let cellWidth = collectionView.bounds.width / 1 - 15
            return CGSize(width: cellWidth, height: cellWidth)
        }
}
