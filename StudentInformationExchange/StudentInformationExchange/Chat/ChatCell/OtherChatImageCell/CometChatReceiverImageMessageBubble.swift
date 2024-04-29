
import UIKit
import SDWebImage

var tempCache = [String:URL]()
class CometChatReceiverImageMessageBubble: UITableViewCell {
   
  
   @IBOutlet weak var name: UILabel!
   @IBOutlet weak var timeStamp: UILabel!
   @IBOutlet weak var imageMessage: UIImageView!
   @IBOutlet weak var viewButton: UIButton!
   private static var thumbnailCache: [URL: UIImage] = [:]
   
    override func awakeFromNib() {
       
       self.imageMessage.maskedCorners(corners: [.bottomLeft , .topLeft , .topRight , .bottomRight], radius: 12)
       self.imageMessage.dropShadow()
       
       imageMessage.layer.cornerRadius = 12
       imageMessage.layer.borderWidth = 1
       if #available(iOS 13.0, *) {
           imageMessage.layer.borderColor = UIColor.systemFill.cgColor
       } else {
           imageMessage.layer.borderColor = UIColor.lightText.cgColor
       }
       imageMessage.clipsToBounds = true
   }
   
    func setData(message:MessageModel) {
        
        self.name.text =  ""
        self.timeStamp.text = message.dateSent.getFirebaseDateTime()
        
       
        self.imageMessage.contentMode = .scaleAspectFill
        self.viewButton.setImage(UIImage(named: "trans"), for: .normal)
        
        if let url = URL(string: message.filePath.encodedURL() ) {
            
            if(message.messageType == MessageType.VIDEO) {
                self.viewButton.setImage(UIImage(named: "playButton"), for: .normal)
                if let cachedThumbnail = CometChatReceiverImageMessageBubble.thumbnailCache[url] {
                                    // Use cached thumbnail if available
                                    self.imageMessage.image = cachedThumbnail
                                } else {
                                    generateThumbnail(for: url) { image in
                                        DispatchQueue.main.async {
                                            self.imageMessage.image = image
                                        }

                                        // Cache the generated thumbnail
                                        CometChatReceiverImageMessageBubble.thumbnailCache[url] = image
                                    }
                }
            }else {
              
                self.imageMessage.sd_setImage(with: url, placeholderImage:nil,options: SDWebImageOptions(rawValue: 0), completed: { image, error, cacheType, imageURL in
                    
                })
            }
        }
        
    }
}
