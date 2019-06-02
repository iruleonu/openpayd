//
//  PostDetailsViewModel.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 20/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import ReactiveSwift
import enum Result.Result
import enum Result.NoError

protocol PostDetailsViewModelInputs {
    func viewDidLoad()
    func fetchStuff()
}

protocol PostDetailsViewModelOutputs {
    var fetchedStuff: Signal<(), NoError> { get }
    var dataSourceChanges: Signal<PostDetailsViewModelState.VMSharedState.DataSource, NoError> { get }
    var headerDataChanges: Signal<Void, NoError> { get }
}

protocol PostDetailsViewModel: PostDetailsCollectionNodeDataSourceProtocol {
    var inputs: PostDetailsViewModelInputs { get }
    var outputs: PostDetailsViewModelOutputs { get }
}

final class PostDetailsViewModelImpl: PostDetailsViewModel, PostDetailsViewModelInputs, PostDetailsViewModelOutputs {
    private let routing: PostDetailsRouting
    private let postId: Int
    private let userDataProvider: DataProvider<[User]>
    private let postDataProvider: DataProvider<[Post]>
    private let commentsDataProvider: DataProvider<[Comment]>
    private let vmState: Atomic<(PostDetailsViewModelState.VMState, PostDetailsViewModelState.VMSharedState)>
    private let fetchUserProperty: MutableProperty<Int?>
    private let fetchedPostProperty: MutableProperty<Post?>
    private let fetchedUserProperty: MutableProperty<User?>
    private let fetchedCommentsProperty: MutableProperty<[Comment]?>
    private var disposables = CompositeDisposable()
    
    var inputs: PostDetailsViewModelInputs { return self }
    private let viewDidLoadProperty: MutableProperty<Void>
    private let fetchStuffProperty: MutableProperty<Void>
    
    var outputs: PostDetailsViewModelOutputs { return self }
    var fetchedStuff: Signal<(), NoError>
    private let fetchedStuffProperty: MutableProperty<()>
    var dataSourceChanges: Signal<PostDetailsViewModelState.VMSharedState.DataSource, NoError>
    private let dataSourceChangesProperty: MutableProperty<PostDetailsViewModelState.VMSharedState.DataSource>
    var headerDataChanges: Signal<Void, NoError>
    private let headerDataChangesProperty: MutableProperty<Void>
    
    init(routing r: PostDetailsRouting, postId pid: Int, userDataProvider udp: DataProvider<[User]>, postDataProvider pdp: DataProvider<[Post]>, commentsDataProvider cdp: DataProvider<[Comment]>) {
        routing = r
        postId = pid
        userDataProvider = udp
        postDataProvider = pdp
        commentsDataProvider = cdp
        vmState = Atomic((PostDetailsViewModelState.VMState.empty, PostDetailsViewModelState.VMSharedState.empty))
        
        viewDidLoadProperty = MutableProperty(())
        fetchStuffProperty = MutableProperty(())
        fetchedStuffProperty = MutableProperty(())
        fetchedStuff = fetchedStuffProperty.signal
        dataSourceChangesProperty = MutableProperty(vmState.value.1.dataSource)
        dataSourceChanges = dataSourceChangesProperty.signal
        headerDataChangesProperty = MutableProperty(())
        headerDataChanges = headerDataChangesProperty.signal
        
        fetchUserProperty = MutableProperty(nil)
        fetchedPostProperty = MutableProperty(nil)
        fetchedUserProperty = MutableProperty(nil)
        fetchedCommentsProperty = MutableProperty(nil)

        setupBindings()
    }
    
    deinit {
        disposables.dispose()
    }
    
    private func setupBindings() {
        let postDPProducer = postDataProvider.fetchStuff(resource: .post(id: "\(self.postId)"))
        let commentsDPProducer = commentsDataProvider.fetchStuff(resource: .comments(postId: "\(self.postId)"))
        disposables += fetchStuffProperty.signal.observeValues { [weak self] (_) in
            postDPProducer.start(on: QueueScheduler()).startWithResult { [weak self] in
                self?.postDPHandler(result: $0)
            }
            commentsDPProducer.start(on: QueueScheduler()).startWithResult { [weak self] in
                self?.commentsDPHandler(result: $0)
            }
        }
        
        let userDPProducer: (Int) -> SignalProducer<([User], DataProviderSource), DataProviderError> = { self.userDataProvider.fetchStuff(resource: .user(id: "\($0)")) }
        disposables += fetchUserProperty.signal.skipNil().observeValues { [weak self] (userId) in
            userDPProducer(userId).start(on: QueueScheduler()).startWithResult { [weak self] in
                self?.userDPHandler(result: $0)
            }
        }
        
        let fetchedPost = fetchedPostProperty.signal.map(value: ())
        let fetchedUser = fetchedUserProperty.signal.map(value: ())
        let fechedComments = fetchedCommentsProperty.signal.map(value: ())
        disposables += Signal.zip([fetchedPost, fetchedUser, fechedComments])
            .observe(on: QueueScheduler())
            .observeValues { [weak self] _ in
                self?.fetchedStuffProperty.value = ()
        }
    }
    
    func viewDidLoad() {
        viewDidLoadProperty.value = ()
        fetchStuff()
    }
    
    func fetchStuff() {
        // Fetch post and comments with the postId passed on the initializer
        // After fething the post we can grab the poster userId to fetch his full details
        fetchStuffProperty.value = ()
    }
    
    private func postDPHandler(result: Result<([Post], DataProviderSource), DataProviderError>) {
        switch result {
        case .success(let (posts, _)):
            guard let post = posts.first else { return }
            
            vmState.modify({ vmState in
                var state = vmState.0
                
                let stateAction = PostDetailsViewModelState.StateAction.insertPost(post)
                state = PostDetailsViewModelState.handleStateAction(stateAction, state: state)
                
                vmState.0 = state
            })
            
            disposables += persistPostDetails(posts)
            fetchedPostProperty.value = post
            fetchUserProperty.value = post.userId
        case .failure(let error):
            print(error.errorDescription)
            fetchedPostProperty.value = nil
        }
    }
    
    private func commentsDPHandler(result: Result<([Comment], DataProviderSource), DataProviderError>) {
        switch result {
        case .success(let (comments, _)):
            vmState.modify({ vmState in
                var sharedState = vmState.1
                
                let sharedStateAction = PostDetailsViewModelState.SharedStateAction.insertOrUpdateComments(comments)
                sharedState = PostDetailsViewModelState.handleSharedStateAction(sharedStateAction, sharedState: sharedState)
                
                vmState.1 = sharedState
            })
            
            disposables += persistComments(comments)
            fetchedCommentsProperty.value = comments
            dataSourceChangesProperty.value = vmState.value.1.dataSource
        case .failure(let error):
            print(error.errorDescription)
            fetchedCommentsProperty.value = nil
        }
    }
    
    private func userDPHandler(result: Result<([User], DataProviderSource), DataProviderError>) {
        switch result {
        case .success(let (users, _)):
            guard let user = users.first else { return }
            
            vmState.modify({ vmState in
                var state = vmState.0
                
                let stateAction = PostDetailsViewModelState.StateAction.insertPosterDetails(user)
                state = PostDetailsViewModelState.handleStateAction(stateAction, state: state)
                
                vmState.0 = state
            })
            
            disposables += persistPosterDetails(users)
            fetchedUserProperty.value = user
            headerDataChangesProperty.value = ()
        case .failure(let error):
            print(error.errorDescription)
            fetchedUserProperty.value = nil
        }
    }
    
    private func persistPostDetails(_ posts: [Post]) -> Disposable {
        return postDataProvider.handlers.persistenceSaveHandler(postDataProvider.persistence, posts).start()
    }
    
    private func persistPosterDetails(_ user: [User]) -> Disposable {
        return userDataProvider.handlers.persistenceSaveHandler(userDataProvider.persistence, user).start()
    }
    
    private func persistComments(_ comments: [Comment]) -> Disposable {
        return commentsDataProvider.handlers.persistenceSaveHandler(commentsDataProvider.persistence, comments).start()
    }
}

extension PostDetailsViewModelImpl: PostDetailsCollectionNodeDataSourceProtocol {
    func numberOfSections(dataSource: PostDetailsViewModelState.VMSharedState.DataSource) -> Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int, dataSource: PostDetailsViewModelState.VMSharedState.DataSource) -> Int {
        return dataSource.rows.count
    }
}

extension PostDetailsViewModelImpl: PostDetailsCollectionNodeDataSourceHeaderDetails {
    var posterName: String {
        return vmState.value.0.user?.name ?? ""
    }
    
    var posterUsername: String {
        return vmState.value.0.user?.username ?? ""
    }
    
    var posterEmail: String {
        return vmState.value.0.user?.email ?? ""
    }
}
