 
import UIKit


var selectedAccomodation : AccomodationModel!

class AccomodationDetailVC: UIViewController, TagListViewDelegate {
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
        
        if let bedRoom = self.view.viewWithTag(14) as? UITextField {
            self.bedRoom = bedRoom
            self.bedRoom!.text = "Bedroom \(selectedAccomodation.bedroom!)"
        }

        if let bathroom = self.view.viewWithTag(15) as? UITextField {
            self.bathroom = bathroom
            self.bathroom!.text = "Bathroom \(selectedAccomodation.bathroom!)"
        }
        
       
        if let listingType = selectedAccomodation.listingType {
            let typeString = listingType.joined(separator: ", ")
            if type != nil {
                self.type.text = " \(typeString)"
            }
        }  
        
        self.imageSlideShow.clipsToBounds = true
 
        self.accomodationTitle.text = selectedAccomodation.name! + "\n$\(selectedAccomodation.rentPrice ?? "")"
        self.accomodationLocation.text = selectedAccomodation.location!
       
        
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
            
            FireStoreManager.shared.deleteAccomondation(doucumentId: selectedAccomodation.documentId!)
            showOkAlertAnyWhereWithCallBack(message: "Accommodation Deleted") {
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
    
    @IBAction func onApplyNow(_ sender: UIButton) {
        
        if(viewOffers) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:  "AddAccomodationVC" ) as! AddAccomodationVC
            vc.updateAccomodation = true
            vc.selectedAccomodation = selectedAccomodation
            self.navigationController?.pushViewController(vc, animated: true)

        }else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:  "BookAccomodationVC" ) as! BookAccomodationVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
       
    }
}

extension AccomodationDetailVC: ImageSlideshowDelegate {
        
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
    }
 }


 
