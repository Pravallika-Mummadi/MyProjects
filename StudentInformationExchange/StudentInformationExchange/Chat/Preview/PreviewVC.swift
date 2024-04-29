

import UIKit
import WebKit
import PDFKit
import Photos

enum FileType :String, Codable{
    case PDF,IMAGE,HTML,File
   
}

class PreviewVC: UIViewController, WKUIDelegate, WKNavigationDelegate {

   var topTitle : String?
   var htmlContent = ""
   @IBOutlet weak var containerView: UIView!
   var hideNavigation = false
   @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

   @IBOutlet weak var downloadButton: UIButton!
   var fileType: FileType?
   var url = ""
   var fileUrl:URL?
   
   lazy var webView: WKWebView = {
       let webConfiguration = WKWebViewConfiguration()
       webConfiguration.allowsInlineMediaPlayback = true
       let webView = WKWebView(frame: .zero, configuration: webConfiguration)
       webView.uiDelegate = self
       webView.navigationDelegate = self
       webView.translatesAutoresizingMaskIntoConstraints = false
       return webView
   }()
   
   override func viewDidLoad() {
       self.containerView.backgroundColor = .white
       self.view.backgroundColor = .appColor
//       self.containerView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
       self.title = "Preview"
       downloadButton.isHidden = true

     
   }
  
    
    
    
    override func viewDidAppear(_ animated: Bool) {
//       self.containerView.roundCorners(corners: [.topLeft, .topRight], radius: 20)
      self.downloadButton.dropShadow()
      self.activityIndicator.color = .appColor
      self.activityIndicator.startAnimating()
      self.webView.navigationDelegate = self
      self.activityIndicator.hidesWhenStopped = true
      
      self.setView()
      
      if(hideNavigation){
          navigationController?.isNavigationBarHidden = true
          tabBarController?.tabBar.isHidden = true
      }
       
   }
   
   
   private func setView() {
       
       guard let fileType = fileType else {
           return
       }

       if fileType == .PDF {
           self.containerView.addSubview(self.activityIndicator)
           self.activityIndicator.startAnimating()
           self.activityIndicator.hidesWhenStopped = true
           
           if let url = self.url.encodedURL().toURL() {
               self.displayPdf(resourceUrl: url)
           }
           
       }else if fileType == .HTML  {
           self.setupUI()
           self.webView.navigationDelegate = self
           let viewportTag = "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
              let fullHTMLContent = "\(viewportTag)\(htmlContent)"
              let cssStyle = "<style>body { margin: 25px; }</style>"
              let modifiedHTMLContent = "\(cssStyle)\(fullHTMLContent)"
              self.webView.loadHTMLString("\(viewportTag)\(modifiedHTMLContent)", baseURL: nil)
       }
       else if fileType == .File  {
           self.setupUI()
           self.webView.navigationDelegate = self
           self.webView.loadFileURL(fileUrl!, allowingReadAccessTo: fileUrl!)
       }
       
       else {
           print(url)
           self.setupUI()
           self.webView.addSubview(self.activityIndicator)
           self.activityIndicator.startAnimating()
           self.webView.navigationDelegate = self
           self.activityIndicator.hidesWhenStopped = true
           
           if let url = self.url.encodedURL().toURL() {
               let myRequest = URLRequest(url: url)
               self.webView.load(myRequest)
           }
       }
       
      
   }

   
   func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       activityIndicator.stopAnimating()
      
           downloadButton.isHidden = false
       
      
   }

   func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
       activityIndicator.stopAnimating()
   }
   
   private func displayPdf(resourceUrl: URL) {
       DispatchQueue.global(qos: .userInitiated).async { [weak self] in
           guard let self = self else { return }

           let pdfDocument = self.createPdfDocument(resourceUrl: resourceUrl)

           DispatchQueue.main.async {
               if let pdfDocument = pdfDocument {
                   let pdfView = self.createPdfView(withFrame: self.view.bounds)
                   self.containerView.addSubview(pdfView)
                   pdfView.document = pdfDocument
               }
               if(pdfDocument == nil) {
                   showErrorBanner(message: "Something went wrong!!")
                   self.navigationController?.popViewController(animated: true)
               }else {
                   self.downloadButton.isHidden = true
               }
               self.activityIndicator.stopAnimating()
           }
       }
   }
   
 
   private func createPdfView(withFrame frame: CGRect) -> PDFView {
       let pdfView = PDFView(frame: frame)
       pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       pdfView.autoScales = true
       
       return pdfView
   }
   
   private func createPdfDocument(resourceUrl: URL?) -> PDFDocument? {
       if let resourceUrl = resourceUrl {
           return PDFDocument(url: resourceUrl)
       }
       
       return nil
   }
   
   
   func setupUI() {
       self.view.backgroundColor = .appColor
       self.containerView.addSubview(webView)
       
       NSLayoutConstraint.activate([
           webView.topAnchor
               .constraint(equalTo: self.containerView.safeAreaLayoutGuide.topAnchor),
           webView.leftAnchor
               .constraint(equalTo: self.containerView.safeAreaLayoutGuide.leftAnchor),
           webView.bottomAnchor
               .constraint(equalTo: self.containerView.safeAreaLayoutGuide.bottomAnchor),
           webView.rightAnchor
               .constraint(equalTo: self.containerView.safeAreaLayoutGuide.rightAnchor)
       ])
   }
   
   override func viewWillDisappear(_ animated: Bool) {
       
       self.navigationController?.navigationBar.isHidden = false
      
   }
}

extension PreviewVC {
    
   
    private func saveImageToAlbum(image: UIImage, albumName: String) {
        // Check if the album already exists
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let existingAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let existingAlbum = existingAlbums.firstObject {
            // Album already exists, add the image to the existing album
            PHPhotoLibrary.shared().performChanges({
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                guard let placeholder = assetChangeRequest.placeholderForCreatedAsset else {
                    return
                }
                PHAssetCollectionChangeRequest(for: existingAlbum)?.addAssets([placeholder] as NSArray)
            }) { completed, error in
                DispatchQueue.main.async {
                    if completed {
                        print("Image is saved!")
                        showSuccessBanner(from: "", message: "Image Saved")
                    } else if let error = error {
                        print("Error saving image to custom album: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            // Album does not exist, create a new album and add the image
            PHPhotoLibrary.shared().performChanges({
                let albumChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                guard let placeholder = assetChangeRequest.placeholderForCreatedAsset else {
                    return
                }
                albumChangeRequest.addAssets([placeholder] as NSArray)
            }) { completed, error in
                DispatchQueue.main.async {
                    if completed {
                        print("Image is saved!")
                        showSuccessBanner(from: "", message: "Image Saved")
                      //  self.showSuccessBanner(from: "", message: "Image Saved")
                    } else if let error = error {
                        print("Error saving image to custom album: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    
   @IBAction func onDownload(_ sender: Any) {
       
       if fileType == .IMAGE {
           
           if let imageUrl = URL(string: url.encodedURL()) {
                      
                       // Download the image data
                       URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                           
                           if let error = error {
                               showAlerOnTop(message: "Error downloading image: \(error.localizedDescription)")
                               return
                           }

                           guard let imageData = data, let image = UIImage(data: imageData) else {
                               showAlerOnTop(message: "Error getting image data.")
                               return
                           }
                           
                           self.saveImageToAlbum(image: image, albumName: "Blood Bank System")

                          
                       }.resume()
                   }
           
           return
       }
       
       
   }
}

extension PreviewVC {
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlerOnTop(message: "Error saving image: \(error.localizedDescription)")
        } else {
            showAlerOnTop(message: "Image saved successfully.")
        }
    }
}
