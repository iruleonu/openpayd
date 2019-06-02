//
//  User+Persistence.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 24/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import enum Result.Result
import CoreData

extension User: CodableToPersistence {
    var entityName: String {
        return "UserCD"
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
    
    static var propertiesToRemoveSavingEachPropertyValueAndSetItToTargetKey: [String: String] {
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

extension User: CoreDataToCodable {
    static func mapToModel<T>(_ object: NSManagedObject) -> T? where T: Decodable, T: Encodable {
        let keys = object.entity.attributesByName.keys.compactMap({ $0 })
        let dict = object.dictionaryWithValues(forKeys: keys)
        var model: User?
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let modelFromData = try JSONDecoder().decode(User.self, from: data)
            model = modelFromData
        } catch { }
        
        return model as? T
    }
    
    static func mapToModelResult<T>(_ object: NSManagedObject) -> Result<T, CoreDataToCodableError> where T: Decodable, T: Encodable {
        let keys = object.entity.attributesByName.keys.compactMap({ $0 })
        let dict = object.dictionaryWithValues(forKeys: keys)
        var model: User?
        var parseError: CoreDataToCodableError?
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let modelFromData = try JSONDecoder().decode(User.self, from: data)
            model = modelFromData
        } catch {
            parseError = CoreDataToCodableError.custom("Error parsing")
        }
        
        guard let m = model as? T else {
            return Result(error: parseError ?? CoreDataToCodableError.unkown)
        }
        
        return Result(value: m)
    }
}
