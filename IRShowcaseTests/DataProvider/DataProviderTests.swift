//
//  DataProviderTests.swift
//  IRShowcaseTests
//
//  Created by Nuno Salvador on 24/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SwiftyMocky
import ReactiveSwift

@testable import IRShowcase

class DataProvidersTests: QuickSpec {
    override func spec() {
        describe("DataProvidersTests") {
            var localDataProvider: DataProvider<[Post]>!
            var remoteDataProvider: DataProvider<[Post]>!
            var hybridLocalFirstDataProvider: DataProvider<[Post]>!
            var hybridRemoteFirstDataProvider: DataProvider<[Post]>!
            let network = APIServiceMock()
            let persistence = PersistenceLayerMock()
            
            beforeEach {
                let localConfig = DataProviderConfiguration.localOnly
                let remoteConfig = DataProviderConfiguration.remoteOnly
                let hybridLocalConfig = DataProviderConfiguration.localIfErrorUseRemote
                let hybridRemoteConfig = DataProviderConfiguration.remoteIfErrorUseLocal
                let ldp: DataProvider<[Post]> = DataProviderBuilder.makeDataProvider(config: localConfig, network: network, persistence: persistence)
                let rdp: DataProvider<[Post]> = DataProviderBuilder.makeDataProvider(config: remoteConfig, network: network, persistence: persistence)
                let hldp: DataProvider<[Post]> = DataProviderBuilder.makeDataProvider(config: hybridLocalConfig, network: network, persistence: persistence)
                let hrdp: DataProvider<[Post]> = DataProviderBuilder.makeDataProvider(config: hybridRemoteConfig, network: network, persistence: persistence)
                localDataProvider = ldp
                remoteDataProvider = rdp
                hybridLocalFirstDataProvider = hldp
                hybridRemoteFirstDataProvider = hrdp
            }
            
            afterEach {
                localDataProvider = nil
                remoteDataProvider = nil
                hybridLocalFirstDataProvider = nil
                hybridRemoteFirstDataProvider = nil
            }
            
            describe("remote data provider") {
                context("fetch stuff method") {
                    it("should get a success result on the happy path") {
                        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                        Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                            let posts: [Post] = Factory.arrayReponse(from: "posts", extension: "json")
                            var data: Data? = nil
                            
                            do {
                                let jsonData = try JSONEncoder().encode(posts)
                                data = jsonData
                            } catch { }
                            
                            if let d = data {
                                observer.send(value: (d, URLResponse()))
                            } else {
                                observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
                            }
                        })))
                        
                        waitUntil(action: { (done) in
                            remoteDataProvider.fetchStuff(resource: .posts).startWithResult({ (result) in
                                switch result {
                                case .failure:
                                    fail()
                                case .success(let values):
                                    expect(values.0.count).to(equal(100))
                                }
                                done()
                            })
                        })
                    }
                    
                    it("should fail before the parsing step when receives generic/empty data") {
                        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                        Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                            observer.send(value: (NSData() as Data, URLResponse()))
                        })))
                        
                        waitUntil(action: { (done) in
                            remoteDataProvider.fetchStuff(resource: .posts).startWithResult({ (result) in
                                switch result {
                                case .failure(let error):
                                    expect(error.errorDescription).to(equal(DataProviderError.parsing(error: DataProviderError.unknown).errorDescription))
                                case .success:
                                    fail()
                                }
                                done()
                            })
                        })
                    }
                }
            }
            
            describe("local data provider") {
                context("fetch stuff method") {
                    it("should get a success result on the happy path") {
                        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
                            observer.send(value: [Post(id: 0, userId: 0, title: "", body: "")])
                        })))
                        
                        waitUntil(action: { (done) in
                            localDataProvider.fetchStuff(resource: .posts).startWithResult({ (result) in
                                switch result {
                                case .failure:
                                    fail()
                                case .success(let values):
                                    expect(values.0.count).to(equal(1))
                                }
                                done()
                            })
                        })
                    }
                    
                    it("should get a response after persistence error") {
                        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
                            observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "No known resource")))
                        })))
                        
                        waitUntil(action: { (done) in
                            localDataProvider.fetchStuff(resource: .posts).startWithResult({ (result) in
                                switch result {
                                case .failure:
                                    break
                                case .success:
                                    fail()
                                }
                                done()
                            })
                        })
                    }
                }
            }
            
            describe("hybrid local first data provider") {
                context("fetch stuff method") {
                    it("should get a success result on the happy path") {
                        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
                            observer.send(value: [Post(id: 0, userId: 0, title: "", body: "")])
                        })))
                        Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                            let posts: [Post] = Factory.arrayReponse(from: "posts", extension: "json")
                            var data: Data? = nil
                            
                            do {
                                let jsonData = try JSONEncoder().encode(posts)
                                data = jsonData
                            } catch { }
                            
                            if let d = data {
                                observer.send(value: (d, URLResponse()))
                            } else {
                                observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
                            }
                        })))
                        
                        waitUntil(action: { (done) in
                            hybridLocalFirstDataProvider.fetchStuff(resource: .posts).startWithResult({ (result) in
                                switch result {
                                case .failure:
                                    fail()
                                case .success(let values):
                                    expect(values.0.count).to(equal(1))
                                }
                                done()
                            })
                        })
                    }
                    
                    it("should error if both layers returns an error and/or invalid data") {
                        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
                            observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "Error")))
                        })))
                        Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                            observer.send(value: (NSData() as Data, URLResponse()))
                        })))
                        
                        waitUntil(action: { (done) in
                            hybridLocalFirstDataProvider.fetchStuff(resource: .posts).startWithResult({ (result) in
                                switch result {
                                case .failure:
                                    break
                                case .success:
                                    fail()
                                }
                                done()
                            })
                        })
                    }
                    
                    it("should get persisted posts even if parsing step after network fails") {
                        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
                            observer.send(value: [Post(id: 0, userId: 0, title: "", body: "")])
                        })))
                        Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                            observer.send(value: (NSData() as Data, URLResponse()))
                        })))
                        
                        waitUntil(action: { (done) in
                            hybridLocalFirstDataProvider.fetchStuff(resource: .posts).startWithResult({ (result) in
                                switch result {
                                case .failure:
                                    fail()
                                case .success(let values):
                                    expect(values.0.count).to(equal(1))
                                }
                                done()
                            })
                        })
                    }
                    
                    it("should get network posts if theres was an error on the persistence layer") {
                        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
                            observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "Error")))
                        })))
                        Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                            let posts: [Post] = Factory.arrayReponse(from: "posts", extension: "json")
                            var data: Data? = nil
                            
                            do {
                                let jsonData = try JSONEncoder().encode(posts)
                                data = jsonData
                            } catch { }
                            
                            if let d = data {
                                observer.send(value: (d, URLResponse()))
                            } else {
                                observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
                            }
                        })))
                        
                        waitUntil(action: { (done) in
                            hybridLocalFirstDataProvider.fetchStuff(resource: .posts).startWithResult({ (result) in
                                switch result {
                                case .failure:
                                    fail()
                                case .success(let values):
                                    expect(values.0.count).to(equal(100))
                                }
                                done()
                            })
                        })
                    }
                    
                    it("should succeed if nothing is returned from the persistence layer") {
                        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
                            observer.send(value: [])
                        })))
                        waitUntil(action: { (done) in
                            hybridLocalFirstDataProvider.fetchStuff(resource: .posts).startWithResult({ (result) in
                                switch result {
                                case .failure:
                                    fail()
                                case .success(let values):
                                    expect(values.0.count).to(equal(0))
                                }
                                done()
                            })
                        })
                    }
                }
            }
            
            describe("hybrid remote first data provider") {
                context("fetch stuff method") {
                    it("should get a success result on the happy path") {
                        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
                            observer.send(value: [Post(id: 0, userId: 0, title: "", body: "")])
                        })))
                        Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                            let posts: [Post] = Factory.arrayReponse(from: "posts", extension: "json")
                            var data: Data? = nil
                            
                            do {
                                let jsonData = try JSONEncoder().encode(posts)
                                data = jsonData
                            } catch { }
                            
                            if let d = data {
                                observer.send(value: (d, URLResponse()))
                            } else {
                                observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
                            }
                        })))
                        
                        waitUntil(action: { (done) in
                            hybridRemoteFirstDataProvider.fetchStuff(resource: .posts).startWithResult({ (result) in
                                switch result {
                                case .failure:
                                    fail()
                                case .success(let values):
                                    expect(values.0.count).to(equal(100))
                                }
                                done()
                            })
                        })
                    }
                    
                    it("should error if both layers returns an error and/or invalid data") {
                        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
                            observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "Error")))
                        })))
                        Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                            observer.send(value: (NSData() as Data, URLResponse()))
                        })))
                        
                        waitUntil(action: { (done) in
                            hybridRemoteFirstDataProvider.fetchStuff(resource: .posts).startWithResult({ (result) in
                                switch result {
                                case .failure:
                                    break
                                case .success:
                                    fail()
                                }
                                done()
                            })
                        })
                    }
                    
                    it("should get persisted posts even if parsing step after network fails") {
                        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
                            observer.send(value: [Post(id: 0, userId: 0, title: "", body: "")])
                        })))
                        Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                            observer.send(value: (NSData() as Data, URLResponse()))
                        })))
                        
                        waitUntil(action: { (done) in
                            hybridRemoteFirstDataProvider.fetchStuff(resource: .posts).startWithResult({ (result) in
                                switch result {
                                case .failure:
                                    fail()
                                case .success(let values):
                                    expect(values.0.count).to(equal(1))
                                }
                                done()
                            })
                        })
                    }
                    
                    it("should get network posts if theres was an error on the persistence layer") {
                        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
                            observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "Error")))
                        })))
                        Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                            let posts: [Post] = Factory.arrayReponse(from: "posts", extension: "json")
                            var data: Data? = nil
                            
                            do {
                                let jsonData = try JSONEncoder().encode(posts)
                                data = jsonData
                            } catch { }
                            
                            if let d = data {
                                observer.send(value: (d, URLResponse()))
                            } else {
                                observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
                            }
                        })))
                        
                        waitUntil(action: { (done) in
                            hybridRemoteFirstDataProvider.fetchStuff(resource: .posts).startWithResult({ (result) in
                                switch result {
                                case .failure:
                                    fail()
                                case .success(let values):
                                    expect(values.0.count).to(equal(100))
                                }
                                done()
                            })
                        })
                    }
                    
                    it("should succeed if nothing is returned from the persistence layer") {
                        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
                            observer.send(value: [])
                        })))
                        Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                            let posts: [Post] = Factory.arrayReponse(from: "posts", extension: "json")
                            var data: Data? = nil
                            
                            do {
                                let jsonData = try JSONEncoder().encode(posts)
                                data = jsonData
                            } catch { }
                            
                            if let d = data {
                                observer.send(value: (d, URLResponse()))
                            } else {
                                observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
                            }
                        })))
                        waitUntil(action: { (done) in
                            hybridRemoteFirstDataProvider.fetchStuff(resource: .posts).startWithResult({ (result) in
                                switch result {
                                case .failure:
                                    fail()
                                case .success(let values):
                                    expect(values.0.count).to(equal(100))
                                }
                                done()
                            })
                        })
                    }
                    
                    it("should succeed ignore results from the persistence layer") {
                        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
                            observer.send(value: [])
                        })))
                        Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                            let posts: [Post] = Factory.arrayReponse(from: "posts", extension: "json")
                            var data: Data? = nil
                            
                            do {
                                let jsonData = try JSONEncoder().encode(posts)
                                data = jsonData
                            } catch { }
                            
                            if let d = data {
                                observer.send(value: (d, URLResponse()))
                            } else {
                                observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
                            }
                        })))
                        waitUntil(action: { (done) in
                            hybridRemoteFirstDataProvider.fetchStuff(resource: .posts).startWithResult({ (result) in
                                switch result {
                                case .failure:
                                    fail()
                                case .success(let values):
                                    expect(values.0.count).to(equal(100))
                                }
                                done()
                            })
                        })
                    }
                }
            }
        }
    }
}
