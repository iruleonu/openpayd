//
//  PostDetailsViewModelTests.swift
//  IRShowcaseTests
//
//  Created by Nuno Salvador on 03/04/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SwiftyMocky
import ReactiveSwift
import enum Result.NoError

@testable import IRShowcase

//class PostDetailsViewModelTests: QuickSpec {
//    override func spec() {
//        describe("PostDetailsViewModelTests") {
//            var subject: ITunesItemDetailsViewModelImpl!
//            var routing: PostDetailsRoutingMock!
//            var network: APIServiceMock!
//            var persistence: PersistenceLayerMock!
//            var connectivity: ConnectivityServiceMock!
//            var postId: Int!
//            
//            beforeEach {
//                routing = PostDetailsRoutingMock()
//                network = APIServiceMock()
//                persistence = PersistenceLayerMock()
//                connectivity = ConnectivityServiceMock()
//                postId = 1
//                let config = DataProviderConfiguration.standard
//                let userHandlersFactory: DataProviderHandlersBuilder<[User]> = DataProviderHandlersBuilder()
//                let userHandlers: DataProviderHandlers<[User]> = userHandlersFactory.makeDataProviderHandlers(config: config)
//                let userDataProvider = DataProvider<[User]>(config: config, network: network, persistence: persistence, handlers: userHandlers)
//                let postHandlersFactory: DataProviderHandlersBuilder<[Post]> = DataProviderHandlersBuilder()
//                let postHandlers: DataProviderHandlers<[Post]> = postHandlersFactory.makeDataProviderHandlers(config: config)
//                let postDataProvider = DataProvider<[Post]>(config: config, network: network, persistence: persistence, handlers: postHandlers)
//                let commentsHandlersFactory: DataProviderHandlersBuilder<[Comment]> = DataProviderHandlersBuilder()
//                let commentsHandlers: DataProviderHandlers<[Comment]> = commentsHandlersFactory.makeDataProviderHandlers(config: config)
//                let commentsDataProvider = DataProvider<[Comment]>(config: config, network: network, persistence: persistence, handlers: commentsHandlers)
//                subject = ITunesItemDetailsViewModelImpl(routing: routing, postId: postId, userDataProvider: userDataProvider, postDataProvider: postDataProvider, commentsDataProvider: commentsDataProvider, connectivity: connectivity)
//            }
//            
//            afterEach {
//                subject = nil
//            }
//            
//            context("viewDidLoad") {
//                it("should get local post after calling viewDidLoad (does a local fetch) on the happy path") {
//                    Given(connectivity, .isReachableProperty(getter: MutableProperty<Bool>(true)))
//                    Given(connectivity, .performSingleConnectivityCheck(willReturn: SignalProducer<ConnectivityServiceStatus, NoError>({ (observer, _) in
//                        observer.send(value: ConnectivityServiceStatus.connected)
//                    })))
//                    Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.post(id: "\(postId!)")), willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
//                        observer.send(value: [Post(id: postId!, userId: 1, title: "", body: "")])
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.comments(postId: "\(postId!)")), willReturn: SignalProducer<[Comment], PersistenceLayerError>({ (observer, _) in
//                        observer.send(value: [Comment(postId: postId!, email: "email")])
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.user(id: "1")), willReturn: SignalProducer<[User], PersistenceLayerError>({ (observer, _) in
//                        observer.send(value: [User(id: 1, email: "email", name: "name", username: "username")])
//                    })))
//
//                    waitUntil(action: { (done) in
//                        subject.fetchedStuff.observeValues({ (result) in
//                            switch result {
//                            case .success(let value):
//                                expect(value.0).toNot(beNil())
//                            case .failure:
//                                fail()
//                            }
//
//                            // Verify that we didnt call the method that saves to persistence
//                            persistence.verify(PersistenceLayerMock.Verify.persistObjects(Parameter<[Post]>.any, saveCompletion: .any), count: 0)
//
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//                                expect(subject.fetchPostAction.isExecuting.value).to(equal(false))
//                                done()
//                            }
//                        })
//                        subject.viewDidLoad()
//                    })
//                }
//                
//                it("should return error after calling viewDidLoad if theres no data") {
//                    Given(connectivity, .isReachableProperty(getter: MutableProperty<Bool>(true)))
//                    Given(connectivity, .performSingleConnectivityCheck(willReturn: SignalProducer<ConnectivityServiceStatus, NoError>({ (observer, _) in
//                        observer.send(value: ConnectivityServiceStatus.connected)
//                    })))
//                    Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.post(id: "\(postId!)")), willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
//                        observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "Error")))
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.comments(postId: "\(postId!)")), willReturn: SignalProducer<[Comment], PersistenceLayerError>({ (observer, _) in
//                        observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "Error")))
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.user(id: "1")), willReturn: SignalProducer<[User], PersistenceLayerError>({ (observer, _) in
//                        observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "Error")))
//                    })))
//                    Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
//                        observer.send(error: DataProviderError.parsing(error: DataProviderError.requestError(error: NSError.error(withMessage: "Did load returns local data"))))
//                    })))
//                    
//                    waitUntil(action: { (done) in
//                        subject.fetchedStuff.observeValues({ (result) in
//                            switch result {
//                            case .success:
//                                fail()
//                            case .failure:
//                                break
//                            }
//                            
//                            // Verify that we didnt call the method that saves to persistence
//                            persistence.verify(PersistenceLayerMock.Verify.persistObjects(Parameter<[Post]>.any, saveCompletion: .any), count: 0)
//                            
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//                                expect(subject.fetchPostAction.isExecuting.value).to(equal(false))
//                                done()
//                            }
//                        })
//                        subject.viewDidLoad()
//                    })
//                }
//            }
//            
//            context("viewDidAppear") {
//                it("should get remote post after calling viewDidAppear (does a config fetch) on the happy path") {
//                    Given(connectivity, .isReachableProperty(getter: MutableProperty<Bool>(true)))
//                    Given(connectivity, .performSingleConnectivityCheck(willReturn: SignalProducer<ConnectivityServiceStatus, NoError>({ (observer, _) in
//                        observer.send(value: ConnectivityServiceStatus.connected)
//                    })))
//                    Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.post(id: "\(postId!)")), willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
//                        observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "Error")))
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.comments(postId: "\(postId!)")), willReturn: SignalProducer<[Comment], PersistenceLayerError>({ (observer, _) in
//                        observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "Error")))
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.user(id: "1")), willReturn: SignalProducer<[User], PersistenceLayerError>({ (observer, _) in
//                        observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "Error")))
//                    })))
//                    Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
//                        let posts: [Post] = Factory.arrayReponse(from: "posts", extension: "json")
//                        var data: Data? = nil
//                        
//                        do {
//                            let jsonData = try JSONEncoder().encode(posts)
//                            data = jsonData
//                        } catch { }
//                        
//                        if let d = data {
//                            observer.send(value: (d, URLResponse()))
//                        } else {
//                            observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
//                        }
//                    })))
//                    
//                    waitUntil(timeout: 50, action: { (done) in
//                        subject.fetchedStuff.observeValues({ (result) in
//                            switch result {
//                            case .success(let value):
//                                expect(value.0).toNot(beNil())
//                            case .failure:
//                                fail()
//                            }
//                            
//                            // Verify that we did call the method that saves to persistence
//                            persistence.verify(PersistenceLayerMock.Verify.persistObjects(Parameter<[Post]>.any, saveCompletion: .any))
//                            
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//                                expect(subject.fetchPostAction.isExecuting.value).to(equal(false))
//                                done()
//                            }
//                        })
//                        subject.viewDidAppear()
//                    })
//                }
//                
//                it("should get local post after calling viewDidAppear (does a config fetch) when the network fails") {
//                    Given(connectivity, .isReachableProperty(getter: MutableProperty<Bool>(true)))
//                    Given(connectivity, .performSingleConnectivityCheck(willReturn: SignalProducer<ConnectivityServiceStatus, NoError>({ (observer, _) in
//                        observer.send(value: ConnectivityServiceStatus.connected)
//                    })))
//                    Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.post(id: "\(postId!)")), willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
//                        observer.send(value: [Post(id: postId!, userId: 1, title: "", body: "")])
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.comments(postId: "\(postId!)")), willReturn: SignalProducer<[Comment], PersistenceLayerError>({ (observer, _) in
//                        observer.send(value: [Comment(postId: postId!, email: "email")])
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.user(id: "1")), willReturn: SignalProducer<[User], PersistenceLayerError>({ (observer, _) in
//                        observer.send(value: [User(id: 1, email: "email", name: "name", username: "username")])
//                    })))
//                    Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
//                        observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
//                    })))
//                    
//                    waitUntil(action: { (done) in
//                        subject.fetchedStuff.observeValues({ (result) in
//                            switch result {
//                            case .success(let value):
//                                expect(value.0).toNot(beNil())
//                            case .failure:
//                                fail()
//                            }
//                            
//                            // Verify that we didnt call the method that saves to persistence
//                            persistence.verify(PersistenceLayerMock.Verify.persistObjects(Parameter<[Post]>.any, saveCompletion: .any), count: 0)
//
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//                                expect(subject.fetchPostAction.isExecuting.value).to(equal(false))
//                                done()
//                            }
//                        })
//                        subject.viewDidAppear()
//                    })
//                }
//            }
//            
//            context("pulled down to refresh") {
//                it("should call fetched stuff on the happy path") {
//                    Given(connectivity, .isReachableProperty(getter: MutableProperty<Bool>(true)))
//                    Given(connectivity, .performSingleConnectivityCheck(willReturn: SignalProducer<ConnectivityServiceStatus, NoError>({ (observer, _) in
//                        observer.send(value: ConnectivityServiceStatus.connected)
//                    })))
//                    Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.post(id: "\(postId!)")), willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
//                        observer.send(value: [Post(id: postId!, userId: 1, title: "", body: "")])
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.comments(postId: "\(postId!)")), willReturn: SignalProducer<[Comment], PersistenceLayerError>({ (observer, _) in
//                        observer.send(value: [Comment(postId: postId!, email: "email")])
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.user(id: "1")), willReturn: SignalProducer<[User], PersistenceLayerError>({ (observer, _) in
//                        observer.send(value: [User(id: 1, email: "email", name: "name", username: "username")])
//                    })))
//                    Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
//                        let posts: [Post] = [Post(id: postId!, userId: 1, title: "", body: "")]
//                        var data: Data? = nil
//                        
//                        do {
//                            let jsonData = try JSONEncoder().encode(posts)
//                            data = jsonData
//                        } catch { }
//                        
//                        if let d = data {
//                            observer.send(value: (d, URLResponse()))
//                        } else {
//                            observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
//                        }
//                    })))
//                    
//                    waitUntil(action: { (done) in
//                        subject.fetchedStuff.observeValues({ (result) in
//                            done()
//                        })
//                        subject.triggerRefreshControl()
//                    })
//                }
//                
//                it("should call fetched stuff with results when theres no connectivity") {
//                    Given(connectivity, .isReachableProperty(getter: MutableProperty<Bool>(false)))
//                    Given(connectivity, .performSingleConnectivityCheck(willReturn: SignalProducer<ConnectivityServiceStatus, NoError>({ (observer, _) in
//                        observer.send(value: ConnectivityServiceStatus.notConnected)
//                    })))
//                    Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.post(id: "\(postId!)")), willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
//                        observer.send(value: [Post(id: postId!, userId: 1, title: "", body: "")])
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.comments(postId: "\(postId!)")), willReturn: SignalProducer<[Comment], PersistenceLayerError>({ (observer, _) in
//                        observer.send(value: [Comment(postId: postId!, email: "email")])
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.user(id: "1")), willReturn: SignalProducer<[User], PersistenceLayerError>({ (observer, _) in
//                        observer.send(value: [User(id: 1, email: "email", name: "name", username: "username")])
//                    })))
//                    Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
//                        observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
//                    })))
//                    
//                    waitUntil(action: { (done) in
//                        subject.fetchedStuff.observeValues({ (result) in
//                            done()
//                        })
//                        subject.triggerRefreshControl()
//                    })
//                }
//                
//                it("should still call fetched stuff when theres an error on the network") {
//                    Given(connectivity, .isReachableProperty(getter: MutableProperty<Bool>(false)))
//                    Given(connectivity, .performSingleConnectivityCheck(willReturn: SignalProducer<ConnectivityServiceStatus, NoError>({ (observer, _) in
//                        observer.send(value: ConnectivityServiceStatus.connected)
//                    })))
//                    Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.post(id: "\(postId!)")), willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
//                        observer.send(value: [Post(id: postId!, userId: 1, title: "", body: "")])
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.comments(postId: "\(postId!)")), willReturn: SignalProducer<[Comment], PersistenceLayerError>({ (observer, _) in
//                        observer.send(value: [Comment(postId: postId!, email: "email")])
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.user(id: "1")), willReturn: SignalProducer<[User], PersistenceLayerError>({ (observer, _) in
//                        observer.send(value: [User(id: 1, email: "email", name: "name", username: "username")])
//                    })))
//                    Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
//                        observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
//                    })))
//                    
//                    waitUntil(action: { (done) in
//                        subject.fetchedStuff.observeValues({ (result) in
//                            done()
//                        })
//                        subject.triggerRefreshControl()
//                    })
//                }
//                
//                it("should still call fetched stuff when theres an error on both layers") {
//                    Given(connectivity, .isReachableProperty(getter: MutableProperty<Bool>(false)))
//                    Given(connectivity, .performSingleConnectivityCheck(willReturn: SignalProducer<ConnectivityServiceStatus, NoError>({ (observer, _) in
//                        observer.send(value: ConnectivityServiceStatus.connected)
//                    })))
//                    Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.post(id: "\(postId!)")), willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
//                        observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "Error")))
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.comments(postId: "\(postId!)")), willReturn: SignalProducer<[Comment], PersistenceLayerError>({ (observer, _) in
//                        observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "Error")))
//                    })))
//                    Given(persistence, .fetchResource(Parameter<Resource>.value(.user(id: "1")), willReturn: SignalProducer<[User], PersistenceLayerError>({ (observer, _) in
//                        observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "Error")))
//                    })))
//                    Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
//                        observer.send(error: DataProviderError.parsing(error: DataProviderError.unknown))
//                    })))
//                    
//                    waitUntil(action: { (done) in
//                        subject.fetchedStuff.observeValues({ (result) in
//                            done()
//                        })
//                        subject.triggerRefreshControl()
//                    })
//                }
//            }
//        }
//    }
//}
