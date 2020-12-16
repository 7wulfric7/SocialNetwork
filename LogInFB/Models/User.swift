//
//  User.swift
//  LogInFB
//
//  Created by Deniz Adil on 11/11/20.
//

import Foundation

typealias UserSaveCompletion = (_ success: Bool,_ error: Error?)-> Void

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
    var blockedUsersID: [String]? = [String]()
    var followingUsersID: [String]? = [String]()
    
    init(id: String) {
        self.id = id
    }
    func save(completion: UserSaveCompletion?) {
//        DataStore.shared.localUser = self
        DataStore.shared.setUserData(user: self) { (success, error) in
            completion?(success, error)
        }
    }
}

