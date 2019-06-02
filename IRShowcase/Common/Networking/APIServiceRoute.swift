//
//  APIServiceRoute.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 20/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

enum APIServiceRouting {
    case posts
    case post(id: String)
    
    var requestProperties: (method: RequestMethod, path: String, query: [String: Any]) {
        switch self {
        case .posts:
            return (.GET, "/v1/posts", [:])
        case let .post(id):
            var params: [String: Any] = [:]
            params["id"] = id
            return (.GET, "/v1/post", params)
        }
    }
}
