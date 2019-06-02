//
//  NetworkTests.swift
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

class NetworkTests: XCTestCase {
    private var network: APIServiceMock!
    private var networkHandler: DataProviderHandlers<[Post]>.NetworkHandler!
    
    override func setUp() {
        super.setUp()
        network = APIServiceMock()
        let dpHandlersBuilder = DataProviderHandlersBuilder<[Post]>()
        networkHandler = dpHandlersBuilder.standardNetworkHandler
    }
    
    override func tearDown() {
        network = nil
        networkHandler = nil
        super.tearDown()
    }
    
    func testSuccessfulRequest() {
        let expectation = self.expectation(description: "Expected request to return data")
        defer { self.waitForExpectations(timeout: 3.0, handler: nil) }
        
        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
        Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
            observer.send(value: (NSData() as Data, URLResponse()))
        })))
        
        networkHandler(network, network.buildUrlRequest(resource: .unknown)).startWithResult { (result) in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
    }
    
    func testFailedRequest() {
        let expectation = self.expectation(description: "Expected request to fail")
        defer { self.waitForExpectations(timeout: 3.0, handler: nil) }
        
        Given(network, .buildUrlRequest(resource: .any, willReturn: Resource.posts.buildUrlRequest(apiBaseUrl: URL(string: "https://fake.com")!)))
        Given(network, .fetchData(request: .any, willReturn: SignalProducer({ (observer, _) in
            observer.send(error: DataProviderError.requestError(error: DataProviderError.unknown))
        })))
        
        networkHandler(network, network.buildUrlRequest(resource: .unknown)).startWithResult { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure:
                expectation.fulfill()
            }
        }
    }
}
