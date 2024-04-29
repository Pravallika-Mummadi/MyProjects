
import UIKit

class AddPriceMarketPlace: UIViewController, TagListViewDelegate {
   @IBOutlet weak var rentPriceTxt: UITextField!
   @IBOutlet weak var tagListView2: TagListView!

   var priceType = ""

   var accomodation : AccomodationModel?
   var selectedAccomodation : AccomodationModel?
   var updateAccomodation = false

   override func viewDidLoad() {
       super.viewDidLoad()
       
       tagListView2.delegate = self
       
       tagListView2.addTag("Monthly")
       tagListView2.addTag("Yearly")

       
       if let selectedAccomodation = selectedAccomodation {
           updateAccomodation = true
       }else {
           updateAccomodation = false
       }

       if updateAccomodation {
           self.rentPriceTxt.text = self.selectedAccomodation?.rentPrice

       }
       
   }
   
   
   func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
       
       for tag in sender.tagViews {
           tag.isSelected = false
       }
       tagView.isSelected = true
       self.priceType = title

       var originalString = "\(self.rentPriceTxt.text ?? "")"

       if originalString.hasSuffix(" / Yearly") {
           originalString.removeLast(" / Yearly".count)
       } else if originalString.hasSuffix(" / Monthly") {
           originalString.removeLast(" / Monthly".count)
       }

       print(originalString)

       self.rentPriceTxt.text = originalString
       
   }
   
   override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       
   }

   
   @IBAction func onNext(_ sender: UIButton) {
       if(rentPriceTxt.text!.isEmpty) {
           showAlerOnTop(message: "Please enter price")
           return
       }
       
       if(rentPriceTxt.text!.first == "0"){
           showAlerOnTop(message: "Please enter price")
           return
       }
      
       sender.isEnabled = false
      
       
       
       if updateAccomodation {
           
           if let selectedAccomodation = selectedAccomodation {
               
               let photourl = selectedAccomodation.photoUrl
               let docuemtID = selectedAccomodation.documentId ?? ""
               self.selectedAccomodation = self.accomodation
               self.selectedAccomodation?.photoUrl = photourl
               self.selectedAccomodation?.rentPrice = "\(self.rentPriceTxt.text ?? "") / \(self.priceType)"
               
               FireStoreManager.shared.updateMarketPlace(documentID: docuemtID, updatedAccomodation: self.selectedAccomodation!) { success in
                   if success {
                       
                       showOkAlertAnyWhereWithCallBack(message: "Market Place updated successfully!!") {
                           DispatchQueue.main.async {
                               SceneDelegate.shared?.loginCheckOrRestart()
                           }
                       }
                   }
               }
               
           }
          
       }
       
       else {
           FireStoreManager.shared.uploadAndGetDataURLs(accomodation!.photo!) { (downloadURLs, error) in
               if let error = error {
                   print("Error: \(error.localizedDescription)")
                   sender.isEnabled = true
               } else {
                   print("Download URLs: \(downloadURLs)")
                   
                   let photoArray = downloadURLs.map { $0.absoluteString }
                   
                   var accomodationModel = AccomodationModel(name: self.accomodation!.name!, listingType: self.accomodation!.listingType!, propertyCategory: self.accomodation!.propertyCategory!, location: self.accomodation!.location!, photo: self.accomodation!.photo!, rentPrice: self.rentPriceTxt.text!, bedroom: self.accomodation!.bedroom!, bathroom: self.accomodation!.bathroom!, facility: ["NA"], photoUrl: photoArray)
                   
                   accomodationModel.addedByEmail = UserDefaultsManager.shared.getEmail()
                   accomodationModel.addedByMobile = UserDefaultsManager.shared.getMobile()
                   accomodationModel.addedByName = UserDefaultsManager.shared.getName()
                   
                   FireStoreManager.shared.addMarketPlace(accomodation: accomodationModel) { success in
                       if success {
                           
                           let email = UserDefaultsManager.shared.getEmail()
                           let currentDate = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
                           
                           let emailBody = "Thank you for adding the Market Place Item. Your Market Place Item (\(accomodationModel.name!)) was added successfully on \(currentDate)!"
                           
                           let subject = "Market Place Added Item successfully Student Information Exchange App"
                           
                           ForgetPasswordManager.sendOtherEmail(emailTo: email, body: emailBody,subject: subject) { _ in }
                           
                           
                           showOkAlertAnyWhereWithCallBack(message: "Market Place Item added successfully!!") {
                               DispatchQueue.main.async {
                                   SceneDelegate.shared?.loginCheckOrRestart()
                               }
                           }
                       }
                   }
               }
           }
       }
   }
   
}
   

