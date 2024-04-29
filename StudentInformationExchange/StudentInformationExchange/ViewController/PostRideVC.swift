
import UIKit
import MapKit
class PostRideVC: UIViewController {

   @IBOutlet weak var pickupLocation: UIButton!
   @IBOutlet weak var pickupTime: UIButton!
   @IBOutlet weak var dropLocation: UIButton!
   @IBOutlet weak var dropTime: UIButton!
   var dateFormatter = DateFormatter()
   let dateTimePicker = GlobalDateTimePicker()
   var pickupTimeStamp = Double()
   var selected = "Pick"
   var documentId = ""
   @IBOutlet weak var passangerCount: UILabel!
   @IBOutlet weak var passangerStepper: UIStepper!
   var booking:Booking?
    
    @IBOutlet weak var bookNowButton: UIButton!
    override func viewDidLoad() {
       dateFormatter = DateFormatter.POSIX()
       dateFormatter.dateFormat = "dd-MMMM-yyyy h:mm a"
       dateTimePicker.uIDatePickerMode = .dateAndTime
       self.title = "Post Ride"
       passangerStepper.minimumValue = 1
       
       if let booking = self.booking {
                   self.pickupLocation.setTitle(booking.pickupLocation, for: .normal)
                   self.pickupTime.setTitle(booking.pickupTime, for: .normal)
                   self.dropLocation.setTitle(booking.dropLocation, for: .normal)
                   self.dropTime.setTitle(booking.dropTime, for: .normal)
                   self.dropTime.setTitle(booking.dropTime, for: .normal)
                   self.passangerStepper.value =  Double(booking.passangers ?? 0)
                   self.bookNowButton.setTitle("Update Ride", for: .normal)
                   self.documentId = booking.documentId ?? ""
               }
   }
   
   @IBAction func onPickupLocation(_ sender: Any) {
       
       self.selected = "Pick"
       let mapKit = MapKitSearchViewController(delegate: self)
       mapKit.modalPresentationStyle = .fullScreen
       present(mapKit, animated: true, completion: nil)
       
   }
   
   @IBAction func onDropLocation(_ sender: Any) {
       self.selected = "Drop"
       let mapKit = MapKitSearchViewController(delegate: self)
       mapKit.modalPresentationStyle = .fullScreen
       present(mapKit, animated: true, completion: nil)
   }
   
   @IBAction func onPickupTime(_ sender: Any) {
       
       self.dateTimePicker.onDone = { date in
           self.pickupTime.setTitle(self.dateFormatter.string(from: date), for: .normal)
           
           let timestamp = date.timeIntervalSince1970
       
           self.pickupTimeStamp =  timestamp
       }
       
       self.dateTimePicker.modalPresentationStyle = .overCurrentContext
       self.present(self.dateTimePicker, animated: true, completion: nil)
   }
   
    @IBAction func passangerStepper(_ sender: Any) {
        passangerCount.text = "\(Int(passangerStepper.value))"
    }
    
    
   @IBAction func onDropTime(_ sender: Any) {
       self.dateTimePicker.onDone = { date in
           self.dropTime.setTitle( self.dateFormatter.string(from: date), for: .normal)
        }
       self.dateTimePicker.modalPresentationStyle = .overCurrentContext
       self.present(self.dateTimePicker, animated: true, completion: nil)
   }
   
   @IBAction func onBooking(_ sender: UIButton) {
       
       
       if let booking = booking {
           
           if let createdBy = booking.createdBy {
               
               if(createdBy != UserDefaultsManager.shared.getEmail().lowercased()) {
                   showAlerOnTop(message: "You are not allow to update")
                   return
               }
           }
       }
       
       guard let pickupTimeString = self.pickupTime.currentTitle,
             let dropTimeString = self.dropTime.currentTitle,
             let pickupTime = dateFormatter.date(from: pickupTimeString),
             let dropTime = dateFormatter.date(from: dropTimeString) else {
           showAlerOnTop(message: "Invalid pickup or drop time")
           return
       }
       
       if pickupTime >= dropTime {
           showAlerOnTop(message: "Drop time should be later than pickup time")
           return
       }
       
       if self.pickupLocation.currentTitle! == "Select Pickup Location" {
           showAlerOnTop(message: "Please Select Pickup Location")
           return
       }

       if self.pickupTime.currentTitle! == "Select Pickup Time" {
           showAlerOnTop(message: "Please Select Pickup Time")
           return
       }

       if self.dropLocation.currentTitle! == "Select Drop Location" {
           showAlerOnTop(message: "Please Select Drop Location")
           return
       }

       if self.dropTime.currentTitle! == "Select Drop Time" {
           showAlerOnTop(message: "Please Select Drop Time")
           return
       }
       
       if(self.pickupLocation == self.dropLocation) {
           showAlerOnTop(message: "Location can't be same")
           return
       }
       pickedLocation = self.pickupLocation.currentTitle!
       
       sender.isEnabled = false
       
       FireStoreManager.shared.savePostRide(
              pickupLocation: self.pickupLocation.currentTitle!,
              pickupTime: self.pickupTime.currentTitle!,
              dropLocation: self.dropLocation.currentTitle!,
              dropTime: self.dropTime.currentTitle!, passangerCount: Int(self.passangerStepper.value), documentId: self.documentId
          ) { success in
              if success {
                  var msg = "Booking successful"
                  
                  if(!self.documentId.isEmpty){msg = "Booking Updated"}
                  showOkAlertAnyWhereWithCallBack(message:msg) {
                      self.navigationController?.popViewController(animated: true)
                  }
              } else {
                  showOkAlertAnyWhereWithCallBack(message: "Error saving booking") {
                      self.navigationController?.popViewController(animated: true)
                  }
              }
        }
   }
}





extension PostRideVC: MapKitSearchDelegate {
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
       
       if(selected == "Pick") {
           self.pickupLocation.setTitle(mapItem.placemark.mkPlacemark!.description.removeCoordinates(), for: .normal)
       }else {
           self.dropLocation.setTitle(mapItem.placemark.mkPlacemark!.description.removeCoordinates(), for: .normal)
       }
   }
}
 
