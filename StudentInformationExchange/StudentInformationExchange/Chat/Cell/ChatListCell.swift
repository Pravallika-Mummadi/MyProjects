 
import UIKit
 
class ChatListCell: UITableViewCell {
 
   @IBOutlet weak var boldLabel: UILabel!
   @IBOutlet weak var contactName: UILabel!
   @IBOutlet weak var contactNumber: UILabel!
   @IBOutlet weak var bgView: UIView!
   
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageCount: UILabel!
    override func awakeFromNib() {
      // bgView.layer.cornerRadius =
   }
   @IBOutlet weak var borderView: UIView!{
       didSet{
           borderView.layer.borderWidth = 0.5
           borderView.layer.borderColor = UIColor.white.cgColor
           //borderView.dropShadow()
       }
   }
}
