//
//  User.swift
//  LogInFB
//
//  Created by Deniz Adil on 11/11/20.
//

import Foundation


struct User: Codable {
    var email: String?
    var fullName: String?
    var dob: String?
    var gender: String?
    var aboutMe: String?
    var id: String?
    var location: String?
    var imageUrl: String?
    var moments: Int?
    var followers: Int?
    var following: Int?
    var likedMoments: [String]? = [String]()
    
    
    init(id: String) {
        self.id = id
    }
    func save() {
        
        DataStore.shared.setUserData(user: self) { (_, _) in }
    }
}

