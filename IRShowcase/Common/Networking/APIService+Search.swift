//
//  APIService+Search.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 31/05/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol APISearchItemsProtocol {
    func search100Items(query: String) -> SignalProducer<[Item], APIServiceError>
}

extension APIServiceImpl: APISearchItemsProtocol {
    func search100Items(query: String) -> SignalProducer<[Item], APIServiceError> {
        let properties = Resource.items(query: query, limit: 100).requestProperties
        let urlRequest = URLRequest(url: apiBaseUrl.appendingPathComponent(properties.path))
        
        let parseData: ((Data, URLResponse)) -> SignalProducer<[Item], APIServiceError> = { tuple in
            return SignalProducer { observer, _ in
                do {
                    let results = try JSONDecoder().decode([Item].self, from: tuple.0)
                    observer.send(value: results)
                } catch {
                    observer.send(error: APIServiceError.parsing(error: error))
                }
            }
        }
        
        return session.fetchData(urlRequest)
            .mapError { APIServiceError.network(error: $0) }
            .flatMap(.latest, parseData)
    }
}
