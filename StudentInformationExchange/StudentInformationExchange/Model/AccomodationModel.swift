import UIKit
import Foundation
import UIKit

struct AccomodationModel: Codable {
    var name: String?
    var listingType: [String]?
    var propertyCategory: [String]?
    var location: String?
    var photo: [UIImage]?
    var rentPrice: String?
    var bedroom: String?
    var bathroom: String?
    var facility: [String]?
    var photoUrl: [String]?
    var documentId:String?
    var rating : Double?
    var addedByEmail:String?
    var addedByMobile:String?
    var addedByName:String?

    enum CodingKeys: String, CodingKey {
        case name
        case listingType
        case propertyCategory
        case location
        case rentPrice
        case bedroom
        case bathroom
        case facility
        case photoUrl
        case addedByEmail
        case addedByMobile
        case addedByName
    }

    init(name: String? = nil, listingType: [String]? = nil, propertyCategory: [String]? = nil, location: String? = nil, photo: [UIImage]? = nil, rentPrice: String? = nil, bedroom: String? = nil, bathroom: String? = nil, facility: [String]? = nil, photoUrl: [String]? = nil) {
        self.name = name
        self.listingType = listingType
        self.propertyCategory = propertyCategory
        self.location = location
        self.photo = photo
        self.rentPrice = rentPrice
        self.bedroom = bedroom
        self.bathroom = bathroom
        self.facility = facility
        self.photoUrl = photoUrl
    }
 
}
