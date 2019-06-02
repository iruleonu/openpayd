//
//  ITunesItemDetailsViewModel.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 20/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import ReactiveSwift
import enum Result.Result
import enum Result.NoError

enum ITunesItemDetailsViewModelError: Error {
    case unknown
    case noData
    case noConnection
    
    var errorDescription: String {
        switch self {
        case .noData:
            return "Couldnt fetch any data"
        default:
            return "Unknown error"
        }
    }
}

protocol ITunesItemDetailsViewModelInputs {
    func viewDidLoad()
    func viewDidAppear()
    func triggerRefreshControl()
}

protocol ITunesItemDetailsViewModelOutputs {
    typealias FetchedStuffTuple = (Post?, User?, [Comment]?)
    var fetchedStuff: Signal<Result<FetchedStuffTuple, ITunesItemDetailsViewModelError>, NoError> { get }
    var dataSourceChanges: Signal<ITunesItemDetailsViewModelState.VMSharedState.DataSource, NoError> { get }
}

protocol ITunesItemDetailsViewModel: ITunesItemDetailsCollectionNodeDataSourceProtocol {
    var inputs: ITunesItemDetailsViewModelInputs { get }
    var outputs: ITunesItemDetailsViewModelOutputs { get }
}

final class ITunesItemDetailsViewModelImpl: ITunesItemDetailsViewModel, ITunesItemDetailsViewModelInputs, ITunesItemDetailsViewModelOutputs {
    private let routing: PostDetailsRouting
    private let postId: Int
    private let userDataProvider: DataProvider<[User]>
    private let postDataProvider: DataProvider<[Post]>
    private let commentsDataProvider: DataProvider<[Comment]>
    private let vmState: Atomic<(ITunesItemDetailsViewModelState.VMState, ITunesItemDetailsViewModelState.VMSharedState)>
    private let fetchedPostProperty: MutableProperty<Post?>
    private let fetchedUserProperty: MutableProperty<User?>
    private let fetchedCommentsProperty: MutableProperty<[Comment]?>
    private let connectivity: ConnectivityService
    private var refreshSupplementaryElementProperty: MutableProperty<ITunesItemDetailsSupplementaryElementOfKinds>
    private var disposables = CompositeDisposable()
    
    var inputs: ITunesItemDetailsViewModelInputs { return self }
    private let viewDidLoadProperty: MutableProperty<Void>
    private let fetchStuffProperty: MutableProperty<DataProviderFetchType>
    
    var outputs: ITunesItemDetailsViewModelOutputs { return self }
    var fetchedStuff: Signal<Result<FetchedStuffTuple, ITunesItemDetailsViewModelError>, NoError>
    private let fetchedStuffObserver: Signal<Result<FetchedStuffTuple, ITunesItemDetailsViewModelError>, NoError>.Observer
    var dataSourceChanges: Signal<ITunesItemDetailsViewModelState.VMSharedState.DataSource, NoError>
    private let dataSourceChangesObserver: Signal<ITunesItemDetailsViewModelState.VMSharedState.DataSource, NoError>.Observer
    
    let fetchPostAction: Action<(Int, DataProviderFetchType), ([Post], DataProviderSource, DataProviderFetchType), DataProviderError>
    let fetchCommentsAction: Action<(Int, DataProviderFetchType), ([Comment], DataProviderSource, DataProviderFetchType), DataProviderError>
    let fetchUserAction: Action<(Int, DataProviderFetchType), ([User], DataProviderSource, DataProviderFetchType), DataProviderError>

    init(routing r: PostDetailsRouting, postId pid: Int, userDataProvider udp: DataProvider<[User]>, postDataProvider pdp: DataProvider<[Post]>, commentsDataProvider cdp: DataProvider<[Comment]>, connectivity c: ConnectivityService) {
        routing = r
        postId = pid
        userDataProvider = udp
        postDataProvider = pdp
        commentsDataProvider = cdp
        vmState = Atomic((ITunesItemDetailsViewModelState.VMState.empty, ITunesItemDetailsViewModelState.VMSharedState.empty))
        fetchedPostProperty = MutableProperty(nil)
        fetchedUserProperty = MutableProperty(nil)
        fetchedCommentsProperty = MutableProperty(nil)
        connectivity = c
        refreshSupplementaryElementProperty = MutableProperty(.header)
        
        viewDidLoadProperty = MutableProperty(())
        fetchStuffProperty = MutableProperty(DataProviderFetchType.config)
        
        (fetchedStuff, fetchedStuffObserver) = Signal<Result<FetchedStuffTuple, ITunesItemDetailsViewModelError>, NoError>.pipe()
        (dataSourceChanges, dataSourceChangesObserver) = Signal<ITunesItemDetailsViewModelState.VMSharedState.DataSource, NoError>.pipe()
        
        fetchPostAction = Action { ITunesItemDetailsViewModelImpl.fetchPostHandler(postId: $0.0, fetchType: $0.1, postDataProvider: pdp) }
        fetchCommentsAction = Action { ITunesItemDetailsViewModelImpl.fetchCommentsHandler(postId: $0.0, fetchType: $0.1, commentsDataProvider: cdp) }
        fetchUserAction = Action { ITunesItemDetailsViewModelImpl.fetchUserHandler(userId: $0.0, fetchType: $0.1, userDataProvider: udp) }
        
        setupBindings()
    }
    
    deinit {
        disposables.dispose()
    }
    
    private func setupBindings() {
        disposables += viewDidLoadProperty.signal.observeValues { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.disposables += strongSelf.connectivity.performSingleConnectivityCheck().start()
            strongSelf.fetchStuffProperty.value = DataProviderFetchType.local
        }
        disposables += fetchStuffProperty.signal.observeValues { [weak self] (fetchType) in
            guard let strongSelf = self else { return }
            if !strongSelf.fetchPostAction.isExecuting.value {
                strongSelf.disposables += strongSelf.fetchPostAction.apply((strongSelf.postId, fetchType)).start()
            }
            if !strongSelf.fetchCommentsAction.isExecuting.value {
                strongSelf.disposables += strongSelf.fetchCommentsAction.apply((strongSelf.postId, fetchType)).start()
            }
        }
        fetchPostAction.values.observe(on: QueueScheduler()).observeValues { [weak self] (value) in
            self?.postDPHandler(result: Result.success(value))
        }
        fetchPostAction.errors.observeValues { [weak self] (error) in
            self?.postDPHandler(result: Result.failure(error))
        }
        fetchCommentsAction.values.observeValues { [weak self] (value) in
            self?.commentsDPHandler(result: Result.success(value))
        }
        fetchCommentsAction.errors.observeValues { [weak self] (error) in
            self?.commentsDPHandler(result: Result.failure(error))
        }
        fetchUserAction.values.observeValues { [weak self] (value) in
            self?.userDPHandler(result: Result.success(value))
        }
        fetchUserAction.errors.observeValues { [weak self] (error) in
            self?.userDPHandler(result: Result.failure(error))
        }
        
        let fetchedPost = fetchedPostProperty.signal.map(value: ())
        let fetchedUser = fetchedUserProperty.signal.map(value: ())
        let fechedComments = fetchedCommentsProperty.signal.map(value: ())
        disposables += Signal.zip([fetchedPost, fetchedUser, fechedComments])
            .observe(on: QueueScheduler())
            .observeValues { [weak self] _ in
                guard let strongSelf = self else { return }
                let vmState = strongSelf.vmState.value
                let post = vmState.0.post
                let user = vmState.0.user
                let comments = vmState.0.comments
                let fetchedStuffTuple: FetchedStuffTuple = (post, user, comments)
                
                guard fetchedStuffTuple.0 != nil || fetchedStuffTuple.1 != nil || fetchedStuffTuple.2 != nil else {
                    self?.fetchedStuffObserver.send(value: Result.failure(ITunesItemDetailsViewModelError.noData))
                    return
                }
                
                self?.fetchedStuffObserver.send(value: Result.success(fetchedStuffTuple))
        }
    }
    
    func viewDidLoad() {
        viewDidLoadProperty.value = ()
    }
    
    func viewDidAppear() {
        fetchStuffProperty.value = .config
    }
    
    func triggerRefreshControl() {
        connectivity.performSingleConnectivityCheck().startWithValues { [weak self] (status) in
            guard let strongSelf = self else { return }
            
            guard status.isReachable else {
                strongSelf.fetchStuffProperty.value = DataProviderFetchType.local
                return
            }
            
            strongSelf.fetchStuffProperty.value = DataProviderFetchType.config
        }
    }
    
    private static func fetchPostHandler(postId: Int, fetchType: DataProviderFetchType, postDataProvider pdp: DataProvider<[Post]>) -> SignalProducer<([Post], DataProviderSource, DataProviderFetchType), DataProviderError> {
        return SignalProducer({ (observer, _) in
            pdp.fetchStuff(resource: .post(id: "\(postId)"), explicitFetchType: fetchType).startWithResult({ (result) in
                switch result {
                case .success(let value):
                    let tuple = (value.0, value.1, fetchType)
                    observer.send(value: tuple)
                    observer.sendCompleted()
                case .failure(let error):
                    observer.send(error: error)
                }
            })
        })
    }
    
    private static func fetchCommentsHandler(postId: Int, fetchType: DataProviderFetchType, commentsDataProvider udp: DataProvider<[Comment]>) -> SignalProducer<([Comment], DataProviderSource, DataProviderFetchType), DataProviderError> {
        return SignalProducer({ (observer, _) in
            udp.fetchStuff(resource: .comments(postId: "\(postId)"), explicitFetchType: fetchType).startWithResult({ (result) in
                switch result {
                case .success(let value):
                    let tuple = (value.0, value.1, fetchType)
                    observer.send(value: tuple)
                    observer.sendCompleted()
                case .failure(let error):
                    observer.send(error: error)
                }
            })
        })
    }
    
    private static func fetchUserHandler(userId: Int, fetchType: DataProviderFetchType, userDataProvider udp: DataProvider<[User]>) -> SignalProducer<([User], DataProviderSource, DataProviderFetchType), DataProviderError> {
        return SignalProducer({ (observer, _) in
            udp.fetchStuff(resource: .user(id: "\(userId)"), explicitFetchType: fetchType).startWithResult({ (result) in
                switch result {
                case .success(let value):
                    let tuple = (value.0, value.1, fetchType)
                    observer.send(value: tuple)
                    observer.sendCompleted()
                case .failure(let error):
                    observer.send(error: error)
                }
            })
        })
    }
    
    private func postDPHandler(result: Result<([Post], DataProviderSource, DataProviderFetchType), DataProviderError>) {
        switch result {
        case .success(let (posts, source, fetchType)):
            guard let post = posts.first else { return }
            
            vmState.modify({ vmState in
                var state = vmState.0
                
                let stateAction = ITunesItemDetailsViewModelState.StateAction.insertPost(post)
                state = ITunesItemDetailsViewModelState.handleStateAction(stateAction, state: state)
                
                vmState.0 = state
            })
            
            disposables += fetchUserAction.apply((post.userId, fetchType)).start(on: QueueScheduler()).start()
            
            if source == .remote {
                disposables += persistPostDetails([post])
            }
            
            fetchedPostProperty.value = post
        case .failure(let error):
            print(error.errorDescription)
            fetchedPostProperty.value = nil
            fetchedUserProperty.value = nil
        }
    }
    
    private func commentsDPHandler(result: Result<([Comment], DataProviderSource, DataProviderFetchType), DataProviderError>) {
        switch result {
        case .success(let (comments, source, _)):
            vmState.modify({ vmState in
                var state = vmState.0
                var sharedState = vmState.1
                
                let action = ITunesItemDetailsViewModelState.HybridAction.insertOrUpdateComments(comments)
                (state, sharedState) = ITunesItemDetailsViewModelState.handleHybridStateAction(action, state: state, sharedState: sharedState)
                
                vmState.0 = state
                vmState.1 = sharedState
            })
            
            if source == .remote {
                disposables += persistComments(comments)
            }
            
            fetchedCommentsProperty.value = comments
            dataSourceChangesObserver.send(value: vmState.value.1.dataSource)
        case .failure(let error):
            print(error.errorDescription)
            fetchedCommentsProperty.value = nil
        }
    }
    
    private func userDPHandler(result: Result<([User], DataProviderSource, DataProviderFetchType), DataProviderError>) {
        switch result {
        case .success(let (users, source, _)):
            guard let user = users.first else { return }
            
            vmState.modify({ vmState in
                var state = vmState.0
                
                let stateAction = ITunesItemDetailsViewModelState.StateAction.insertPosterDetails(user)
                state = ITunesItemDetailsViewModelState.handleStateAction(stateAction, state: state)
                
                vmState.0 = state
            })
            
            if source == .remote {
                disposables += persistPosterDetails(users)
            }
            
            fetchedUserProperty.value = user
            refreshSupplementaryElementProperty.value = .header
        case .failure(let error):
            print(error.errorDescription)
            fetchedUserProperty.value = nil
        }
    }
    
    private func removePostDetailsData() -> Disposable {
        let aux = CompositeDisposable()

        aux += postDataProvider.removeEntities(forResource: .post(id: "\(postId)")).start()
        aux += commentsDataProvider.removeEntities(forResource: .comments(postId: "\(postId)")).start()
        if let userId = vmState.value.0.user?.id {
            aux += userDataProvider.removeEntities(forResource: .user(id: "\(userId)")).start()
        }

        return aux
    }
    
    private func persistPostDetails(_ posts: [Post]) -> Disposable? {
        guard posts.count > 0 else { return nil }
        return postDataProvider.saveToPersistence(posts).start()
    }
    
    private func persistPosterDetails(_ user: [User]) -> Disposable? {
        guard user.count > 0 else { return nil }
        return userDataProvider.saveToPersistence(user).start()
    }
    
    private func persistComments(_ comments: [Comment]) -> Disposable? {
        guard comments.count > 0 else { return nil }
        return commentsDataProvider.saveToPersistence(comments).start()
    }
}

extension ITunesItemDetailsViewModelImpl: ITunesItemDetailsCollectionNodeDataSourceProtocol {
    func numberOfSections(dataSource: ITunesItemDetailsViewModelState.VMSharedState.DataSource) -> Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int, dataSource: ITunesItemDetailsViewModelState.VMSharedState.DataSource) -> Int {
        return dataSource.rows.count
    }
}

extension ITunesItemDetailsViewModelImpl: ITunesItemDetailsCollectionNodeDataSourceHeaderDetails {
    var posterName: String {
        return vmState.value.0.user?.name ?? ""
    }
    
    var posterUsername: String {
        return vmState.value.0.user?.username ?? ""
    }
    
    var posterEmail: String {
        return vmState.value.0.user?.email ?? ""
    }
    
    var refreshSupplementaryElementOfKind: MutableProperty<ITunesItemDetailsSupplementaryElementOfKinds> {
        return refreshSupplementaryElementProperty
    }
}
