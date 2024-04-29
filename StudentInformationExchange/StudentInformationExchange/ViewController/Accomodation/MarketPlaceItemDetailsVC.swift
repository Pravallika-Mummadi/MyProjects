
import UIKit

 
class MarketPlaceItemDetailsVC: UIViewController, TagListViewDelegate {
   @IBOutlet weak var tagListView: TagListView?
   var moveFromHistory = false
   @IBOutlet weak var applyNowButton: UIButton?
   var viewOffers = false
   @IBOutlet weak var type: UILabel!
   var accomodationTitle: UILabel!
   var accomodationLocation: UILabel!
   var imageSlideShow: ImageSlideshow!
   
   @IBOutlet weak var deleteButton: UIButton?
   var bedRoom: UITextField?
    var bathroom: UITextField?
   override func viewDidLoad() {
       super.viewDidLoad()
   
       accomodationTitle = (self.view.viewWithTag(10)! as! UILabel)
       accomodationLocation = (self.view.viewWithTag(11)! as! UILabel)
       imageSlideShow = (self.view.viewWithTag(13)! as! ImageSlideshow)
       
       
      
       if let listingType = selectedAccomodation.listingType {
           let typeString = listingType.joined(separator: ", ")
           if let type = type {
               self.type.text = " \(typeString)"
           }
       }
       
       self.imageSlideShow.clipsToBounds = true

       self.accomodationTitle.text = selectedAccomodation.name! + "\n$\(selectedAccomodation.rentPrice ?? "")"
     
       let location = selectedAccomodation.location!
       let name = selectedAccomodation.addedByName!
       let email = selectedAccomodation.addedByEmail!
       let mobile = selectedAccomodation.addedByMobile!
       self.accomodationLocation.numberOfLines = 0
       self.type.numberOfLines = 0
       self.type.text = "Type : \(self.type.text!)\n\nName: \(name)\n\nEmail: \(email)\n\nMobile: \(mobile)"
       
       if let tagListView  = self.tagListView {
           
           tagListView.delegate = self
    
           
           for item in selectedAccomodation.facility! {
               tagListView.addTag(item)
           }
         
           tagListView.isUserInteractionEnabled = false
       }
      
       self.setupImageSlideShow()
       
       if let applyNowButton = self.applyNowButton {
           
           if(selectedAccomodation.addedByEmail?.lowercased() == UserDefaultsManager.shared.getEmail().lowercased()) {
               applyNowButton.setTitle("Update", for: .normal)
               self.viewOffers = true
               self.deleteButton?.isHidden = false
           }else{
               self.deleteButton?.isHidden = true
           }
           
           if(moveFromHistory == true ) {
               applyNowButton.isHidden = true
               self.deleteButton?.isHidden = true
           }
         
       }
       
       
       self.deleteButton?.onTap {
           
           FireStoreManager.shared.deleteMarketPlace(doucumentId: selectedAccomodation.documentId!)
           showOkAlertAnyWhereWithCallBack(message: "Market Place Deleted") {
               self.navigationController?.popViewController(animated: true)
           }
           
       }
   }
   

   // MARK: TagListViewDelegate
   func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
       print("Tag pressed: \(title), \(sender)")
       tagView.isSelected = !tagView.isSelected
   }
   
   func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
       print("Tag Remove pressed: \(title), \(sender)")
       sender.removeTagView(tagView)
   }

   func setupImageSlideShow() {
       
       let sdWebImageSource = selectedAccomodation.photoUrl!.compactMap { billboard -> SDWebImageSource? in
           if  let url =  URL(string: billboard.encodedURL()) {
               return SDWebImageSource(url: url)
           }
           return nil
       }
       
       imageSlideShow.slideshowInterval = 3.0
       imageSlideShow.pageIndicatorPosition = .init(horizontal: .center, vertical: .bottom)
       imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
       
       let pageControl = UIPageControl()
       pageControl.currentPageIndicatorTintColor = UIColor.white
       pageControl.pageIndicatorTintColor = UIColor.lightGray
       
       pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
   
       imageSlideShow.pageIndicator = pageControl
       imageSlideShow.activityIndicator = DefaultActivityIndicator()
       imageSlideShow.delegate = self
       imageSlideShow.setImageInputs(sdWebImageSource)
       
   }
   
   @IBAction func onApplyNow(_ sender: Any) {
       
       if(viewOffers) {
           let vc = self.storyboard?.instantiateViewController(withIdentifier:  "AddMarketPlaceVC" ) as! AddMarketPlaceVC
           vc.updateAccomodation = true
           vc.selectedAccomodation = selectedAccomodation
           self.navigationController?.pushViewController(vc, animated: true)
       }else {
           let vc = self.storyboard?.instantiateViewController(withIdentifier:  "BookMarketPlaceItemVC" ) as! BookMarketPlaceItemVC
           self.navigationController?.pushViewController(vc, animated: true)
       }
      
   }
}

extension MarketPlaceItemDetailsVC: ImageSlideshowDelegate {
       
   func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
   }
}



