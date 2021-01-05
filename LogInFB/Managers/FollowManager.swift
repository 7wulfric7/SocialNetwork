//
//  FollowManager.swift
//  LogInFB
//
//  Created by Deniz Adil on 28.12.20.
//

import Foundation

class FollowManager {
    static let shared = FollowManager()
    init(){}
    
    var following = [Follow]()
    var followers = [Follow]()
    
  func  getFollowing() {
        DataStore.shared.getFollowings { (followings, error) in
            NotificationCenter.default.post(name: Notification.Name("ReloadAfterUserAction"), object: nil)

            if let followings = followings {
            self.following = followings
        }
    }
}
    func getFollowers() {
        DataStore.shared.getFollowers { (followers, error) in
            NotificationCenter.default.post(name: Notification.Name("ReloadAfterUserAction"), object: nil)

            if let followers = followers {
            self.followers = followers
            }
        }
    }
}
