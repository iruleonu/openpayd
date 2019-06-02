//
//  URLSession.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 21/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import ReactiveSwift

extension URLSession: Fetchable {
    func fetchData(_ request: URLRequest) -> SignalProducer<(Data, URLResponse), DataProviderError> {
        return reactive
            .data(with: request)
            .mapError(DataProviderError.requestError)
    }
}
