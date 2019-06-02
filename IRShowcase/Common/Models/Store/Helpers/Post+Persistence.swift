//
//  Post+CoreDataToCodable.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 23/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import enum Result.Result
import CoreData

extension Post: CodableToPersistence {
    var entityName: String {
        return "PostCD"
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
        return "\(id)"
    }
    
    var propertiesToRemoveSavingEachPropertyValueAndSetItToTargetKey: [String: String] {
        return [:]
    }
    
    private var dictionaryRepresentation: [String: AnyObject] {
        var aux: [String: AnyObject] = [:]
        
        do {
            let jsonData = try JSONEncoder().encode(self)
            guard let json = try JSONSerialization.jsonObject(with: jsonData, options: [.mutableContainers]) as? [String: AnyObject] else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "jsonData to [String: AnyObject] error"])
                throw error
            }
            aux = json
        } catch { }
        
        return aux
    }
}

extension Post: CoreDataToCodable {
    static func mapToModel<T>(_ object: NSManagedObject) -> T? where T: Decodable, T: Encodable {
        let keys = object.entity.attributesByName.keys.compactMap({ $0 })
        let dict = object.dictionaryWithValues(forKeys: keys)
        var post: Post?
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let postFromData = try JSONDecoder().decode(Post.self, from: data)
            post = postFromData
        } catch { }
        
        return post as? T
    }
    
    static func mapToModelResult<T>(_ object: NSManagedObject) -> Result<T, CoreDataToCodableError> where T: Decodable, T: Encodable {
        let keys = object.entity.attributesByName.keys.compactMap({ $0 })
        let dict = object.dictionaryWithValues(forKeys: keys)
        var post: Post?
        var parseError: CoreDataToCodableError?
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let postFromData = try JSONDecoder().decode(Post.self, from: data)
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
