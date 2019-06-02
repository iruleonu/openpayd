//
//  NetworkParserTests.swift
//  IRShowcaseTests
//
//  Created by Nuno Salvador on 02/04/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import XCTest
import ReactiveSwift

@testable import IRShowcase

class NetworkParserTests: XCTestCase {
    
    func testPostsDecodingEncoding() {
        let expectation = self.expectation(description: "Expected to decode/encode properly")
        defer { self.waitForExpectations(timeout: 3.0, handler: nil) }
        
        let posts: [Post] = Factory.arrayReponse(from: "posts", extension: "json")
        XCTAssertTrue(posts.count == 100)
        var data: Data? = nil
        
        do {
            let jsonData = try JSONEncoder().encode(posts)
            data = jsonData
        } catch { }
        
        XCTAssertNotNil(data)
        
        let dpHandlersBuilder = DataProviderHandlersBuilder<[Post]>()
        let networkParser = dpHandlersBuilder.standardNetworkParserHandler
        
        networkParser(data!).startWithResult { (result) in
            switch result {
            case .success(let value):
                XCTAssertTrue(value.count == posts.count)
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
    }
    
    func testFailsWhenParsingWeirdData() {
        let expectation = self.expectation(description: "Expected to fail when encontering unknown data")
        defer { self.waitForExpectations(timeout: 3.0, handler: nil) }
        
        let data: Data? = NSData() as Data
        let dpHandlersBuilder = DataProviderHandlersBuilder<[Post]>()
        let networkParser = dpHandlersBuilder.standardNetworkParserHandler
        
        networkParser(data!).startWithResult { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertTrue(error.errorDescription == DataProviderError.parsing(error: DataProviderError.unknown).errorDescription)
                expectation.fulfill()
            }
        }
    }
}
