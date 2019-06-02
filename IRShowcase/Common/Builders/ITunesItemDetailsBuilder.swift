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
    func make(navigation: UINavigationController?, postId: Int, network: DataProviderNetworkProtocol, persistence: DataProviderPersistenceProtocol, connectivity: ConnectivityService, action: @escaping (ITunesSearchListAction) -> Void) -> UIViewController {
        let coordinator = PostDetailsCoordinator(navigation: navigation, builders: self)
        let config = DataProviderConfiguration.standard
        let userHandlersFactory: DataProviderHandlersBuilder<[User]> = DataProviderHandlersBuilder()
        let userHandlers: DataProviderHandlers<[User]> = userHandlersFactory.makeDataProviderHandlers(config: config)
        let userDataProvider = DataProvider<[User]>(config: config, network: network, persistence: persistence, handlers: userHandlers)
        let postHandlersFactory: DataProviderHandlersBuilder<[Post]> = DataProviderHandlersBuilder()
        let postHandlers: DataProviderHandlers<[Post]> = postHandlersFactory.makeDataProviderHandlers(config: config)
        let postDataProvider = DataProvider<[Post]>(config: config, network: network, persistence: persistence, handlers: postHandlers)
        let commentsHandlersFactory: DataProviderHandlersBuilder<[Comment]> = DataProviderHandlersBuilder()
        let commentsHandlers: DataProviderHandlers<[Comment]> = commentsHandlersFactory.makeDataProviderHandlers(config: config)
        let commentsDataProvider = DataProvider<[Comment]>(config: config, network: network, persistence: persistence, handlers: commentsHandlers)
        let viewModel = ITunesItemDetailsViewModelImpl(routing: coordinator, postId: postId, userDataProvider: userDataProvider, postDataProvider: postDataProvider, commentsDataProvider: commentsDataProvider, connectivity: connectivity)
        return ITunesItemDetailsViewController(viewModel: viewModel)
    }
    // swiftlint:enable function_parameter_count
}
