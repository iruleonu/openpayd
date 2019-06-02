//
//  PersistenceLayer+Track.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 01/06/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import CoreData
import ReactiveSwift

protocol EntityFetchTracksProtocol {
    func fetchTrack(id: Int64) -> SignalProducer<[Track], PersistenceLayerError>
}

extension PersistenceLayerImpl: EntityFetchTracksProtocol {
    func fetchTrack(id: Int64) -> SignalProducer<[Track], PersistenceLayerError> {
        let context = coreDataStack.managedObjectContext!
        
        return SignalProducer<[Track], PersistenceLayerError> { observer, _ in
            var results: [Track] = []
            
            do {
                let fetchRequest: NSFetchRequest<TrackCD> = TrackCD.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %lld", Int64(id))
                let aux = try context.fetch(fetchRequest) as [TrackCD]
                aux.forEach({ (cd) in
                    guard let audioBook: Track = Track.mapToModel(cd) else { return }
                    results.append(audioBook)
                })
            } catch {}
            
            guard results.count > 0 else {
                let error = NSError.error(withMessage: "No results for post with id: \(id)")
                observer.send(error: PersistenceLayerError.emptyResult(error: error))
                return
            }
            
            observer.send(value: results)
        }
    }
}
