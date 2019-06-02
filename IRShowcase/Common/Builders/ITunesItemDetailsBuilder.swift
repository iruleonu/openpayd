//
//  PostDetailsBuilder.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 20/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import UIKit
import enum Result.Result

protocol ITunesItemDetailsChildBuilders {
    // Empty
}

struct ITunesItemDetailsBuilder: ITunesItemDetailsChildBuilders {
    // swiftlint:disable function_parameter_count
    func make(navigation: UINavigationController?, audioBookId: Int, network: DataProviderNetworkProtocol, persistence: DataProviderPersistenceProtocol, connectivity: ConnectivityService, action: @escaping (ITunesSearchListAction) -> Void) -> UIViewController {
        let coordinator = ITunesItemDetailsCoordinator(navigation: navigation, builders: self)
        let config = DataProviderConfiguration.localOnly
        let audiobookHandlersFactory: DataProviderHandlersBuilder<[AudioBook]> = DataProviderHandlersBuilder()
        let audiobookHandlers: DataProviderHandlers<[AudioBook]> = audiobookHandlersFactory.makeDataProviderHandlers(config: config)
        let audiobooksDataProvider = DataProvider<[AudioBook]>(config: config, network: network, persistence: persistence, handlers: audiobookHandlers)
        let viewModel = ITunesAudioBookItemDetailsViewModelImpl(routing: coordinator, audioBookId: audioBookId, audioBooksDataProvider: audiobooksDataProvider, action: action)
        return ITunesItemDetailsViewController(viewModel: viewModel)
    }
    
    func make(navigation: UINavigationController?, trackId: Int, network: DataProviderNetworkProtocol, persistence: DataProviderPersistenceProtocol, connectivity: ConnectivityService, action: @escaping (ITunesSearchListAction) -> Void) -> UIViewController {
        let coordinator = ITunesItemDetailsCoordinator(navigation: navigation, builders: self)
        let config = DataProviderConfiguration.localOnly
        let trackHandlersFactory: DataProviderHandlersBuilder<[Track]> = DataProviderHandlersBuilder()
        let trackHandlers: DataProviderHandlers<[Track]> = trackHandlersFactory.makeDataProviderHandlers(config: config)
        let tracksDataProvider = DataProvider<[Track]>(config: config, network: network, persistence: persistence, handlers: trackHandlers)
        let viewModel = ITunesTrackItemDetailsViewModelImpl(routing: coordinator, trackId: trackId, tracksDataProvider: tracksDataProvider, action: action)
        return ITunesItemDetailsViewController(viewModel: viewModel)
    }
    // swiftlint:enable function_parameter_count
}
