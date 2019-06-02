//
//  Comment.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

struct Comment: Codable {
    let id: Int
    let postId: Int
    let name: String
    let email: String
    let body: String
    
    private enum Constants: Int {
        case defaultId = -1
        case defaultUserId = -2
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case postId
        case name
        case email
        case body
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let postId = try container.decode(Int.self, forKey: .postId)
        let name = try container.decode(String.self, forKey: .name)
        let email = try container.decode(String.self, forKey: .email)
        let body = try container.decode(String.self, forKey: .body)
        self.init(id: id, postId: postId, name: name, email: email, body: body)
    }
    
    init(id: Int = Constants.defaultId.rawValue, postId: Int, name: String = "", email: String, body: String = "") {
        self.id = id
        self.postId = postId
        self.name = name
        self.email = email
        self.body = body
    }
}

extension Comment: Equatable {
    static func == (left: Comment, right: Comment) -> Bool {
        return left.id == right.id && left.postId == right.postId && left.name == right.name && left.body == right.body
    }
}
