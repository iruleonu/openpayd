//
//  Fetchable.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 21/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol Fetchable {
    associatedtype I
    associatedtype V
    associatedtype E: Error
    func fetchData(_ input: I) -> SignalProducer<V, E>
}

protocol URLRequestFetchable {
    func fetchData(request: URLRequest) -> SignalProducer<(Data, URLResponse), DataProviderError>
}
