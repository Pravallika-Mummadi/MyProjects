//
//  AddAccomodationVC.swift
//  StudentInformationExchange
//
//  Created by Macbook-Pro on 16/12/23.
//

import UIKit

class AddAccomodationVC: UIViewController, TagListViewDelegate {
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var tagListView1: TagListView!
    @IBOutlet weak var tagListView2: TagListView!
    @IBOutlet weak var name: UILabel!

    var listingArray: [String] = []
    var propertyArray: [String] = []

    var selectedAccomodation : AccomodationModel!
    var updateAccomodation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moveFromAddMarketPlace = false
        self.navigationItem.title = "Add Listing"

        self.name.text = "Hey, \(UserDefaultsManager.shared.getName()) Fill detail of your real estate"

        tagListView1.delegate = self
        tagListView2.delegate = self
        
        tagListView1.tag = 0
        tagListView2.tag = 1
        
        tagListView1.addTag("Rent")
        tagListView1.addTag("Sell")

        tagListView2.addTag("House")
        tagListView2.addTag("Apartment")
        tagListView2.addTag("Hotel")
        tagListView2.addTag("Villa")
        tagListView2.addTag("Cottage")
        
        if updateAccomodation {
            self.nameTxt.text = selectedAccomodation.name
            if let arrOfListing = selectedAccomodation.listingType {
                self.listingArray = arrOfListing
                for tagView in tagListView1.tagViews {
                    if let title = tagView.titleLabel?.text, arrOfListing.contains(title) {
                        tagView.isSelected = true
                    }
                }
            }
            
            if let arrOfProperty = selectedAccomodation.propertyCategory {
                self.propertyArray = arrOfProperty
                for tagView in tagListView2.tagViews {
                    if let title = tagView.titleLabel?.text, arrOfProperty.contains(title) {
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
        if sender.tag == 0 {

            if listingArray.contains(title) {
                if let index = listingArray.firstIndex(of: title) {
                    listingArray.remove(at: index)
                }
            } else {
                listingArray.append(title)
            }

        }
        if sender.tag == 1 {

            if propertyArray.contains(title) {
                if let index = propertyArray.firstIndex(of: title) {
                    propertyArray.remove(at: index)
                }
            } else {
                propertyArray.append(title)
            }

        }
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
    }

    @IBAction func onNext(_ sender: Any) {
        
        if(nameTxt.text!.isEmpty) {
            showAlerOnTop(message: "Please enter name")
            return
        }
    
        
        if(self.listingArray.count == 0) {
            showAlerOnTop(message: "Please select listing type")
            return
        }
        
        if(self.propertyArray.count == 0) {
            showAlerOnTop(message: "Please select property category")
            return
        }
        
        let accomodationModel = AccomodationModel(name: self.nameTxt.text ?? "", listingType: self.listingArray, propertyCategory: self.propertyArray, location: "", photo: [], rentPrice: "", bedroom: "", bathroom: "", facility: [""], photoUrl: [])
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "AccomodationLocationVC" ) as! AccomodationLocationVC
                
        vc.updateAccomodation = self.updateAccomodation
        vc.selectedAccomodation = selectedAccomodation

        vc.accomodation = accomodationModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
