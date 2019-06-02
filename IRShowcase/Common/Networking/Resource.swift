//
//  APIServiceRoute.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 20/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

enum Resource {
    case unknown
    case items(query: String, limit: Int)
    case audiobook(id: String)
    case track(id: String)
    case posts
    case post(id: String)
    case comments(postId: String)
    case user(id: String)
}

extension Resource {
    var requestProperties: (method: RequestMethod, path: String, query: [String: Any]) {
        switch self {
        case .unknown:
            return (.GET, "/", [:])
        case let .items(query, limit):
            var params: [String: Any] = [:]
            params["term"] = query
            params["limit"] = limit
            return (.GET, "/search", params)
        default:
            return (.GET, "/", [:])
        }
    }
    
    func buildUrlRequest(apiBaseUrl: URL) -> URLRequest {
        var components = URLComponents(url: apiBaseUrl, resolvingAgainstBaseURL: false)
        components?.queryItems = Resource.buildQueryItems(requestProperties.query)
        components?.path = requestProperties.path
        let finalURL = components?.url ?? apiBaseUrl
        let request = NSMutableURLRequest(url: finalURL)
        request.httpMethod = requestProperties.method.rawValue
        return request as URLRequest
    }
    
    fileprivate static func buildQueryItems(_ query: [String: Any]) -> [URLQueryItem]? {
        guard !query.isEmpty else { return nil }
        return query.compactMap({ tuple in
            guard let value = tuple.value as? String else { return nil }
            return URLQueryItem(name: tuple.key, value: value)
        })
    }
}

extension Resource: Equatable {
    static func == (lhs: Resource, rhs: Resource) -> Bool {
        let samePath: Bool
        let sameParams: Bool
        
        switch (lhs.requestProperties, rhs.requestProperties) {
        case (let (_, lPath, lParams), let (_, rPath, rParams)):
            samePath = lPath == rPath
            let lQueryItems = Resource.buildQueryItems(lParams)
            let rQueryItems = Resource.buildQueryItems(rParams)
            sameParams = lQueryItems == rQueryItems
        }
        
        return samePath && sameParams
    }
}
