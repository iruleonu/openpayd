//
//  DataProviderHandlersBuilder.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import ReactiveSwift

struct DataProviderHandlersBuilder<T: Codable> {
    let standardNetworkHandler: DataProviderHandlers<T>.NetworkHandler = { (fetchable, urlRequest) in
        let network: ((Data, URLResponse)) -> SignalProducer<Data, DataProviderError> = { tuple in
            return SignalProducer { observer, _ in
                if let cast = tuple.1 as? HTTPURLResponse, cast.statusCode == 400 {
                    let error = NSError.error(withMessage: "DataProviderHandlers", statusCode: cast.statusCode)
                    observer.send(error: .requestError(error: error))
                    return
                }
                observer.send(value: tuple.0)
            }
        }
        return fetchable.fetchData(request: urlRequest).flatMap(.latest, network)
    }
    let standardNetworkParserHandler: DataProviderHandlers<T>.NetworkParserHandler = { data in
        return SignalProducer { observer, _ in
            do {
                let results = try JSONDecoder().decode(T.self, from: data)
                observer.send(value: results)
            } catch {
                observer.send(error: .parsing(error: error))
            }
        }
    }
    let standardPersistenceSaveHandler: DataProviderHandlers<T>.PersistenceSaveHandler = { (persistenceLayer, codables) in
        return SignalProducer { observer, _ in
            _ = persistenceLayer.persistObjects(codables, saveCompletion: { _, error in
                if let e = error {
                    observer.send(error: DataProviderError.persistence(error: e))
                    return
                }
                observer.send(value: codables)
            })
        }
    }
    let standardPersistenceLoadHandler: DataProviderHandlers<T>.PersistenceLoadHandler = { (persistenceLayer, resource) in
        return persistenceLayer
            .fetchResource(resource)
            .mapError({ DataProviderError.persistence(error: $0) })
    }
    let standardPersistenceRemoveHandler: DataProviderHandlers.PersistenceRemoveHandler = { (persistenceLayer, resource) in
        return persistenceLayer.removeResource(resource).mapError({ DataProviderError.persistence(error: $0) })
    }
    
    // Disable force_cast because this we need to use it to help the compiler with the associatedType
    // swiftlint:disable force_cast
    func makeDataProviderHandlers<T: Codable>(config: DataProviderConfiguration) -> DataProviderHandlers<T> {
        var networkHandler: DataProviderHandlers<T>.NetworkHandler
        var networkParserHandler: DataProviderHandlers<T>.NetworkParserHandler
        var persistenceSaveHandler: DataProviderHandlers<T>.PersistenceSaveHandler
        var persistenceLoadHandler: DataProviderHandlers<T>.PersistenceLoadHandler
        var persistenceRemoveHandler: DataProviderHandlers<T>.PersistenceRemoveHandler
        
        if config.persistenceEnabled {
            persistenceSaveHandler = standardPersistenceSaveHandler as! DataProviderHandlers<T>.PersistenceSaveHandler
            persistenceLoadHandler = standardPersistenceLoadHandler as! DataProviderHandlers<T>.PersistenceLoadHandler
            persistenceRemoveHandler = standardPersistenceRemoveHandler
        } else {
            persistenceSaveHandler = { _, _ in
                return SignalProducer<T, DataProviderError>({ (observer, _) in
                    observer.send(error: DataProviderError.persistence(error: PersistenceLayerError.disabled))
                })
            }
            persistenceLoadHandler = { _, _ in
                return SignalProducer<T, DataProviderError>({ (observer, _) in
                    observer.send(error: DataProviderError.persistence(error: PersistenceLayerError.disabled))
                })
            }
            persistenceRemoveHandler = { _, _ in
                return SignalProducer<Bool, DataProviderError>({ (observer, _) in
                    observer.send(error: DataProviderError.persistence(error: PersistenceLayerError.disabled))
                })
            }
        }
        
        if config.remoteEnabled {
            networkHandler = standardNetworkHandler
            networkParserHandler = standardNetworkParserHandler as! DataProviderHandlers<T>.NetworkParserHandler
        } else {
            networkHandler = { _, _ in
                return SignalProducer({ (observer, _) in
                    observer.send(error: DataProviderError.networkingDisabled)
                })
            }
            networkParserHandler = { _ in SignalProducer.empty }
        }
        
        return DataProviderHandlers(networkHandler: networkHandler,
                                    networkParserHandler: networkParserHandler,
                                    persistenceSaveHandler: persistenceSaveHandler,
                                    persistenceLoadHandler: persistenceLoadHandler,
                                    persistenceRemoveHandler: persistenceRemoveHandler)
    }
    // swiftlint:enable force_cast
}
