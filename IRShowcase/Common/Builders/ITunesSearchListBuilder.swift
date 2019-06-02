//
//  PostsListBuilder.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 20/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import UIKit
import enum Result.Result

// Actions available from childs built from PostsListChildBuilders
enum ITunesSearchListAction {
    case deleteTrack
    case deleteAudioBook
    case markTrackHasSeen
    case markAudioBookHasSeen
}

// swiftlint:disable function_parameter_count
protocol ITunesSearchListChildBuilders {
    func makeAudioBookDetails(navigation: UINavigationController?, id: Int, network: DataProviderNetworkProtocol, persistence: DataProviderPersistenceProtocol, connectivity: ConnectivityService, action: @escaping (ITunesSearchListAction) -> Void) -> UIViewController
    func makeTrackDetails(navigation: UINavigationController?, id: Int, network: DataProviderNetworkProtocol, persistence: DataProviderPersistenceProtocol, connectivity: ConnectivityService, action: @escaping (ITunesSearchListAction) -> Void) -> UIViewController
}
// swiftlint:enable function_parameter_count

struct ITunesSearchListBuilder: ITunesSearchListChildBuilders {
    func make(navigation: UINavigationController, network: DataProviderNetworkProtocol, dataProviderPersistence: DataProviderPersistenceProtocol, searchListPersistence: ITunesSearchListViewModelPersistenceFetcher, connectivity: ConnectivityService) -> UIViewController {
        let coordinator = ITunesSearchListCoordinator(navigation: navigation, builders: self, network: network, persistence: dataProviderPersistence, connectivity: connectivity)
        let localConfig = DataProviderConfiguration.localOnly
        let remoteConfig = DataProviderConfiguration.remoteOnly
        let localDataProvider: DataProvider<SearchItemResponse> = DataProviderBuilder.makeDataProvider(config: localConfig, network: network, persistence: dataProviderPersistence)
        let remoteDataProvider: DataProvider<SearchItemResponse> = DataProviderBuilder.makeDataProvider(config: remoteConfig, network: network, persistence: dataProviderPersistence)
        let viewModel = ITunesSearchListViewModelImpl(routing: coordinator, persistenceFetcher: searchListPersistence, persistenceSaver: localDataProvider, remoteDataProvider: remoteDataProvider, connectivity: connectivity)
        let viewController = ITunesSearchListViewController(viewModel: viewModel)
        return viewController
    }
    
    // swiftlint:disable function_parameter_count
    func makeAudioBookDetails(navigation: UINavigationController?, id: Int, network: DataProviderNetworkProtocol, persistence: DataProviderPersistenceProtocol, connectivity: ConnectivityService, action: @escaping (ITunesSearchListAction) -> Void) -> UIViewController {
        let vc = ITunesItemDetailsBuilder().make(navigation: navigation, audioBookId: id, network: network, persistence: persistence, connectivity: connectivity, action: action)
        return vc
    }
    func makeTrackDetails(navigation: UINavigationController?, id: Int, network: DataProviderNetworkProtocol, persistence: DataProviderPersistenceProtocol, connectivity: ConnectivityService, action: @escaping (ITunesSearchListAction) -> Void) -> UIViewController {
        let vc = ITunesItemDetailsBuilder().make(navigation: navigation, trackId: id, network: network, persistence: persistence, connectivity: connectivity, action: action)
        return vc
    }
    // swiftlint:enable function_parameter_count
}
