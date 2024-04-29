//
//  ProfileVC.swift
//  StudentInformationExchange
//
//  Created by Macbook-Pro on 29/11/23.


import UIKit

class ProfileVC: UIViewController {

    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var name: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.email.text = UserDefaultsManager.shared.getEmail()
        self.name.text = UserDefaultsManager.shared.getName()
    }
    
    @IBAction func onLogout(_ sender: Any) {
        UserDefaultsManager.shared.clearUserDefaults()
        UserDefaults.standard.removeObject(forKey: "documentId")
        SceneDelegate.shared!.loginCheckOrRestart()
    }
    
    @IBAction func onUpdatePassword(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "UpdatePasswordVC" ) as! UpdatePasswordVC
                
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    @IBAction func onHistory(_ sender: Any) {
        
    
        let actions = ["My Posting History","Market Place History" , "Ride History" , "Events History" , "Assistance History" , "Applied Accomodation" , "Applied Item", "Post-Ride History"]

        self.showActionSheetPopup(actionsTitle: actions, title: "Select", message: "Please Select Option") { selectedIndex in

            switch selectedIndex {
            case 0 :
                let vc = self.storyboard?.instantiateViewController(withIdentifier:  "AccomodationVC" ) as! AccomodationVC
                vc.myAccomodationOnly = true
                self.navigationController?.pushViewController(vc, animated: true)
              
            case 1 :
                let vc = self.storyboard?.instantiateViewController(withIdentifier:  "MarketPlaceVC" ) as! MarketPlaceVC
                vc.myAccomodationOnly = true
                self.navigationController?.pushViewController(vc, animated: true)
               
            case 2 :
                let vc = self.storyboard?.instantiateViewController(withIdentifier:  "RiderHistoryViewController" ) as! RiderHistoryViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 3 :
                let vc = self.storyboard?.instantiateViewController(withIdentifier:  "EventsListVC" ) as! EventsListVC
                vc.myDataOnly = true 
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 4 :
                let vc = self.storyboard?.instantiateViewController(withIdentifier:  "ProcessAssistanceVC" ) as! ProcessAssistanceVC
                vc.myDataOnly = true
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 5 :
                let vc = self.storyboard?.instantiateViewController(withIdentifier:  "AppliedAccomodationVC" ) as! AppliedAccomodationVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 6 :
                let vc = self.storyboard?.instantiateViewController(withIdentifier:  "AppliedMarketPlaceHistoryVC" ) as! AppliedMarketPlaceHistoryVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 7 :
                let vc = self.storyboard?.instantiateViewController(withIdentifier:  "PostRideHistoryViewController" ) as! PostRideHistoryViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
               
            default : break
            }
        }
        
    }

}
