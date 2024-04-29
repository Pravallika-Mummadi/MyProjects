//
//  AddPhotosVC.swift
//  StudentInformationExchange
//
//  Created by Macbook-Pro on 16/12/23.
//

import UIKit
import SDWebImage

class AddPhotosVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextBtn: UIButton!
    
    var images: [UIImage] = []
    var newimages: [String] = []

    var accomodation : AccomodationModel?
    var selectedAccomodation : AccomodationModel!
    var updateAccomodation = false

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self

        let layout = CollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout

        if !updateAccomodation {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
            navigationItem.rightBarButtonItem = addButton
        }
        
        self.nextBtn.isHidden = true
        
        if updateAccomodation {
            self.newimages = self.selectedAccomodation.photoUrl!
            for imageName in self.newimages {
                
                downloadImage(from: imageName) { (image) in
                    if let image = image {
                        self.images.append(image)
                    } else {
                        print("Error: Unable to download image")
                    }
                }
            }
            self.collectionView.reloadData()
            self.nextBtn.isHidden = false
        }
    }

    @objc func addButtonTapped() {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onNext(_ sender: Any) {
        
        if(images.count == 0) {
            showAlerOnTop(message: "Please select photo")
            return
        }
        
        let accomodationModel = AccomodationModel(name: accomodation!.name, listingType: accomodation!.listingType, propertyCategory: accomodation!.propertyCategory, location: accomodation!.location!, photo: self.images, rentPrice: "", bedroom: "", bathroom: "", facility: [""], photoUrl: [])

        
        if(moveFromAddMarketPlace == true) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:  "AddPriceMarketPlace" ) as! AddPriceMarketPlace
            vc.accomodation = accomodationModel
            vc.updateAccomodation = true
            vc.selectedAccomodation = selectedAccomodation
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier:  "AddRoomVC" ) as! AddRoomVC
            vc.accomodation = accomodationModel
            vc.updateAccomodation = self.updateAccomodation
            vc.selectedAccomodation = selectedAccomodation
            self.navigationController?.pushViewController(vc, animated: true)
        }
      
    }


    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.updateAccomodation{
            return newimages.count
        }
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagecell", for: indexPath) as! ImageCollectionViewCell
        if updateAccomodation {
            let imageUrl = self.newimages[indexPath.item]
            cell.imageview.sd_setImage(with: imageUrl.encodedURL().toURL(), placeholderImage: UIImage(named: ""),options: SDWebImageOptions(rawValue: 0), completed: { image, error, cacheType, imageURL in
                cell.imageview.image =  image
            })

            cell.imageview.layer.cornerRadius = 20.0
            cell.imageview.clipsToBounds = true
            cell.designableView.isHidden = true
            cell.deleteBtn.tag = indexPath.item
            cell.deleteBtn.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
            return cell
        }
        else {
            cell.imageview.image = images[indexPath.item]
            cell.imageview.layer.cornerRadius = 20.0
            cell.imageview.clipsToBounds = true
            cell.deleteBtn.isHidden = false
            cell.deleteBtn.tag = indexPath.item
            cell.deleteBtn.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
            return cell
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         let spacingBetweenCells: CGFloat = 10
         let collectionViewWidth = collectionView.frame.width
         let cellWidth = (collectionViewWidth - spacingBetweenCells) / 2
         return CGSize(width: cellWidth, height: 170)
     }

     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
         return 5
     }
    
    @objc func deleteButtonTapped(_ sender: UIButton) {
            images.remove(at: sender.tag)
            self.nextBtn.isHidden = images.count > 0 ? false : true
            collectionView.reloadData()
    }
}



extension AddPhotosVC {
    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            images.append(editedImage)
            self.nextBtn.isHidden = images.count > 0 ? false : true
            collectionView.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Check if the URL string is valid
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            completion(nil)
            return
        }
        
        // Create a URLSession task to download the image data
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Check for errors
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Check if data was received
            guard let imageData = data else {
                print("Error: No image data received")
                completion(nil)
                return
            }
            
            // Convert the data into a UIImage object
            if let image = UIImage(data: imageData) {
                // Call the completion handler with the UIImage object
                completion(image)
            } else {
                print("Error: Unable to create image from data")
                completion(nil)
            }
        }
        
        // Start the URLSession task
        task.resume()
    }
}
