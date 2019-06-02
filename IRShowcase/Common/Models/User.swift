//
//  User.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

struct User: Codable {
    let id: Int
    let email: String
    let name: String
    let username: String
    
    private enum Constants: Int {
        case defaultId = -1
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case username
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let email = try container.decode(String.self, forKey: .email)
        let name = try container.decode(String.self, forKey: .name)
        let username = try container.decode(String.self, forKey: .username)
        self.init(id: id, email: email, name: name, username: username)
    }
    
    init(id: Int = Constants.defaultId.rawValue, email: String, name: String = "", username: String = "") {
        self.id = id
        self.email = email
        self.name = name
        self.username = username
    }
}

extension User: Equatable {
    static func == (left: User, right: User) -> Bool {
        return left.id == right.id
    }
}
