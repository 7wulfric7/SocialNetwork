//
//  Comment.swift
//  LogInFB
//
//  Created by Deniz Adil on 16.12.20.
//

import Foundation

struct Comment: Codable {
    var id: String?
    var creatorId: String?
    var momentId: String?
    var createdAt: TimeInterval?
    var body: String?
    
}
