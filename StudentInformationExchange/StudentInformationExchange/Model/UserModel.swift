//
//  UserModel.swift
//  StudentInformationExchange
//
//  Created by Macbook-Pro on 21/11/23.
//

import Foundation

struct UserRegistrationModel {
    var name: String?
    var email: String?
    var dob: String?
    var mobile: String?
    var password: String?

    init(name: String?, email: String?, dob: String?, mobile: String?, password: String?) {
        self.name = name
        self.email = email
        self.dob = dob
        self.mobile = mobile
        self.password = password
    }
}

struct User : Codable {
    var email: String?
    var name: String?
    var documentId:String?
    var mobile:String?
}
