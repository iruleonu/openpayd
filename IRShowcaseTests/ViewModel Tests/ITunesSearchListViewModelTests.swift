//
//  PostsListViewModelTests.swift
//  IRShowcaseTests
//
//  Created by Nuno Salvador on 02/04/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SwiftyMocky
import ReactiveSwift
import enum Result.Result
import enum Result.NoError

@testable import IRShowcase

class ITunesSearchListViewModelTests: QuickSpec {
    override func spec() {
        describe("ITunesSearchListViewModelTests") {
            var subject: ITunesSearchListViewModelImpl!
            var routing: PostsListRoutingMock!
            var network: APIServiceMock!
            var persistence: PersistenceLayerMock!
            var connectivity: ConnectivityServiceMock!
            
            beforeEach {
                routing = PostsListRoutingMock()
                network = APIServiceMock()
                persistence = PersistenceLayerMock()
                connectivity = ConnectivityServiceMock()
                let localConfig = DataProviderConfiguration.localOnly
                let remoteConfig = DataProviderConfiguration.remoteOnly
                let localDataProvider: DataProvider<SearchItemResponse> = DataProviderBuilder.makeDataProvider(config: localConfig, network: network, persistence: persistence)
                let remoteDataProvider: DataProvider<SearchItemResponse> = DataProviderBuilder.makeDataProvider(config: remoteConfig, network: network, persistence: persistence)
                Given(connectivity, .isReachableProperty(getter: MutableProperty<Bool>(true)))
                subject = ITunesSearchListViewModelImpl(routing: routing, localDataProvider: localDataProvider, remoteDataProvider: remoteDataProvider, connectivity: connectivity)
            }
            
            afterEach {
                subject = nil
            }
            
            context("fetch stuff dance") {
                it("should get items after calling fetchStuff on the happy path") {
                    Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.items(query: "test", limit: 50).buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                    Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                        let posts: SearchItemResponse = Factory.arrayReponse(from: "items", extension: "json")
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
                    Given(persistence, .fetchResource(.any, willReturn: SignalProducer<SearchItemResponse, PersistenceLayerError>({ (observer, _) in
                        observer.send(value: SearchItemResponse())
                    })))
                    waitUntil(action: { (done) in
                        subject.fetchedStuff.observeValues({ (result) in
                            switch result {
                            case .success(let value):
                                expect(value.count) == 50
                            case .failure:
                                fail()
                            }
                            
                            // Verify that we called the method that saves to persistence
                            persistence.verify(PersistenceLayerMock.Verify.persistObjects(Parameter<SearchItemResponse>.any, saveCompletion: .any))
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                // Verify that the fetchStuffAction isnt executing
                                expect(subject.fetchStuffAction.isExecuting.value).to(equal(false))
                                done()
                            }
                        })
                        subject.fetchStuff()
                    })
                }
                
                it("should get posts after calling fetchStuff with an error from empty persistence") {
                    Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.items(query: "test", limit: 50).buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                    Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                        let posts: SearchItemResponse = Factory.arrayReponse(from: "items", extension: "json")
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
                    Given(persistence, .fetchResource(.any, willReturn: SignalProducer<SearchItemResponse, PersistenceLayerError>({ (observer, _) in
                        observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "should get a signal after calling fetchStuff Error")))
                    })))

                    waitUntil(action: { (done) in
                        subject.fetchedStuff.observeValues({ (result) in
                            switch result {
                            case .success(let value):
                                expect(value.count) == 50
                            case .failure:
                                fail()
                            }

                            // Verify that we called the method that saves to persistence
                            persistence.verify(PersistenceLayerMock.Verify.persistObjects(Parameter<SearchItemResponse>.any, saveCompletion: .any))

                            // Verify that the fetchStuffAction isnt executing
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                expect(subject.fetchStuffAction.isExecuting.value).to(equal(false))
                                done()
                            }
                        })
                        subject.fetchStuff()
                    })
                }

                it("should get posts after calling fetchStuff with an error from the network") {
                    Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.items(query: "test", limit: 50).buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                    Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                        observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
                    })))
                    Given(persistence, .fetchResource(.any, willReturn: SignalProducer<SearchItemResponse, PersistenceLayerError>({ (observer, _) in
                        let jsonFile: SearchItemResponse = Factory.arrayReponse(from: "items", extension: "json")
                        let response = SearchItemResponse(resultCount: jsonFile.resultCount, results: jsonFile.results)
                        observer.send(value: response)
                    })))
                    
                    waitUntil(action: { (done) in
                        subject.fetchedStuff.observeValues({ (result) in
                            switch result {
                            case .success(let value):
                                expect(value.count) == 50
                            case .failure:
                                fail()
                            }

                            // Verify that we DIDNT called the method that saves to persistence
                            persistence.verify(PersistenceLayerMock.Verify.persistObjects(Parameter<SearchItemResponse>.any, saveCompletion: .any), count: 0)

                            // Verify that the fetchStuffAction isnt executing
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                expect(subject.fetchStuffAction.isExecuting.value).to(equal(false))
                                done()
                            }
                        })
                        subject.fetchStuff()
                    })
                }

                it("should get a signal (failure) after calling fetchStuff with an error on both the persistence and network layer") {
                    Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.items(query: "test", limit: 50).buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                    Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                        observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
                    })))
                    Given(persistence, .fetchResource(.any, willReturn: SignalProducer<SearchItemResponse, PersistenceLayerError>({ (observer, _) in
                        observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "should get a signal after calling fetchStuff Error")))
                    })))

                    waitUntil(action: { (done) in
                        subject.fetchedStuff.observeValues({ (result) in
                            switch result {
                            case .success:
                                fail()
                            case .failure:
                                break
                            }

                            // Verify that we DIDNT called the method that saves to persistence
                            persistence.verify(PersistenceLayerMock.Verify.persistObjects(Parameter<SearchItemResponse>.any, saveCompletion: .any), count: 0)

                            // Verify that the fetchStuffAction isnt executing
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                expect(subject.fetchStuffAction.isExecuting.value).to(equal(false))
                                done()
                            }
                        })
                        subject.fetchStuff()
                    })
                }
            }
            
            context("pulled down to refresh") {
                it("should call fetch stuff") {
                    Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.items(query: "test", limit: 50).buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
                    Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
                        observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
                    })))
                    Given(persistence, .fetchResource(.any, willReturn: SignalProducer<SearchItemResponse, PersistenceLayerError>({ (observer, _) in
                        observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "should get a signal after calling fetchStuff Error")))
                    })))
                    waitUntil(action: { (done) in
                        subject.fetchedStuff.observeValues({ (result) in
                            done()
                        })
                        subject.triggerRefreshControl()
                    })
                }
            }
            
            context("tapped on a post") {
                it("should open next screen") {
                    waitUntil(action: { (done) in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            routing.verify(PostsListRoutingMock.Verify.showTrack(id: .value(1), action: .any))
                            done()
                        }
                        subject.userDidTapTrackCellWithTrackId(1)
                    })
                }
            }
        }
    }
}
