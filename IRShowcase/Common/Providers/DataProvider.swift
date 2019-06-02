//
//  BaseDataProvider.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 22/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import ReactiveSwift
import enum Result.Result
import enum Result.NoError

typealias DataProviderNetworkProtocol = APIURLRequestProtocol & URLRequestFetchable
typealias DataProviderPersistenceProtocol = PersistenceLayerLoad & PersistenceLayerSave & PersistenceLayerRemove

enum DataProviderSource {
    case local
    case remote
}

enum DataProviderFetchType {
    case config // defaults to the used data provider configuration
    case local
    case remote
}

protocol DataProviderProtocol {
    associatedtype T: Codable
    var config: DataProviderConfiguration { get }
    var network: DataProviderNetworkProtocol { get }
    var persistence: DataProviderPersistenceProtocol { get }
    var handlers: DataProviderHandlers<T> { get }
    func fetchStuff(resource: Resource) -> SignalProducer<(T, DataProviderSource), DataProviderError>
    func fetchStuff(resource: Resource, explicitFetchType: DataProviderFetchType) -> SignalProducer<(T, DataProviderSource), DataProviderError>
}

struct DataProviderConfiguration {
    static let standard: DataProviderConfiguration = remoteIfErrorUseLocal
    
    static let localOnly: DataProviderConfiguration = {
        return DataProviderConfiguration(persistenceEnabled: true, remoteEnabled: false, remoteFirst: false)
    }()
    
    static let remoteOnly: DataProviderConfiguration = {
        return DataProviderConfiguration(persistenceEnabled: false, remoteEnabled: true, remoteFirst: true)
    }()
    
    static let localIfErrorUseRemote: DataProviderConfiguration = {
        return DataProviderConfiguration(persistenceEnabled: true, remoteEnabled: true, remoteFirst: false)
    }()
    
    static let remoteIfErrorUseLocal: DataProviderConfiguration = {
        return DataProviderConfiguration(persistenceEnabled: true, remoteEnabled: true, remoteFirst: true)
    }()
    
    let persistenceEnabled: Bool
    let remoteEnabled: Bool
    let remoteFirst: Bool
    
    init(persistenceEnabled pe: Bool, remoteEnabled re: Bool, remoteFirst rf: Bool) {
        persistenceEnabled = pe
        remoteEnabled = re
        remoteFirst = rf
    }
}

struct DataProviderHandlers<T: Codable> {
    typealias NetworkHandler = (URLRequestFetchable, URLRequest) -> SignalProducer<Data, DataProviderError>
    typealias NetworkParserHandler = (Data) -> SignalProducer<T, DataProviderError>
    typealias PersistenceSaveHandler = (PersistenceLayerSave, T) -> SignalProducer<T, DataProviderError>
    typealias PersistenceLoadHandler = (PersistenceLayerLoad, Resource) -> SignalProducer<T, DataProviderError>
    typealias PersistenceRemoveHandler = (PersistenceLayerRemove, Resource) -> SignalProducer<Bool, DataProviderError>

    let networkHandler: NetworkHandler
    let networkParserHandler: NetworkParserHandler
    let persistenceSaveHandler: PersistenceSaveHandler
    let persistenceLoadHandler: PersistenceLoadHandler
    let persistenceRemoveHandler: PersistenceRemoveHandler
    
    init(networkHandler nh: @escaping NetworkHandler = { (_, _) in SignalProducer.empty },
         networkParserHandler nph: @escaping NetworkParserHandler = { _ in SignalProducer.empty },
         persistenceSaveHandler psh: @escaping PersistenceSaveHandler = { (_, _) in SignalProducer.empty },
         persistenceLoadHandler plh: @escaping PersistenceLoadHandler = { (_, _) in SignalProducer.empty },
         persistenceRemoveHandler prh: @escaping PersistenceRemoveHandler = { (_, _) in SignalProducer.empty }) {
        networkHandler = nh
        networkParserHandler = nph
        persistenceSaveHandler = psh
        persistenceLoadHandler = plh
        persistenceRemoveHandler = prh
    }
}

struct DataProvider<Type: Codable>: DataProviderProtocol {
    typealias T = Type
    let config: DataProviderConfiguration
    let network: DataProviderNetworkProtocol
    let persistence: DataProviderPersistenceProtocol
    let handlers: DataProviderHandlers<T>
    
    init(config c: DataProviderConfiguration, network n: DataProviderNetworkProtocol, persistence p: DataProviderPersistenceProtocol, handlers h: DataProviderHandlers<T>) {
        config = c
        network = n
        persistence = p
        handlers = h
    }
    
    func fetchStuff(resource: Resource) -> SignalProducer<(T, DataProviderSource), DataProviderError> {
        return fetchData((resource, .config))
    }
    
    func fetchStuff(resource: Resource, explicitFetchType: DataProviderFetchType) -> SignalProducer<(T, DataProviderSource), DataProviderError> {
        return fetchData((resource, explicitFetchType))
    }
}

extension DataProvider {
    func saveToPersistence(_ elements: T) -> SignalProducer<T, DataProviderError> {
        return handlers.persistenceSaveHandler(persistence, elements)
    }
    
    func removeEntities(forResource resource: Resource) -> SignalProducer<Bool, DataProviderError> {
        return handlers.persistenceRemoveHandler(persistence, resource)
    }
}

extension DataProvider: Fetchable {
    typealias E = DataProviderError
    typealias I = (Resource, DataProviderFetchType)
    typealias V = (T, DataProviderSource)
    
    func fetchData(_ input: I) -> SignalProducer<(T, DataProviderSource), DataProviderError> {
        switch input.1 {
        case .config:
            return fetchForTypeConfig(input: input.0)
        case .local:
            return fetchForTypeLocal(input: input.0)
        case .remote:
            return fetchForTypeRemote(input: input.0)
        }
    }
    
    private func fetchForTypeConfig(input: Resource) -> SignalProducer<(T, DataProviderSource), DataProviderError> {
        // Guard for just local data provider config
        guard config.remoteEnabled else {
            return persistenceLoadProducer(resource: input)
        }
        
        // Guard for just remote data provider config
        guard config.persistenceEnabled else {
            return remoteProducer(resource: input)
        }
        
        // Hybrid
        // Guard for persistenceFirst - Load persisted values first, fallback to remote when the local fetch fails
        guard config.remoteFirst else {
            return persistenceLoadProducer(resource: input)
                .concat( self.remoteProducer(resource: input).flatMapError { _ in SignalProducer.empty })
                .flatMapError { _ in self.remoteProducer(resource: input) }
        }
        
        // Load remotely first, fallback to the persisted values when the remote fetch fails
        return remoteProducer(resource: input)
            .concat( self.persistenceLoadProducer(resource: input).flatMapError { _ in SignalProducer.empty })
            .flatMapError { _ in self.persistenceLoadProducer(resource: input) }
    }
    
    private func fetchForTypeLocal(input: Resource) -> SignalProducer<(T, DataProviderSource), DataProviderError> {
        return persistenceLoadProducer(resource: input)
    }
    
    private func fetchForTypeRemote(input: Resource) -> SignalProducer<(T, DataProviderSource), DataProviderError> {
        return remoteProducer(resource: input)
    }
    
    private func persistenceLoadProducer(resource: Resource) -> SignalProducer<V, DataProviderError> {
        return handlers
            .persistenceLoadHandler(persistence, resource)
            .start(on: QueueScheduler(name: "DataProvider.persistenceProducer"))
            .map({ ($0, .local) })
            .mapError({ DataProviderError.persistence(error: $0) })
    }
    
    private func remoteProducer(resource: Resource) -> SignalProducer<V, DataProviderError> {
        return handlers
            .networkHandler(network, network.buildUrlRequest(resource: resource))
            .start(on: QueueScheduler(name: "DataProvider.networkHandler"))
            .flatMap(.latest, handlers.networkParserHandler)
            .map({ ($0, .remote) })
            .start(on: QueueScheduler(name: "DataProvider.parserHandler"))
    }
}

// MARK: Type erasure
private class AnyDataProviderBase<Type: Codable>: DataProviderProtocol {
    typealias T = Type
    // swiftlint:disable implicit_getter
    var config: DataProviderConfiguration {
        get { fatalError("Must override") }
    }
    var network: DataProviderNetworkProtocol {
        get { fatalError("Must override") }
    }
    var persistence: DataProviderPersistenceProtocol {
        get { fatalError("Must override") }
    }
    var handlers: DataProviderHandlers<Type> {
        get { fatalError("Must override") }
    }
    // swiftlint:enable implicit_getter

    init() {
        guard type(of: self) != AnyDataProviderBase.self else {
            fatalError("AnyDataProvider<Model> instances can not be created; create a subclass instance instead")
        }
    }

    func fetchStuff(resource: Resource) -> SignalProducer<(T, DataProviderSource), DataProviderError> {
        fatalError("Must override")
    }
    
    func fetchStuff(resource: Resource, explicitFetchType: DataProviderFetchType) -> SignalProducer<(Type, DataProviderSource), DataProviderError> {
        fatalError("Must override")
    }
}

private final class AnyDataProviderBox<Concrete: DataProviderProtocol>: AnyDataProviderBase<Concrete.T> {
    // swiftlint:disable implicit_getter
    override var config: DataProviderConfiguration {
        get {
            return concrete.config
        }
    }
    override var network: DataProviderNetworkProtocol {
        get {
            return concrete.network
        }
    }
    override var persistence: DataProviderPersistenceProtocol {
        get {
            return concrete.persistence
        }
    }
    override var handlers: DataProviderHandlers<Concrete.T> {
        get {
            return concrete.handlers
        }
    }
    // swiftlint:enable implicit_getter

    // variable used since we're calling mutating functions
    var concrete: Concrete

    init(_ concrete: Concrete) {
        self.concrete = concrete
        super.init()
    }

    // Trampoline functions forward along to base
    override func fetchStuff(resource: Resource) -> SignalProducer<(T, DataProviderSource), DataProviderError> {
        return concrete.fetchStuff(resource: resource)
    }
    
    override func fetchStuff(resource: Resource, explicitFetchType: DataProviderFetchType) -> SignalProducer<(T, DataProviderSource), DataProviderError> {
        return concrete.fetchStuff(resource: resource, explicitFetchType: explicitFetchType)
    }
}

final class AnyDataProvider<Type: Codable>: DataProviderProtocol {
    typealias T = Type
    // swiftlint:disable implicit_getter
    var config: DataProviderConfiguration {
        get {
            return box.config
        }
    }
    var network: DataProviderNetworkProtocol {
        get {
            return box.network
        }
    }
    var persistence: DataProviderPersistenceProtocol {
        get {
            return box.persistence
        }
    }
    var handlers: DataProviderHandlers<Type> {
        get {
            return box.handlers
        }
    }
    // swiftlint:enable implicit_getter

    private let box: AnyDataProviderBase<Type>

    init<Concrete: DataProviderProtocol>(_ concrete: Concrete) where Concrete.T == Type {
        box = AnyDataProviderBox(concrete)
    }

    func fetchStuff(resource: Resource) -> SignalProducer<(T, DataProviderSource), DataProviderError> {
        return box.fetchStuff(resource: resource)
    }
    
    func fetchStuff(resource: Resource, explicitFetchType: DataProviderFetchType) -> SignalProducer<(T, DataProviderSource), DataProviderError> {
        return box.fetchStuff(resource: resource, explicitFetchType: explicitFetchType)
    }
}
