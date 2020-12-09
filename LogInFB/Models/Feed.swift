//
//  Feed.swift
//  LogInFB
//
//  Created by Deniz Adil on 30.11.20.
//

import UIKit
import Foundation

struct Feed: Codable {
    var id: String?
    var caption: String?
    var imageUrl: String?
    var creatorId: String?
    var createdAt: TimeInterval?
    var likeCount: Int?
    var shareCount: Int?
    var location: String?
    
}
