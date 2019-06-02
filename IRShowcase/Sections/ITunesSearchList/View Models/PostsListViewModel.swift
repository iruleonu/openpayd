//
//  PostsListViewModel.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 20/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import ReactiveSwift
import enum Result.Result
import enum Result.NoError

protocol PostsListViewModelInputs {
    func viewDidLoad()
    func fetchStuff()
    func userDidTapCellWithPostId(_ postId: Int)
}

protocol PostsListViewModelOutputs {
    var fetchedStuff: Signal<[Post], NoError> { get }
    var dataSourceChanges: Signal<PostsListViewModelState.VMSharedState.DataSource, NoError> { get }
}

protocol PostsListViewModel: PostsListCollectionNodeDataSourceProtocol {
    var inputs: PostsListViewModelInputs { get }
    var outputs: PostsListViewModelOutputs { get }
}

final class PostsListViewModelImpl: PostsListViewModel, PostsListViewModelInputs, PostsListViewModelOutputs {
    private let routing: PostsListRouting
    private let dataProvider: DataProvider<[Post]>
    private let vmState: Atomic<(PostsListViewModelState.VMState, PostsListViewModelState.VMSharedState)>
    private let fetchedStuffProperty: MutableProperty<[Post]>
    private let dataSourceChangesProperty: MutableProperty<PostsListViewModelState.VMSharedState.DataSource>
    private var disposables = CompositeDisposable()
    
    var inputs: PostsListViewModelInputs { return self }
    private let viewDidLoadProperty: MutableProperty<Void>
    private let fetchStuffProperty: MutableProperty<Resource>
    
    var outputs: PostsListViewModelOutputs { return self }
    var fetchedStuff: Signal<[Post], NoError>
    var dataSourceChanges: Signal<PostsListViewModelState.VMSharedState.DataSource, NoError>
    
    deinit {
        disposables.dispose()
    }
    
    init(routing r: PostsListRouting, dataProvider dp: DataProvider<[Post]>) {
        routing = r
        dataProvider = dp
        vmState = Atomic((PostsListViewModelState.VMState.empty, PostsListViewModelState.VMSharedState.empty))
        
        viewDidLoadProperty = MutableProperty(())
        fetchStuffProperty = MutableProperty(Resource.unknown)
        
        fetchedStuffProperty = MutableProperty([])
        dataSourceChangesProperty = MutableProperty(vmState.value.1.dataSource)
        fetchedStuff = fetchedStuffProperty.signal
        dataSourceChanges = dataSourceChangesProperty.signal
        
        setupBindings()
    }
    
    private func setupBindings() {
        let dpProducer: (Resource) -> SignalProducer<([Post], DataProviderSource), DataProviderError> = { self.dataProvider.fetchStuff(resource: $0) }
        
        disposables += fetchStuffProperty.signal.observeValues { [weak self] (resource) in
            dpProducer(resource).start(on: QueueScheduler()).startWithResult { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let (value, source)):
                    switch source {
                    case .remote, .hybrid:
                        strongSelf.persistPosts(value)
                    default:
                        break
                    }
                    
                    strongSelf.vmState.modify({ vmState in
                        var sharedState = vmState.1
                        
                        let sharedStateAction = PostsListViewModelState.SharedStateAction.replacePosts(value)
                        sharedState = PostsListViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                        
                        vmState.1 = sharedState
                    })
                    
                    strongSelf.fetchedStuffProperty.value = value
                    strongSelf.dataSourceChangesProperty.value = strongSelf.vmState.value.1.dataSource
                case .failure(let error):
                    print(error.errorDescription)
                }
            }
        }
    }
    
    func viewDidLoad() {
        viewDidLoadProperty.value = ()
        fetchStuff()
    }
    
    func fetchStuff() {
        fetchStuffProperty.value = .posts
    }
    
    func userDidTapCellWithPostId(_ postId: Int) {
        routing.showPost(id: postId) { (action) in
            switch action {
            case .deletePost:
                break
            }
        }
    }
    
    func persistPosts(_ posts: [Post]) {
        _ = dataProvider.handlers.persistenceSaveHandler(dataProvider.persistence, posts).start()
    }
}

// MARK: PostsListCollectionNodeDataSourceProtocol
extension PostsListViewModelImpl {
    func numberOfSections(dataSource: PostsListViewModelState.VMSharedState.DataSource) -> Int {
        return 1
    }

    func numberOfRowsInSection(_ section: Int, dataSource: PostsListViewModelState.VMSharedState.DataSource) -> Int {
        return dataSource.rows.count
    }
}
