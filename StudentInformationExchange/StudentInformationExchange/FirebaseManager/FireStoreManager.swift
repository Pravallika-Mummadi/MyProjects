
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Firebase
import FirebaseFirestoreSwift
import Photos
var showBanner = false

struct Photo {
    var image: UIImage
    var downloadURL: URL?
}


struct AppliedAccomodation : Codable {
    let status: String?
    let moveInDate: String?
    let propertyId: String?
    let appliedOn: Double?
}


class FireStoreManager {
    
    public static let shared = FireStoreManager()
    var hospital = [String]()
    
    var db: Firestore!
    var dbRef : CollectionReference!
    
    var storageRef: StorageReference!
    var lastMessagesData: [LastChatModel] = []
    var lastMessages : CollectionReference!
    var chatDbRef : CollectionReference!
    var onLineOffLine : CollectionReference!
    var onlineOfflineListener: ListenerRegistration?
    var tempListnerLastmsg: ListenerRegistration?
    var lastMessageListner: ListenerRegistration?
    var gallary : CollectionReference!
    
    
    init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        dbRef = db.collection("Users")
        gallary = db.collection("Gallary")
        storageRef = Storage.storage().reference()
        lastMessages = db.collection("LastMessages")
        chatDbRef = db.collection("Chat")
        onLineOffLine = db.collection("OnLineOffLine")
    }
    
    
    func getAccomodationDetails(documentId: String, completion: @escaping (AccomodationModel?) -> Void) {
        
        db.collection("Accomodation").document(documentId).getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    let accomodation = try document.data(as: AccomodationModel.self)
                    completion(accomodation)
                } catch {
                    print("Error decoding document: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                print("Document does not exist")
                completion(nil)
            }
        }
    }
    
    func getAccomodationDetailsMarketPlace(documentId: String, completion: @escaping (AccomodationModel?) -> Void) {
        
        db.collection("MarketPlace").document(documentId).getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    let accomodation = try document.data(as: AccomodationModel.self)
                    completion(accomodation)
                } catch {
                    print("Error decoding document: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                print("Document does not exist")
                completion(nil)
            }
        }
    }
    
    
    
    
    func getBookingHistory(completion: @escaping ([Booking]) -> Void) {
        db.collection("Bookings").getDocuments { snapshot, error in
            guard error == nil else {
                print("Error fetching booking history: \(error!.localizedDescription)")
                completion([])
                return
            }
            
            var bookingHistory = [Booking]()
            
            for document in snapshot!.documents {
                do {
                    var temp = try document.data(as: Booking.self)
                    temp.documentId = document.documentID
                    bookingHistory.append(temp)
                } catch let error {
                    print(error)
                }
            }
            
            completion(bookingHistory)
        }
    }
    
    func getPostBookingHistory(completion: @escaping ([Booking]) -> Void) {
        db.collection("PostRides").getDocuments { snapshot, error in
            guard error == nil else {
                print("Error fetching booking history: \(error!.localizedDescription)")
                completion([])
                return
            }
            
            var bookingHistory = [Booking]()
            
            for document in snapshot!.documents {
                do {
                    var temp = try document.data(as: Booking.self)
                    temp.documentId = document.documentID
                    bookingHistory.append(temp)
                } catch let error {
                    print(error)
                }
            }
            
            completion(bookingHistory)
        }
    }
    
    func saveBooking(pickupLocation: String, pickupTime: String, dropLocation: String, dropTime: String,documentId:String, completion: @escaping (Bool) -> Void) {
        let bookingData: [String: Any] = [
            "pickupLocation": pickupLocation,
            "pickupTime": pickupTime,
            "dropLocation": dropLocation,
            "dropTime": dropTime,
            "createdBy" : UserDefaultsManager.shared.getEmail().lowercased()
        ]
        
        if(documentId.isEmpty) {
            
            db.collection("Bookings").addDocument(data: bookingData) { error in
                if let error = error {
                    print("Error saving booking: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Booking saved successfully")
                    completion(true)
                }
            }
            
        }else {
            db.collection("Bookings").document(documentId).setData(bookingData) { error in
                if let error = error {
                    print("Error saving booking: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Booking Edited successfully")
                    completion(true)
                }
            }
        }
        
    }
    
    func savePostRide(pickupLocation: String, pickupTime: String, dropLocation: String, dropTime: String,passangerCount:Int,documentId:String, completion: @escaping (Bool) -> Void) {
        let bookingData: [String: Any] = [
            "pickupLocation": pickupLocation,
            "pickupTime": pickupTime,
            "dropLocation": dropLocation,
            "dropTime": dropTime,
            "passangers" : passangerCount,
            "createdBy" : UserDefaultsManager.shared.getEmail().lowercased()
        ]
        
        if(documentId.isEmpty) {
            db.collection("PostRides").addDocument(data: bookingData) { error in
                if let error = error {
                    print("Error saving booking: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Booking saved successfully")
                    completion(true)
                }
            }
        }else {
            
            db.collection("PostRides").document(documentId).updateData(bookingData) { error in
                if let error = error {
                    print("Error saving booking: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Booking saved successfully")
                    completion(true)
                }
            }
            
        }
        
    }
    
    
    func deleteAccomondation(doucumentId:String) {
        
        db.collection("Accomodation").document(doucumentId).delete()
        
    }
    
    func deleteMarketPlace(doucumentId:String) {
        
        db.collection("MarketPlace").document(doucumentId).delete()
        
    }
    
    
    func deleteEvents(doucumentId:String,completion: @escaping (Bool)->() ) {
        
        db.collection("Events").document(doucumentId).delete { err in
            if let err = err {
                showAlerOnTop(message: "Error deleting document: \(err)")
            } else {
                completion(true)
            }
        }
    }
    
    
    func updateEvent(event: Events, completion: @escaping (Error?) -> Void) {
        
        showLoading()
        do {
            try db.collection("Events").document(event.documentId).setData(from: event) { error in
                hideLoading()
                if let error = error {
                    completion(error)
                } else {
                    showOkAlertAnyWhereWithCallBack(message: "Event Updated") {
                        completion(nil)
                    }
                }
            }
        } catch {
            completion(error)
        }
    }
    
    
    func addDesises(eventTitle:String,details:String,createdByEmail:String,createdByName:String,completion: @escaping (Bool)->()) {
        let data = ["eventTitle":eventTitle, "details":details,"createdByEmail":createdByEmail,"createdByName":createdByName] as [String : Any]
        db.collection("Events").addDocument(data: data) { err in
            if let err = err {
                showAlerOnTop(message: "Error adding document: \(err)")
            } else {
                completion(true)
            }
        }
    }
    
    
    func signUp(user: UserRegistrationModel,completion: @escaping (Bool)->() ) {
        
        getQueryFromFirestore(field: "email", compareValue: user.email?.lowercased() ?? "") { querySnapshot in
            
            print(querySnapshot.count)
            
            if(querySnapshot.count > 0) {
                showAlerOnTop(message: "This Email is Already Registerd!!")
            }else {
                
                
                self.getQueryFromFirestore(field: "mobile", compareValue: user.mobile ?? "") { querySnapshot in
                    
                    print(querySnapshot.count)
                    
                    if(querySnapshot.count > 0) {
                        showAlerOnTop(message: "This Phone is Already Registerd!!")
                    }else {
                        
                        // Signup
                        
                        let data = ["name":user.name ?? "","dob":user.dob ?? "","email":user.email ?? "","password":user.password ?? "","mobile":user.mobile ?? ""] as [String : Any]
                        
                        self.addDataToFireStore(data: data) { _ in
                            
                            
                            showOkAlertAnyWhereWithCallBack(message: "Registration Success!!") {
                                
                                DispatchQueue.main.async {
                                    completion(true)
                                }
                                
                            }
                            
                        }
                        
                    }
                }
                
            }
        }
    }
    
    
    func applyAccommodation(_ data: [String: Any], completion: @escaping (Error?) -> Void) {
        // Assuming "accommodations" is the collection name
        let accommodationsCollection = db.collection("AccommodationOffers")
        
        // Add a new document with a generated ID
        accommodationsCollection.addDocument(data: data) { error in
            completion(error)
        }
    }
    
    func applyMarketPlaceItem(_ data: [String: Any], completion: @escaping (Error?) -> Void) {
        // Assuming "accommodations" is the collection name
        let accommodationsCollection = db.collection("MarketPlaceOffers")
        
        // Add a new document with a generated ID
        accommodationsCollection.addDocument(data: data) { error in
            completion(error)
        }
    }
    
    
    func login(email:String,password:String,completion: @escaping (Bool)->()) {
        let  query = db.collection("Users").whereField("email", isEqualTo: email)
        
        query.getDocuments { (querySnapshot, err) in
            
            
            if(querySnapshot?.count == 0) {
                showAlerOnTop(message: "Email id not found!!")
            }else {
                
                for document in querySnapshot!.documents {
                    print("doclogin = \(document.documentID)")
                    UserDefaults.standard.setValue("\(document.documentID)", forKey: "documentId")
                    
                    if let pwd = document.data()["password"] as? String{
                        
                        if(pwd.base64Decoded() == password) {
                            
                            let name = document.data()["name"] as? String ?? ""
                            let email = document.data()["email"] as? String ?? ""
                            let mobile = document.data()["mobile"] as? String ?? ""
                            let dob = document.data()["dob"] as? String ?? ""
                            
                            UserDefaultsManager.shared.saveData(name: name, email: email, mobile: mobile, dob: dob)
                            completion(true)
                            
                        }else {
                            showAlerOnTop(message: "Password doesn't match")
                        }
                        
                        
                    }else {
                        showAlerOnTop(message: "Something went wrong!!")
                    }
                }
            }
        }
    }
    
    func getPassword(email:String,password:String,completion: @escaping (String)->()) {
        let  query = db.collection("Users").whereField("email", isEqualTo: email)
        
        query.getDocuments { (querySnapshot, err) in
            
            if(querySnapshot?.count == 0) {
                showAlerOnTop(message: "Email id not found!!")
            }else {
                
                for document in querySnapshot!.documents {
                    print("doclogin = \(document.documentID)")
                    UserDefaults.standard.setValue("\(document.documentID)", forKey: "documentId")
                    if let pwd = document.data()["password"] as? String{
                        completion(pwd)
                    }else {
                        showAlerOnTop(message: "Something went wrong!!")
                    }
                }
            }
        }
    }
    
    
    
    
    func getAllAssistance(myDataOnly:Bool,completion:@escaping ([Assistance])->()) {
        
        if(myDataOnly) {
            
            db.collection("Assistance").whereField("createdByEmail", isEqualTo: UserDefaultsManager.shared.getEmail()).getDocuments { querySnapshot, err in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion([])
                }else {
                    
                    var list: [Assistance] = []
                    for document in querySnapshot!.documents {
                        do {
                            var temp = try document.data(as: Assistance.self)
                            temp.documentId = document.documentID
                            list.append(temp)
                        } catch let error {
                            print(error)
                        }
                    }
                    completion(list)
                }
            }
        }
        
        else {
            
            db.collection("Assistance").getDocuments { [self](querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion([])
                }else {
                    
                    var list: [Assistance] = []
                    for document in querySnapshot!.documents {
                        do {
                            var temp = try document.data(as: Assistance.self)
                            temp.documentId = document.documentID
                            list.append(temp)
                        } catch let error {
                            print(error)
                        }
                    }
                    completion(list)
                }
                
            }
        }
        
    }
    
    func createAssistance(name:String,desc:String,documentId:String,completion: @escaping ()->()) {
        
        
        if(documentId.isEmpty) {
            
            let docRef = db.collection("Assistance").document()
            
            let documentId = docRef.documentID
            let data = ["documentId" : documentId, "service":name, "details" : desc,"createdByEmail":UserDefaultsManager.shared.getEmail(),"createdByName":UserDefaultsManager.shared.getName()] as [String : Any]
            
            docRef.setData(data){ err in
                
                if let err = err {
                    showAlerOnTop(message: "Error adding document: \(err)")
                } else {
                    let email = UserDefaultsManager.shared.getEmail()
                    let currentDate = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
                    
                    let emailBody = "Thank you for adding the Documents Assistance. Your Documents Assistance For Service (\(name)) was added successfully on \(currentDate)!"
                    
                    let subject = "Documents Assistance Added successfully Student Information Exchange App"
                    
                    ForgetPasswordManager.sendOtherEmail(emailTo: email, body: emailBody,subject: subject) { _ in }
                    
                    showOkAlertAnyWhereWithCallBack(message: "Documents Assistance added successfully!!") {
                        DispatchQueue.main.async {
                            completion()
                        }
                    }
                }
            }
            
        }else {
            
            let docRef = db.collection("Assistance").document(documentId)
            
             
            let data = ["documentId" : documentId, "service":name, "details" : desc,"createdByEmail":UserDefaultsManager.shared.getEmail(),"createdByName":UserDefaultsManager.shared.getName()] as [String : Any]
            
            docRef.setData(data){ err in
                
                if let err = err {
                    showAlerOnTop(message: "Error adding document: \(err)")
                } else {
                    let email = UserDefaultsManager.shared.getEmail()
                    let currentDate = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
                    
                    let emailBody = "Thank you for adding the Documents Assistance. Your Documents Assistance For Service (\(name)) was added successfully on \(currentDate)!"
                    
                    let subject = "Documents Assistance Added successfully Student Information Exchange App"
                    
                    ForgetPasswordManager.sendOtherEmail(emailTo: email, body: emailBody,subject: subject) { _ in }
                    
                    showOkAlertAnyWhereWithCallBack(message: "Documents Assistance added successfully!!") {
                        DispatchQueue.main.async {
                            completion()
                        }
                    }
                }
            }
            
        }
        
        
        
    }
    
    
    func deleteAssistance(doucumentId:String,completion: @escaping (Bool)->() ) {
        
        db.collection("Assistance").document(doucumentId).delete { err in
            if let err = err {
                showAlerOnTop(message: "Error deleting document: \(err)")
            } else {
                completion(true)
            }
        }
    }
    
    
    func getAllEvents(myDataOnly:Bool,completion:@escaping ([Events])->()) {
        
        if(myDataOnly) {
            
            db.collection("Events").whereField("createdByEmail", isEqualTo: UserDefaultsManager.shared.getEmail()).getDocuments { querySnapshot, err in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion([])
                }else {
                    
                    var list: [Events] = []
                    for document in querySnapshot!.documents {
                        do {
                            var temp = try document.data(as: Events.self)
                            temp.documentId = document.documentID
                            list.append(temp)
                        } catch let error {
                            print(error)
                        }
                    }
                    completion(list)
                }
            }
        }
        
        else {
            
            db.collection("Events").getDocuments { [self](querySnapshot, err) in
                
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion([])
                }else {
                    
                    var list: [Events] = []
                    for document in querySnapshot!.documents {
                        do {
                            var temp = try document.data(as: Events.self)
                            temp.documentId = document.documentID
                            list.append(temp)
                        } catch let error {
                            print(error)
                        }
                    }
                    completion(list)
                }
                
            }
            
            
        }
        
    }
    
    
    func getAllAccomodation(completion: @escaping ([AccomodationModel])->()) {
        
        db.collection("Accomodation").getDocuments { [self](querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                completion([])
            }else {
                
                var list: [AccomodationModel] = []
                for document in querySnapshot!.documents {
                    do {
                        var temp = try document.data(as: AccomodationModel.self)
                        temp.documentId = document.documentID
                        temp.rating = getRandomRating()
                        list.append(temp)
                    } catch let error {
                        print(error)
                    }
                }
                completion(list)
            }
            
        }
    }
    
    
    
    
    func createEvent(eventName:String,eventDescription:String,location:String,date:String,time:String,imageUrl:String,eventTime:Double,completion: @escaping ()->()) {
        
        
        let docRef = db.collection("Events").document()
        let documentId = docRef.documentID
        let data = ["documentId" : documentId, "eventName":eventName, "eventDescription" : eventDescription, "location" : location ,  "date" :date, "time" : time , "imageUrl" : imageUrl ,  "eventTime" :eventTime,"createdByEmail":UserDefaultsManager.shared.getEmail(),"createdByName":UserDefaultsManager.shared.getName()] as [String : Any]
        
        docRef.setData(data){ err in
            
            if let err = err {
                showAlerOnTop(message: "Error adding document: \(err)")
            } else {
                let email = UserDefaultsManager.shared.getEmail()
                let currentDate = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
                
                let emailBody = "Thank you for adding the Event. Your Event (\(eventName)) was added successfully on \(currentDate)!"
                
                let subject = "Event Added successfully Student Information Exchange App"
                
                ForgetPasswordManager.sendOtherEmail(emailTo: email, body: emailBody,subject: subject) { _ in }
                
                showOkAlertAnyWhereWithCallBack(message: "Event added successfully!!") {
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }
    
    func saveImage(image: UIImage,completion: @escaping (String)->()) {
        
        showLoading()
        
        let imageName = "\(Int(Date().timeIntervalSince1970)).jpg"
        
        if let data = image.jpegData(compressionQuality: 0.3) {
            let storageRef = Storage.storage().reference().child("images/\(imageName)")
            
            let _ = storageRef.putData(data, metadata: nil) { (metadata, error) in
                hideLoading()
                if let error = error {
                    print(error)
                } else {
                    storageRef.downloadURL { (url, error) in
                        if let _ = error {
                            completion("")
                        } else {
                            print(url!.path)
                            print(url!.description)
                            completion(url!.description)
                        }
                    }
                }
            }
        }
        
    }
    
    
    
    func getMyAppliedAccomodation(completion: @escaping ([AppliedAccomodation]) -> Void) {
        let userEmail = UserDefaultsManager.shared.getEmail()
        
        db.collection("AccommodationOffers")
            .whereField("applyedByEmail", isEqualTo: userEmail)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting accommodation offers: \(error.localizedDescription)")
                    completion([])
                } else {
                    
                    var list: [AppliedAccomodation] = []
                    
                    for document in querySnapshot!.documents {
                        do {
                            var temp = try document.data(as: AppliedAccomodation.self)
                            list.append(temp)
                        } catch let error {
                            print(error)
                        }
                    }
                    completion(list)
                }
            }
    }
    
    func getMyAppliedItem(completion: @escaping ([AppliedAccomodation]) -> Void) {
        let userEmail = UserDefaultsManager.shared.getEmail()
        
        db.collection("MarketPlaceOffers")
            .whereField("applyedByEmail", isEqualTo: userEmail)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting accommodation offers: \(error.localizedDescription)")
                    completion([])
                } else {
                    
                    var list: [AppliedAccomodation] = []
                    
                    for document in querySnapshot!.documents {
                        do {
                            var temp = try document.data(as: AppliedAccomodation.self)
                            list.append(temp)
                        } catch let error {
                            print(error)
                        }
                    }
                    completion(list)
                }
            }
    }
    
    
    
    func getMyPosting(completion: @escaping ([AccomodationModel]) -> Void) {
        let userEmail = UserDefaultsManager.shared.getEmail()
        
        db.collection("Accomodation").whereField("addedByEmail", isEqualTo: UserDefaultsManager.shared.getEmail()).getDocuments { querySnapshot, err in
            
            if let err = err {
                print("Error getting documents: \(err)")
                completion([])
            }else {
                
                var list: [AccomodationModel] = []
                for document in querySnapshot!.documents {
                    do {
                        var temp = try document.data(as: AccomodationModel.self)
                        temp.documentId = document.documentID
                        temp.rating = self.getRandomRating()
                        list.append(temp)
                    } catch let error {
                        print(error)
                    }
                }
                completion(list)
            }
        }
    }
    
    func getMyPostingMarketPlace(completion: @escaping ([AccomodationModel]) -> Void) {
        let userEmail = UserDefaultsManager.shared.getEmail()
        
        db.collection("MarketPlace").whereField("addedByEmail", isEqualTo: UserDefaultsManager.shared.getEmail()).getDocuments { querySnapshot, err in
            
            if let err = err {
                print("Error getting documents: \(err)")
                completion([])
            }else {
                
                var list: [AccomodationModel] = []
                for document in querySnapshot!.documents {
                    do {
                        var temp = try document.data(as: AccomodationModel.self)
                        temp.documentId = document.documentID
                        temp.rating = self.getRandomRating()
                        list.append(temp)
                    } catch let error {
                        print(error)
                    }
                }
                completion(list)
            }
        }
    }
    
    
    func getAllAccomodationMarketPlace(completion: @escaping ([AccomodationModel])->()) {
        
        db.collection("MarketPlace").getDocuments { [self](querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                completion([])
            }else {
                
                var list: [AccomodationModel] = []
                for document in querySnapshot!.documents {
                    do {
                        var temp = try document.data(as: AccomodationModel.self)
                        temp.documentId = document.documentID
                        temp.rating = getRandomRating()
                        list.append(temp)
                    } catch let error {
                        print(error)
                    }
                }
                completion(list)
            }
            
        }
    }
    
    func getRandomRating() -> Double {
        let lowerBound = 2.0
        let upperBound = 5.0
        let randomRating = Double.random(in: lowerBound...upperBound)
        return Double(String(format: "%.1f", randomRating))!
    }
    
    
    
    func getAllUsers(completion: @escaping ([User])->()) {
        
        db.collection("Users").getDocuments {(querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                completion([])
            }else {
                
                var list: [User] = []
                for document in querySnapshot!.documents {
                    do {
                        var temp = try document.data(as: User.self)
                        if(temp.mobile != getMobile()) {
                            temp.documentId = document.documentID
                            list.append(temp)
                        }
                        
                    } catch let error {
                        print(error)
                    }
                }
                completion(list)
                
                
            }
            
        }
        
    }
    
    
    func getQueryFromFirestore(field:String,compareValue:String,completionHandler:@escaping (QuerySnapshot) -> Void){
        
        dbRef.whereField(field, isEqualTo: compareValue).getDocuments { querySnapshot, err in
            
            if let err = err {
                
                showAlerOnTop(message: "Error getting documents: \(err)")
                return
            }else {
                
                if let querySnapshot = querySnapshot {
                    return completionHandler(querySnapshot)
                }else {
                    showAlerOnTop(message: "Something went wrong!!")
                }
                
            }
        }
        
    }
    
    func addDataToFireStore(data:[String:Any] ,completionHandler:@escaping (Any) -> Void){
        let dbr = db.collection("Users")
        dbr.addDocument(data: data) { err in
            if let err = err {
                showAlerOnTop(message: "Error adding document: \(err)")
            } else {
                completionHandler("success")
            }
        }
        
        
    }
    
    func updatePassword(documentid:String, userData: [String:String] ,completion: @escaping (Bool)->()) {
        let  query = db.collection("Users").document(documentid)
        
        query.updateData(userData) { error in
            if let error = error {
                print("Error updating Firestore data: \(error.localizedDescription)")
                // Handle the error
            } else {
                print("Profile data updated successfully")
                completion(true)
                // Handle the success
            }
        }
    }
    
    //    func uploadAndGetDataURLs(_ photos: [UIImage], completion: @escaping ([URL], Error?) -> Void) {
    //        let storage = Storage.storage()
    //        let storageRef = storage.reference()
    //
    ////        var updatedPhotos: [UIImage] = []
    //        var downloadURLs: [URL] = []
    //
    //        let group = DispatchGroup()
    //
    //        for (index, photo) in photos.enumerated() {
    //            group.enter()
    //
    //            guard let imageData = photo.jpegData(compressionQuality: 0.8) else {
    //                group.leave()
    //                continue
    //            }
    //
    //            let photoRef = storageRef.child("accomodation/images/photo\(index).jpg")
    //
    //            photoRef.putData(imageData, metadata: nil) { (metadata, error) in
    //                guard let _ = metadata else {
    //                    group.leave()
    //                    completion([], error)
    //                    return
    //                }
    //
    //                photoRef.downloadURL { (url, error) in
    ////                    var updatedPhoto = photo
    ////                    updatedPhoto = url
    ////                    updatedPhotos.append(updatedPhoto)
    //
    //                    if let url = url {
    //                        downloadURLs.append(url)
    //                    }
    //
    //                }
    //
    //                        group.notify(queue: .main) {
    //                            print("downloadURl == ",downloadURLs)
    //                            completion(downloadURLs, nil)
    //                       }
    //
    //            }
    //        }
    //
    //
    //    }
    
    //    func updateAccomodation(documentID: String, updatedAccomodation: AccomodationModel,completion: @escaping (Bool)->()){
    //        let db = Firestore.firestore()
    //        let userRef = db.collection("Accomodation").document(documentID)
    //
    //        self.db.collection("Accomodation").document(updatedAccomodation.documentId ?? "").getDocument { document, error in
    //            guard let document = document, document.exists else {
    //                print("Document does not exist")
    //                return
    //            }
    //
    //            do {
    //                let user = try document.data(as: AccomodationModel.self)
    //
    //                var updatedUserData = user ?? updatedAccomodation
    //                updatedUserData.name = updatedAccomodation.name // Modify the name as needed
    //
    //                guard let updatedData = try? Firestore.Encoder().encode(updatedUserData) else {
    //                    print("Error encoding updated user data")
    //                    return
    //                }
    //
    //                userRef.setData(updatedAccomodation) { error in
    //                    if let error = error {
    //                        print("Error updating user: \(error.localizedDescription)")
    //                    } else {
    //                        print("User updated successfully")
    //                    }
    //                }
    //            } catch {
    //                print("Error decoding user data: \(error.localizedDescription)")
    //            }
    //        }
    //}
    
    
    func updateAccomodation(documentID: String, updatedAccomodation: AccomodationModel,completion: @escaping (Bool)->())
    {
        let Accomodationdata = ["name": updatedAccomodation.name ?? "",
                            "listingType": updatedAccomodation.listingType ?? "",
                            "location": updatedAccomodation.location ?? "",
                            "propertyCategory": updatedAccomodation.propertyCategory ?? "",
                            "bathroom": updatedAccomodation.bathroom ?? "",
                            "bedroom": updatedAccomodation.bedroom ?? "",
                            "rentPrice": updatedAccomodation.rentPrice ?? "",
                            "facility": updatedAccomodation.facility ?? "",
                            "photoUrl": updatedAccomodation.photoUrl ?? "",
                            "rating": updatedAccomodation.rating ?? ""] as [String : Any]
                    
        let  query = db.collection("Accomodation").document(documentID)
        
        query.updateData(Accomodationdata) { error in
            if let error = error {
                print("Error updating Firestore data: \(error.localizedDescription)")
            } else {
                print("Profile data updated successfully")
                completion(true)
            }
        }
    }

    func updateMarketPlace(documentID: String, updatedAccomodation: AccomodationModel,completion: @escaping (Bool)->())
    {
        let Accomodationdata = ["name": updatedAccomodation.name ?? "",
                            "listingType": updatedAccomodation.listingType ?? "",
                            "location": updatedAccomodation.location ?? "",
                            "propertyCategory": updatedAccomodation.propertyCategory ?? "",
                            "bathroom": updatedAccomodation.bathroom ?? "",
                            "bedroom": updatedAccomodation.bedroom ?? "",
                            "rentPrice": updatedAccomodation.rentPrice ?? "",
                            "facility": updatedAccomodation.facility ?? "",
                            "photoUrl": updatedAccomodation.photoUrl ?? "",
                            "rating": updatedAccomodation.rating ?? ""] as [String : Any]
                    
        let  query = db.collection("MarketPlace").document(documentID)
        
        query.updateData(Accomodationdata) { error in
            if let error = error {
                print("Error updating Firestore data: \(error.localizedDescription)")
            } else {
                print("Profile data updated successfully")
                completion(true)
            }
        }
    }
    func uploadAndGetDataURLs(_ photos: [UIImage], completion: @escaping ([URL], Error?) -> Void) {
      
        var downloadURLs: [URL] = []

        let group = DispatchGroup()

        for (index, photo) in photos.enumerated() {
            group.enter()

            guard let imageData = photo.jpegData(compressionQuality: 0.8) else {
                group.leave()
                continue
            }

            let photoRef = storageRef.child("accomodation/images/photo\(index).jpg")

            photoRef.putData(imageData, metadata: nil) { (metadata, error) in
                guard let _ = metadata else {
                    group.leave()
                    completion([], error)
                    return
                }

                photoRef.downloadURL { (url, error) in
                   
                    if let url = url {
                        downloadURLs.append(url)
                    }

                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion(downloadURLs, nil)
        }
    }
    
    func addAccomodation(accomodation: AccomodationModel ,completion: @escaping (Bool)->()) {
        
        let data = [
            "name": accomodation.name ?? "",
            "listingType": accomodation.listingType ?? [],
            "propertyCategory": accomodation.propertyCategory ?? [],
            "location": accomodation.location ?? "",
            "photoUrl": accomodation.photoUrl!,
            "rentPrice": accomodation.rentPrice ?? "",
            "bedroom": accomodation.bedroom ?? "",
            "bathroom": accomodation.bathroom ?? "",
            "facility": accomodation.facility ?? [],
            "addedByEmail": accomodation.addedByEmail ?? "",
            "addedByMobile": accomodation.addedByMobile ?? "",
            "addedByName": accomodation.addedByName ?? ""
        ] as [String: Any]

        self.db.collection("Accomodation").addDocument(data: data) { err in
            if let err = err {
                showAlerOnTop(message: "Error adding document: \(err)")
            } else {
                completion(true)
            }
        }
    }
    
    
    func addMarketPlace(accomodation: AccomodationModel ,completion: @escaping (Bool)->()) {
        
        let data = [
            "name": accomodation.name ?? "",
            "listingType": accomodation.listingType ?? [],
            "propertyCategory": accomodation.propertyCategory ?? [],
            "location": accomodation.location ?? "",
            "photoUrl": accomodation.photoUrl!,
            "rentPrice": accomodation.rentPrice ?? "",
            "bedroom": accomodation.bedroom ?? "",
            "bathroom": accomodation.bathroom ?? "",
            "facility": accomodation.facility ?? [],
            "addedByEmail": accomodation.addedByEmail ?? "",
            "addedByMobile": accomodation.addedByMobile ?? "",
            "addedByName": accomodation.addedByName ?? ""
        ] as [String: Any]

        self.db.collection("MarketPlace").addDocument(data: data) { err in
            if let err = err {
                showAlerOnTop(message: "Error adding document: \(err)")
            } else {
                completion(true)
            }
        }
    }
}



 


 

extension FireStoreManager {
    
  
    func removeLastMessageListner() {
        self.lastMessageListner?.remove()
    }
    
   
}
 
extension FireStoreManager {
    
    func resetMessageCount(mobile:String,chatID:String){
        
        lastMessages.document(mobile).collection("chats").document(chatID).updateData([ "messageCount": 0])
        
    }
}

extension FireStoreManager {
    
    func saveTextChat(sendToMobile:String,userEmail:String, text:String,time:Double,chatID:String,messageType:MessageType,filePath:String){
          
          let sendToMobile =  getFormatedNumber(mobile: sendToMobile)
          let chatDbRef = self.db.collection("Chat")
        
          let mobile = getFormatedNumber(mobile: getMobile())
         
         let msgType = messageType.rawValue
        
           
        
        let data = ["senderName" : mobile,"sender": mobile,"messageType":msgType,"dateSent":time,"chatId":chatID,"text" : text,"filePath":filePath] as [String : Any]
          
          let messagesCollection = chatDbRef.document(chatID).collection("Messages")
          let d = messagesCollection.addDocument(data: data)
          
        
          let ref2 = lastMessages.document(sendToMobile).collection("chats").document(chatID)
          let ref3 = lastMessages.document(mobile).collection("chats").document(chatID)

      
          let data3 = [
              "lastMessageDate": time,
              "lastMessageID": d.documentID,
              "lastMessageText": text,
              "lastMessageType": msgType,
              "messageCount": 0,
              "sender" : mobile,
              "sendTo" : sendToMobile,
              "filePath" : filePath
              
          ] as [String: Any]

          ref3.setData(data3) // set data under self message
                       
                       
              // Retrieve the current message count from the user's chat document
              ref2.getDocument { (document, error) in
                  if let document = document, document.exists {
                      var messageCount = document.data()?["messageCount"] as? Int ?? 0
                      messageCount += 1

                      let data2 = [
                          "lastMessageDate": time,
                          "lastMessageID": d.documentID,
                          "lastMessageText": text,
                          "lastMessageType": msgType,
                          "messageCount": messageCount,
                          "sender" : mobile,
                          "sendTo" : sendToMobile,
                          "filePath" : filePath
                      ] as [String: Any]

                      ref2.setData(data2)
                  }else {
                      
                      let data2 = [
                          "lastMessageDate": time,
                          "lastMessageID": d.documentID,
                          "lastMessageText": text,
                          "lastMessageType": msgType,
                          "messageCount": 1,
                          "sender" : mobile,
                          "sendTo" : sendToMobile,
                          "filePath" : filePath
                      ] as [String: Any]

                      ref2.setData(data2)
                      
                  }
           }
          
      }
    
      func getLatestMessages(chatID: String, completionHandler: @escaping ([QueryDocumentSnapshot]?, Error?) -> Void) {
          let chatDbRef = self.db.collection("Chat")
          let messagesCollection = chatDbRef.document(chatID).collection("Messages")
          
          // Query the last 1000 messages
          let query = messagesCollection.order(by: "dateSent", descending: true).limit(to: 1000)
          
          // Add a snapshot listener to the query
          query.addSnapshotListener { (querySnapshot, error) in
              if let error = error {
                  print("Error fetching documents: \(error)")
                  completionHandler(nil, error)
                  return
          }
              // Handle the snapshot data
              let documents = querySnapshot?.documents
              completionHandler(documents, nil)
          }
      }
    
}

extension FireStoreManager {
    
 
    
    func getLastMessagesAndMessageCount(completion: @escaping (Error?, [LastChatModel]?)->()) {
        
        lastMessageListner?.remove()
        
         let userId = getFormatedNumber(mobile: UserDefaultsManager.shared.getMobile()!)
            
            lastMessageListner = lastMessages.document(userId).collection("chats").addSnapshotListener { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        completion(err, nil)
                    } else {
                        var list: [LastChatModel] = []
                        for document in querySnapshot!.documents {
                            do {
                                var data = try document.data(as: LastChatModel.self)
                                data.documentId = document.documentID
                                list.append(data)
                            }catch let error {
                                print(error)
                            }
                        }
                        completion(nil, list)
                    }
              }
            
        
   
    }
    
    
    
    
}


extension FireStoreManager {
    
    
    func checkLastMessages() {
        
        self.getLastMessagesAndMessageCount{ error, lastChatModel in
            self.lastMessagesData = lastChatModel ?? []
            chatListVC?.lastMessages = lastChatModel ?? []
           
            if let msg = lastChatModel?.first?.lastMessageText {
              
                if(lastChatModel?.first?.messageCount.description == "0") {
                    return
                }
                showBanner = true
                
                if(!onChatScreen) {
                    if(showBanner == true  && lastChatModel?.first?.messageCount ?? 0 > 0) {
                        
                        let type = lastChatModel?.first?.lastMessageType ?? .TEXT
                        
                        if( type == .TEXT) {
                            
                            showInAppNotification(messageFrom:lastChatModel?.first?.sender ?? "1",  documentId: lastChatModel?.first?.documentId ?? "1", dataType: "text", title: msg, body: msg)
                        }else {
                            showInAppNotification(messageFrom:lastChatModel?.first?.sender ?? "1",  documentId: lastChatModel?.first?.documentId ?? "1", dataType: "text", title: "New \(type) Received", body: "New \(type) Received")
                        }
                        AudioServicesPlaySystemSound(SystemSoundID(1322))
                    }
                }
              //  showBanner = true
            }
          
        }
    }
}

    private func deleteTemporaryFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            print("Temporary file deleted successfully.")
        } catch {
            print("Error deleting temporary file: \(error.localizedDescription)")
        }
    }
 


func getFormatedNumber(mobile:String)->String {
    
    return formatPhoneNumber(mobile)
 
}


func formatPhoneNumber(_ phoneNumber: String) -> String {
   var formattedNumber = phoneNumber
   
   // Remove "+91" or "91"
   formattedNumber = formattedNumber.replacingOccurrences(of: "+91", with: "")
//   formattedNumber = formattedNumber.replacingOccurrences(of: "91", with: "")
   formattedNumber = formattedNumber.replacingOccurrences(of: " ", with: "")
   
   // Remove spaces and special characters using a regular expression
   formattedNumber = formattedNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
   
   return formattedNumber
}

