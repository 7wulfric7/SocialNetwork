//
//  DataStore.swift
//  LogInFB
//
//  Created by Deniz Adil on 11/11/20.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseAuth

typealias FeedItemsCompletion = ((_ items: [Feed]?,_ error: Error?) -> Void)

class DataStore {
    static let shared = DataStore()
    init() {}
    
    var localUser: User?
    private let storage = Storage.storage()
    
    private let database = Firestore.firestore()
    
    func setUserData(user: User, completion: @escaping (_ success: Bool,_ error: Error?)-> Void) {
        guard let uid = user.id else {
            completion(false,nil)
            return
        }
        do {
            
            let usersRef = database.collection("users").document(uid)
            try usersRef.setData(from: user, completion: { error in
                if let loggedInUser = Auth.auth().currentUser, loggedInUser.uid == uid {
                    self.localUser = user
                }
                if let error = error {
                    completion(false, error)
                        return
                }
                completion(true, nil)
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    func getUser(uid: String, completion: @escaping (_ user: User?, _ error: Error?)-> Void) {
        let userRef = database.collection("users").document(uid)
        userRef.getDocument { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
        if let document = snapshot {
            do {
                let user = try document.data(as: User.self)
                completion(user, nil)
            } catch {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
}
    func uploadImage(image: UIImage, itemId: String, isUserImage: Bool = true, completion: @escaping (_ imageUrl: URL?,_ error: Error?) -> Void) {
        var imageRef = storage.reference()
        if isUserImage {
            imageRef = imageRef.child("profile_pictures/" + itemId + ".jpg")
        } else {
            imageRef = imageRef.child("feed_images/" + itemId + ".jpg")
        }
        let imageData = image.jpegData(compressionQuality: 0.1)
        guard let data = imageData else {
            completion(nil, nil)
            return
        }
        imageRef.putData(data, metadata: nil) { (metadata, error) in
            guard let _ = metadata else {
                completion(nil, nil)
                return
            }
            imageRef.downloadURL { (imageUrl, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                completion(imageUrl, nil)
            }
        }
    }
    
    func getAllUsers(completion: @escaping (_ user: [User]?, _ error: Error?) -> Void) {
       
//        let userss = [User]()
//                let userNames = userss.compactMap({ $0.email })
//                //CompactMap done with For in
//                var userEmails = [String]()
//                for user in userss {
//                    if let email = user.email {
//                        userEmails.append(email)
//                    }
//                }
//                //CompactMap done with Foreach
//                userss.forEach { user in
//                    if let email = user.email {
//                        userEmails.append(email)
//                    }
//                }
        
        let usersRef = database.collection("users")
        usersRef.getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            if let snapshot = snapshot {
                do {
                    let users = try snapshot.documents.compactMap({ try $0.data(as: User.self) })
                    completion(users, nil)
                } catch (let error) {
                    completion(nil, error)
                }
            }
        }
    }
    func cerateFeedItem(item: Feed, completion: @escaping (_ item: Feed?,_ error: Error?) -> Void) {
        var newItem = item
        let feedRef = database.collection("feed").document()
        newItem.id = feedRef.documentID
        do {
           try feedRef.setData(from: newItem) { error in
                completion(newItem, error)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    func fetchFeedItems(completion: @escaping FeedItemsCompletion) {
        let feedRef = database.collection("feed")
//        collection reference is a subclass of Query, so it can be casted to Query
        var feedQuery: Query = feedRef
        if let localUser = DataStore.shared.localUser, let blockedUsers = localUser.blockedUsersID, blockedUsers.count > 0 {
            feedQuery = feedRef.whereField("creatorId", notIn: blockedUsers)
        }
        feedQuery.getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            if let snapshot = snapshot {
                do {
                    let feeds = try snapshot.documents.compactMap({ try $0.data(as: Feed.self) })
                    completion(feeds, nil)
                } catch (let error) {
                    completion(nil, error)
                }
            }
        }
    }
}
