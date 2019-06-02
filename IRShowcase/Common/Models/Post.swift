//
//  Post.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 20/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

struct Post: Codable {
    let id: Int
    let userId: Int
    var title: String
    var body: String
    
    private enum Constants: Int {
        case defaultId = -1
        case defaultUserId = -2
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case body
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let userId = try container.decode(Int.self, forKey: .userId)
        let title = try container.decode(String.self, forKey: .title)
        let body = try container.decode(String.self, forKey: .body)
        self.init(id: id, userId: userId, title: title, body: body)
    }
    
    init(id: Int = Constants.defaultId.rawValue, userId: Int = Constants.defaultUserId.rawValue, title: String = "", body: String = "") {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
    }
}

extension Post: Equatable {
    static func == (left: Post, right: Post) -> Bool {
        return left.id == right.id && left.userId == right.userId && left.title == right.title && left.body == right.body
    }
}
