//
//  PersistenceTests.swift
//  IRShowcaseTests
//
//  Created by Nuno Salvador on 02/04/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import XCTest
import SwiftyMocky
import ReactiveSwift

@testable import IRShowcase

class PersistenceTests: XCTestCase {
    private var persistence: PersistenceLayerMock!
    private var persistenceLoadHandler: DataProviderHandlers<[Post]>.PersistenceLoadHandler!
    private var persistenceSaveHandler: DataProviderHandlers<[Post]>.PersistenceSaveHandler!
    private var persistenceRemoveHandler: DataProviderHandlers<[Post]>.PersistenceRemoveHandler!
    
    override func setUp() {
        super.setUp()
        persistence = PersistenceLayerMock()
        let dpHandlersBuilder = DataProviderHandlersBuilder<[Post]>()
        persistenceLoadHandler = dpHandlersBuilder.standardPersistenceLoadHandler
        persistenceSaveHandler = dpHandlersBuilder.standardPersistenceSaveHandler
        persistenceRemoveHandler = dpHandlersBuilder.standardPersistenceRemoveHandler
    }
    
    override func tearDown() {
        persistence = nil
        persistenceLoadHandler = nil
        persistenceSaveHandler = nil
        persistenceRemoveHandler = nil
        super.tearDown()
    }
    
    func testShouldLoadIfSuccess() {
        let expectation = self.expectation(description: "Expected load data when found resource")
        defer { self.waitForExpectations(timeout: 3.0, handler: nil) }
        
        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
            observer.send(value: [Post(id: 0, userId: 0, title: "", body: "")])
        })))
        
        persistenceLoadHandler(persistence, .unknown).startWithResult { (result) in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
    }
    
    func testFailToLoadIfError() {
        let expectation = self.expectation(description: "Expected to fail when doesnt know the resource")
        defer { self.waitForExpectations(timeout: 3.0, handler: nil) }
        
        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
            observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "No known resource")))
        })))
        
        persistenceLoadHandler(persistence, .unknown).startWithResult { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure:
                expectation.fulfill()
            }
        }
    }
    
    func testThrowErrorIfEmptyResultsForResource() {
        let expectation = self.expectation(description: "Expected to return an error if there was no results for the requested resource")
        defer { self.waitForExpectations(timeout: 3.0, handler: nil) }
        
        Given(persistence, .fetchResource(.any, willReturn: SignalProducer<[Post], PersistenceLayerError>({ (observer, _) in
            observer.send(error: PersistenceLayerError.emptyResult(error: NSError.error(withMessage: "No results")))
        })))
        
        persistenceLoadHandler(persistence, .posts).startWithResult { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure:
                expectation.fulfill()
            }
        }
    }
    
    func testSucceedIfSuccessSaving() {
        let expectation = self.expectation(description: "Expected success when saving")
        defer { self.waitForExpectations(timeout: 3.0, handler: nil) }
        
        persistence.perform(.persistObjects(Parameter<[Post]>.any, saveCompletion: .any, perform: { _, block in
            block(true, nil)
        }))
        
        persistenceSaveHandler(persistence, []).startWithResult { (result) in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
    }
    
    func testFailureIfErrorSaving() {
        let expectation = self.expectation(description: "Expected failure when there was an error saving")
        defer { self.waitForExpectations(timeout: 3.0, handler: nil) }
        
        persistence.perform(.persistObjects(Parameter<[Post]>.any, saveCompletion: .any, perform: { _, block in
            let error = PersistenceLayerError.emptyResult(error: NSError.error(withMessage: "Error"))
            block(false, error)
        }))
        
        persistenceSaveHandler(persistence, []).startWithResult { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure:
                expectation.fulfill()
            }
        }
    }
    
    func testSucceedIfSuccessRemoving() {
        let expectation = self.expectation(description: "Expected success when resource was sucessfuly removed")
        defer { self.waitForExpectations(timeout: 3.0, handler: nil) }
        
        Given(persistence, .removeResource(.any, willReturn: SignalProducer<Bool, PersistenceLayerError>({ (observer, _) in
            observer.send(value: true)
        })))
        
        persistenceRemoveHandler(persistence, .posts).startWithResult { (result) in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
    }
    
    func testErrorIfFailureRemoving() {
        let expectation = self.expectation(description: "Expected error when failure removing")
        defer { self.waitForExpectations(timeout: 3.0, handler: nil) }
        
        Given(persistence, .removeResource(.any, willReturn: SignalProducer<Bool, PersistenceLayerError>({ (observer, _) in
            observer.send(error: PersistenceLayerError.emptyResult(error: NSError.error(withMessage: "No results")))
        })))
        
        persistenceRemoveHandler(persistence, .posts).startWithResult { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure:
                expectation.fulfill()
            }
        }
    }
}
