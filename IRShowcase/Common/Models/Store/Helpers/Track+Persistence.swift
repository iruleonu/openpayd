//
//  Track+Persistence.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 01/06/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import enum Result.Result
import CoreData

extension Track: CodableToPersistence {
    var entityName: String {
        return "TrackCD"
    }
    
    var relationshipPropertyNames: [String] {
        return []
    }
    
    var dictionaryWithoutCDRelationships: [String: AnyObject] {
        return dictionaryRepresentation.filter({ !relationshipPropertyNames.contains($0.key) })
    }
    
    func dictionaryForCDRelationshipPropertyNamed(_ property: String) -> [String: AnyObject]? {
        guard let value = dictionaryRepresentation[property], let cast = value as? CodableToPersistence else {
            return [:]
        }
        return cast.dictionaryWithoutCDRelationships
    }
    
    var identifier: String {
        return "\(trackId)"
    }
    
    static var propertiesToRemoveSavingEachPropertyValueAndSetItToTargetKey: [String: String] {
        return ["trackId": "id",
                "shortDescription": "trackDescription"]
    }
    
    private var dictionaryRepresentation: [String: AnyObject] {
        var aux: [String: AnyObject] = [:]
        
        do {
            let jsonData = try JSONEncoder().encode(self)
            guard var json = try JSONSerialization.jsonObject(with: jsonData, options: [.mutableContainers]) as? [String: AnyObject] else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "jsonData to [String: AnyObject] error"])
                throw error
            }
            
            Track.propertiesToRemoveSavingEachPropertyValueAndSetItToTargetKey.forEach { (key, value) in
                defer {
                    json.removeValue(forKey: key)
                }
                guard let sourceValue = json[key], !(sourceValue is NSNull) else { return }
                json[value] = sourceValue
            }
            
            aux = json
        } catch { }
        
        return aux
    }
}

extension Track: CoreDataToCodable {
    static func mapToModel<T>(_ object: NSManagedObject) -> T? where T: Decodable, T: Encodable {
        let keys = object.entity.attributesByName.keys.compactMap({ $0 })
        let dict = object.dictionaryWithValues(forKeys: keys)
        var transformDict = dict
        Track.propertiesToRemoveSavingEachPropertyValueAndSetItToTargetKey.forEach { (key, value) in
            defer {
                transformDict.removeValue(forKey: value)
            }
            guard let sourceValue = transformDict[value], !(sourceValue is NSNull) else { return }
            transformDict[key] = sourceValue
        }
        
        var post: Track?
        do {
            let data = try JSONSerialization.data(withJSONObject: transformDict, options: .prettyPrinted)
            let postFromData = try JSONDecoder().decode(Track.self, from: data)
            post = postFromData
        } catch let e {
            print(e)
        }
        
        return post as? T
    }
    
    static func mapToModelResult<T>(_ object: NSManagedObject) -> Result<T, CoreDataToCodableError> where T: Decodable, T: Encodable {
        let keys = object.entity.attributesByName.keys.compactMap({ $0 })
        let dict = object.dictionaryWithValues(forKeys: keys)
        var post: Track?
        var parseError: CoreDataToCodableError?
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let postFromData = try JSONDecoder().decode(Track.self, from: data)
            post = postFromData
        } catch {
            parseError = CoreDataToCodableError.custom("Error parsing")
        }
        
        guard let p = post as? T else {
            return Result(error: parseError ?? CoreDataToCodableError.unkown)
        }
        
        return Result(value: p)
    }
}
