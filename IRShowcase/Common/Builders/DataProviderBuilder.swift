//
//  DataProviderFactory.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 25/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import ReactiveSwift

struct DataProviderBuilder {
    static func makeDataProvider<T: Codable>(config: DataProviderConfiguration, network: DataProviderNetworkProtocol, persistence: DataProviderPersistenceProtocol) -> DataProvider<T> {
        let handlersFactory: DataProviderHandlersBuilder<T> = DataProviderHandlersBuilder()
        let handlers: DataProviderHandlers<T> = handlersFactory.makeDataProviderHandlers(config: config)
        return DataProvider<T>(config: config, network: network, persistence: persistence, handlers: handlers)
    }
}
