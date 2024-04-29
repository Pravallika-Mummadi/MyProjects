
import UIKit

class AddAssistance: UIViewController {
  
    @IBOutlet weak var addButton: ButtonWithShadow!
    @IBOutlet weak var eventitle: UITextField!
    @IBOutlet weak var details: UITextView!
    var assistance : Assistance?
    var documentId = ""
    let campusCertificationDocumentAssistanceServices: [String] = [
        "Transcript preparation",
        "Diploma and degree certificate processing",
        "Letter of enrollment",
        "Academic recommendation letter writing",
        "Certification application assistance",
        "Verification document preparation",
        "Internship completion certificates",
        "Research project documentation",
    ]
    
    
    override func viewDidLoad() {
         
        if let assistance = assistance {
            
            self.documentId = assistance.documentId
            self.eventitle.text = assistance.service
            self.details.text = assistance.details
            self.addButton.setTitle("Update", for: .normal)
        }
    }
   
    @IBAction func onServices(_ sender: Any) {
        
        let picker = GlobalPicker()
        picker.stringArray = campusCertificationDocumentAssistanceServices
               picker.onDone = { selectedIndex in
                   self.eventitle.text = self.campusCertificationDocumentAssistanceServices[selectedIndex]
               }
        picker.modalPresentationStyle = .overCurrentContext
        present(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func onAdd(_ sender: Any) {
       
       if self.eventitle.text!.isEmpty{
            showAlerOnTop(message: "Please add Title")
            return
       }
       
       if self.details.text!.isEmpty{
            showAlerOnTop(message: "Please add Details")
            return
       }
        
        FireStoreManager.shared.createAssistance(name: eventitle.text!, desc: details.text!, documentId: self.documentId) {
          // showAlerOnTop(message: "Added Successfully")
           self.navigationController?.popViewController(animated: true)
       }
    
     }
       
   }


