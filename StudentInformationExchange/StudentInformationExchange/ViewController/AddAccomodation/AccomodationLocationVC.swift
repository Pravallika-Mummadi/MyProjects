//
//  AccomodationLocationVC.swift
//  StudentInformationExchange
//
//  Created by Macbook-Pro on 16/12/23.
//

import UIKit
import MapKit

class AccomodationLocationVC: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var locationTxt: UILabel!

    var accomodation : AccomodationModel?
    var selectedAccomodation : AccomodationModel!
    var updateAccomodation = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if let selectedAccomodation = selectedAccomodation {
            updateAccomodation = true
        }else {
            updateAccomodation = false
        }
        
        if updateAccomodation {
            self.locationTxt.text = self.selectedAccomodation.location ?? ""
        }
    }
    

    @IBAction func onLocation(_ sender: Any) {
        let mapKit = MapKitSearchViewController(delegate: self)
        mapKit.modalPresentationStyle = .fullScreen
        present(mapKit, animated: true, completion: nil)
    }
    
    @IBAction func onNext(_ sender: Any) {
        
        if(locationTxt.text == "Select Location") {
            showAlerOnTop(message: "Please select location")
            return
        }
        
        let accomodationModel = AccomodationModel(name: accomodation!.name, listingType: accomodation!.listingType, propertyCategory: accomodation!.propertyCategory, location: self.locationTxt.text!, photo: [], rentPrice: "", bedroom: "", bathroom: "", facility: [""], photoUrl: [])

        
        
        if updateAccomodation {
            
            if(moveFromAddMarketPlace == true) {
                let vc = self.storyboard?.instantiateViewController(withIdentifier:  "AddPriceMarketPlace" ) as! AddPriceMarketPlace
                vc.accomodation = accomodationModel
                vc.updateAccomodation = true
                vc.selectedAccomodation = selectedAccomodation

                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier:  "AddRoomVC" ) as! AddRoomVC
                
                vc.accomodation = accomodationModel
                
                vc.updateAccomodation = self.updateAccomodation
                vc.selectedAccomodation = selectedAccomodation
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:  "AddPhotosVC" ) as! AddPhotosVC
                    
            vc.accomodation = accomodationModel

            self.navigationController?.pushViewController(vc, animated: true)

        }
    }

}


extension AccomodationLocationVC: MapKitSearchDelegate {
    func mapKitSearch(_ mapKitSearchViewController: MapKitSearchViewController, mapItem: MKMapItem) {
    }
    
    func mapKitSearch(_ mapKitSearchViewController: MapKitSearchViewController, searchReturnedOneItem mapItem: MKMapItem) {
    }

    func mapKitSearch(_ mapKitSearchViewController: MapKitSearchViewController, userSelectedListItem mapItem: MKMapItem) {
    }

    func mapKitSearch(_ mapKitSearchViewController: MapKitSearchViewController, userSelectedGeocodeItem mapItem: MKMapItem) {
    }

    func mapKitSearch(_ mapKitSearchViewController: MapKitSearchViewController, userSelectedAnnotationFromMap mapItem: MKMapItem) {
        print(mapItem.placemark.address)
        
        mapKitSearchViewController.dismiss(animated: true)
        self.setAddress(mapItem: mapItem)
    }
    
    
    func setAddress(mapItem: MKMapItem) {
        
            self.locationTxt.text = mapItem.placemark.mkPlacemark!.description.removeCoordinates()
        
    }
    
}
