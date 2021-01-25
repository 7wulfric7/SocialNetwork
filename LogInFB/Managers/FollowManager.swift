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
    
    func followUser(user: User, completion: @escaping(_ success: Bool,_ error: Error?) -> Void) {
        DataStore.shared.followUser(user: user) { (following, error) in
            if let following = following {
                self.following.append(following)
                completion(true, nil)
                return
            }
            if let error = error {
                completion(false, error)
                return
            }
        }
        
    }
    
    func unfollowUser(_ user: User, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        guard let following = following.first(where: {$0.userId == user.id}), let followingId = following.id else { return }
        DataStore.shared.unfollow(followingId: followingId) { (success, error) in
            if success {
                self.following.removeAll(where: { $0.id == following.id})
                completion(true, nil)
                return
            }
            completion(false, error)
        }
    }
}
