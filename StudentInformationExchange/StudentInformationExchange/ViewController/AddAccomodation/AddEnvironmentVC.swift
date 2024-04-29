//
//  AddEnvironmentVC.swift
//  StudentInformationExchange
//
//  Created by Macbook-Pro on 16/12/23.
//

import UIKit

class AddEnvironmentVC: UIViewController, TagListViewDelegate {
    @IBOutlet weak var tagListView2: TagListView!
    
    var accomodation : AccomodationModel?
    var listingArray: [String] = []
    var selectedAccomodation : AccomodationModel!
    var updateAccomodation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add Listing"
        
        tagListView2.delegate = self
        
        tagListView2.addTag("Parking Lot")
        tagListView2.addTag("Pet Allowed")
        tagListView2.addTag("Garden")
        tagListView2.addTag("Gym")
        tagListView2.addTag("Home theatre")
        tagListView2.addTag("Kid's Friendly")
        
        
        if updateAccomodation {
            if let arrOfListing = selectedAccomodation.facility {
                self.listingArray = arrOfListing
                for tagView in tagListView2.tagViews {
                    if let title = tagView.titleLabel?.text, arrOfListing.contains(title) {
                        tagView.isSelected = true
                    }
                }
            }
        }
        
    }
    
    
    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        tagView.isSelected = !tagView.isSelected
        
        if listingArray.contains(title) {
            if let index = listingArray.firstIndex(of: title) {
                listingArray.remove(at: index)
            }
        } else {
            listingArray.append(title)
        }
        
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
    }
    
    @IBAction func onNext(_ sender: UIButton) {
        
        if(self.listingArray.count == 0) {
            showAlerOnTop(message: "Please select facility")
            return
        }
        
        
        sender.isEnabled = false
        
        
        if updateAccomodation {
            let photourl = self.selectedAccomodation.photoUrl
            let docuemtID = selectedAccomodation.documentId ?? ""
            self.selectedAccomodation = self.accomodation
            self.selectedAccomodation.facility = self.listingArray
            self.selectedAccomodation.photoUrl = photourl
            
            FireStoreManager.shared.updateAccomodation(documentID: docuemtID, updatedAccomodation: self.selectedAccomodation) { success in
                if success {
                    
                    showOkAlertAnyWhereWithCallBack(message: "Accomodation updated successfully!!") {
                        DispatchQueue.main.async {
                            SceneDelegate.shared?.loginCheckOrRestart()
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
                    
                    var accomodationModel = AccomodationModel(name: self.accomodation!.name!, listingType: self.accomodation!.listingType!, propertyCategory: self.accomodation!.propertyCategory!, location: self.accomodation!.location!, photo: self.accomodation!.photo!, rentPrice: self.accomodation!.rentPrice!, bedroom: self.accomodation!.bedroom!, bathroom: self.accomodation!.bathroom!, facility: self.listingArray, photoUrl: photoArray)
                    
                    accomodationModel.addedByEmail = UserDefaultsManager.shared.getEmail()
                    accomodationModel.addedByMobile = UserDefaultsManager.shared.getMobile()
                    accomodationModel.addedByName = UserDefaultsManager.shared.getName()
                    
                    FireStoreManager.shared.addAccomodation(accomodation: accomodationModel) { success in
                        if success {
                            
                            let email = UserDefaultsManager.shared.getEmail()
                            let currentDate = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
                            
                            let emailBody = "Thank you for adding the accommodation. Your Accommodation (\(accomodationModel.name!)) was added successfully on \(currentDate)!"
                            
                            let subject = "Accomodation Added successfully Student Information Exchange App"
                            
                            ForgetPasswordManager.sendOtherEmail(emailTo: email, body: emailBody,subject: subject) { _ in }
                            
                            
                            showOkAlertAnyWhereWithCallBack(message: "Accomodation added successfully!!") {
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
