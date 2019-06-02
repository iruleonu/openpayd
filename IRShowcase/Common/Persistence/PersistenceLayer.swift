//
//  PersistenceLayer.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 21/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import ReactiveSwift
import IRCoreDataStack

typealias PersistenceSaveCompletion = (Bool, Error?) -> Void

protocol PersistenceLayerLoad {
    func fetchResource<T>(_ resource: Resource) -> SignalProducer<T, PersistenceLayerError>
}

protocol PersistenceLayerSave {
    func persistObjects<T>(_ objects: T, saveCompletion: @escaping PersistenceSaveCompletion)
}

protocol PersistenceLayerRemove {
    func removeResource(_ resource: Resource) -> SignalProducer<Bool, PersistenceLayerError>
}

//sourcery: AutoMockable
protocol PersistenceLayer: PersistenceLayerLoad, PersistenceLayerSave, PersistenceLayerRemove, EntityFetchAudiobooksProtocol, EntityFetchTracksProtocol {
    
}

class PersistenceLayerImpl {
    static let `default` = PersistenceLayerBuilder.make()
    
    let coreDataStack: IRCDStack
    
    init(coreDataStack: IRCDStack) {
        self.coreDataStack = coreDataStack
    }
}

extension PersistenceLayerImpl: PersistenceLayerLoad {
    func fetchResource<T>(_ resource: Resource) -> SignalProducer<T, PersistenceLayerError> {
        switch resource {
        case .audiobook(let id):
            guard let aId = Int64(id) else { return SignalProducer.empty }
            return fetchAudiobook(id: aId) as? SignalProducer<T, PersistenceLayerError> ?? SignalProducer.empty
        case .track(let id):
            guard let tId = Int64(id) else { return SignalProducer.empty }
            return fetchTrack(id: tId) as? SignalProducer<T, PersistenceLayerError> ?? SignalProducer.empty
        case .posts:
            return fetchAllPosts() as? SignalProducer<T, PersistenceLayerError> ?? SignalProducer.empty
        case .post(let postId):
            guard let pId = Int64(postId) else { return SignalProducer.empty }
            return fetchPost(postId: pId) as? SignalProducer<T, PersistenceLayerError> ?? SignalProducer.empty
        default:
            return SignalProducer<T, PersistenceLayerError> { observer, _ in
                observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "No known resource")))
            }
        }
    }
}

extension PersistenceLayerImpl: PersistenceLayerRemove {
    func removeResource(_ resource: Resource) -> SignalProducer<Bool, PersistenceLayerError> {
        switch resource {
        case .audiobook(let id):
            return deleteEntity(entityName: "AudiobookCD", entityIdenfitier: id)
        case .track(let id):
            return deleteEntity(entityName: "TrackCD", entityIdenfitier: id)
        case .posts:
            return deleteAllEntities(entityName: "PostCD")
        case .post(let postId):
            return deleteEntity(entityName: "PostCD", entityIdenfitier: postId)
        default:
            return SignalProducer<Bool, PersistenceLayerError> { observer, _ in
                observer.send(error: PersistenceLayerError.persistence(error: NSError.error(withMessage: "Unknown resource")))
            }
        }
    }
    
    private func deleteAllEntities(entityName: String) -> SignalProducer<Bool, PersistenceLayerError> {
        let bmoc = coreDataStack.backgroundManagedObjectContext!
        let cdt = coreDataStack
        return SignalProducer<Bool, PersistenceLayerError> { observer, _ in
            cdt.deleteAll(fromEntity: entityName, in: bmoc)
            cdt.save(into: bmoc) { (removed, error) in
                if let e = error {
                    observer.send(error: PersistenceLayerError.persistence(error: e))
                    return
                }
                
                observer.send(value: removed)
            }
        }
    }
    
    private func deleteEntity(entityName: String, entityIdenfitier: String) -> SignalProducer<Bool, PersistenceLayerError> {
        let predicate = NSPredicate(format: "id == %@", entityIdenfitier)
        let bmoc = coreDataStack.backgroundManagedObjectContext!
        let cdt = coreDataStack
        let findEntity = checkIfObjectExits(entityName: entityName, predicate: predicate, context: bmoc)
        return SignalProducer<Bool, PersistenceLayerError> { observer, _ in
            guard findEntity != nil else {
                observer.send(value: true)
                return
            }
            
            cdt.deleteEntity(findEntity)
            cdt.save(into: bmoc) { (removed, error) in
                if let e = error {
                    observer.send(error: PersistenceLayerError.persistence(error: e))
                    return
                }
                
                observer.send(value: removed)
            }
        }
    }
}

extension PersistenceLayerImpl: PersistenceLayerSave {
    func persistObjects<T>(_ objects: T, saveCompletion: @escaping PersistenceSaveCompletion) {
        switch objects {
        case let t as CodableToPersistence:
            persistCodables([t], saveCompletion: saveCompletion)
        case let t as [CodableToPersistence]:
            persistCodables(t, saveCompletion: saveCompletion)
        case let t as NestedCodableToPersistence:
            persistCodables(t.codablesToPersistence, saveCompletion: saveCompletion)
        default:
            saveCompletion(false, nil)
        }
    }
    
    private func persistCodables(_ objects: [CodableToPersistence], saveCompletion: @escaping PersistenceSaveCompletion) {
        let bmoc = coreDataStack.backgroundManagedObjectContext!
        objects.forEach { (c) in
            let dict = c.dictionaryWithoutCDRelationships
            let predicate = NSPredicate(format: "id == %@", c.identifier)
            
            if let mo: NSManagedObject = checkIfObjectExits(entityName: c.entityName, predicate: predicate, context: bmoc) {
                let attributes = dict.keys.compactMap({ $0 })
                attributes.forEach({ (key) in
                    guard let value = dict[key] else { return }
                    bmoc.performAndWait({
                        mo.setValue(value, forKey: key)
                    })
                })
            } else {
                coreDataStack.createEntity(withClassName: c.entityName, attributesDictionary: dict, in: bmoc)
            }
        }
        
        coreDataStack.save(into: bmoc) { (saved, error) in
            saveCompletion(saved, error)
        }
    }
    
    private func checkIfObjectExits(entityName: String, predicate: NSPredicate, context: NSManagedObjectContext) -> NSManagedObject? {
        var aux: NSManagedObject?
        
        coreDataStack.fetchEntries(forClassName: entityName, with: predicate, sortDescriptors: [], managedObjectContext: context, asynchronous: false, completionBlock: { (results) in
            aux = results?.first as? NSManagedObject
        })
        
        return aux
    }
}

extension PersistenceLayerImpl: AppService {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
