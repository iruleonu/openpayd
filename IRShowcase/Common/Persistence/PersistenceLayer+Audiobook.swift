//
//  PersistenceLayer+Audiobook.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 01/06/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import CoreData
import ReactiveSwift

protocol EntityFetchAudiobooksProtocol {
    func fetchAudiobook(id: Int64) -> SignalProducer<[AudioBook], PersistenceLayerError>
    func fetchAudiobooks(ids: [Int64]) -> SignalProducer<[AudioBook], PersistenceLayerError>
}

extension PersistenceLayerImpl: EntityFetchAudiobooksProtocol {
    func fetchAudiobook(id: Int64) -> SignalProducer<[AudioBook], PersistenceLayerError> {
        let context = coreDataStack.managedObjectContext!
        
        return SignalProducer<[AudioBook], PersistenceLayerError> { observer, _ in
            var results: [AudioBook] = []
            
            do {
                let fetchRequest: NSFetchRequest<AudioBookCD> = AudioBookCD.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %lld", Int64(id))
                let aux = try context.fetch(fetchRequest) as [AudioBookCD]
                aux.forEach({ (cd) in
                    guard let audioBook: AudioBook = AudioBook.mapToModel(cd) else { return }
                    results.append(audioBook)
                })
            } catch {}
            
            guard results.count > 0 else {
                let error = NSError.error(withMessage: "No results for audiobook with id: \(id)")
                observer.send(error: PersistenceLayerError.emptyResult(error: error))
                return
            }
            
            observer.send(value: results)
        }
    }
    
    func fetchAudiobooks(ids: [Int64]) -> SignalProducer<[AudioBook], PersistenceLayerError> {
        let context = coreDataStack.managedObjectContext!
        
        return SignalProducer<[AudioBook], PersistenceLayerError> { observer, _ in
            var results: [AudioBook] = []
            
            do {
                let fetchRequest: NSFetchRequest<AudioBookCD> = AudioBookCD.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
                let aux = try context.fetch(fetchRequest) as [AudioBookCD]
                aux.forEach({ (cd) in
                    guard let audioBook: AudioBook = AudioBook.mapToModel(cd) else { return }
                    results.append(audioBook)
                })
            } catch {}
            
            guard results.count > 0 else {
                let error = NSError.error(withMessage: "No results for audiobooks with ids: \(ids)")
                observer.send(error: PersistenceLayerError.emptyResult(error: error))
                return
            }
            
            observer.send(value: results)
        }
    }
}
