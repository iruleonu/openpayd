//
//  Factory.swift
//  IRShowcaseTests
//
//  Created by Nuno Salvador on 02/04/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation

class Factory {
    static func object<T: Codable>(from filename: String, extension type: String) -> T {
        do {
            let bundle = Bundle(for: self)
            guard let url = bundle.url(forResource: filename, withExtension: type) else { fatalError() }
            let data = try Data(contentsOf: url)
            let jsonDecoder = JSONDecoder.IRJSONDecoder()
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            fatalError()
        }
    }
    
    static func arrayReponse<T: Codable>(from filename: String, extension type: String) -> T {
        do {
            let bundle = Bundle(for: self)
            guard let url = bundle.url(forResource: filename, withExtension: type) else { fatalError() }
            let data = try Data(contentsOf: url)
            let jsonDecoder = JSONDecoder.IRJSONDecoder()
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            fatalError()
        }
    }
    
    static func dataReponse(from filename: String, extension type: String) -> Data {
        do {
            let bundle = Bundle(for: self)
            guard let url = bundle.url(forResource: filename, withExtension: type) else { fatalError() }
            let data = try Data(contentsOf: url)
            return data
        } catch {
            fatalError()
        }
    }
}
