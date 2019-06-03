//
//  ITunesItemDetailsViewModel.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 20/03/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import UIKit
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
    func userDidTapDeleteButton(sourceVC: UIViewController)
}

protocol ITunesItemDetailsViewModelOutputs {
    typealias FetchedStuffTuple = (AudioBook?, Track?)
    var fetchedStuff: Signal<Result<FetchedStuffTuple, ITunesItemDetailsViewModelError>, NoError> { get }
    var dataSourceChanges: Signal<ITunesItemDetailsViewModelState.VMSharedState.DataSource, NoError> { get }
}

protocol ITunesItemDetailsItemSpecific {
    var screenTitle: String { get }
}

protocol ITunesItemDetailsViewModel: ITunesItemDetailsHeaderDetails, ITunesItemDetailsItemSpecific {
    var inputs: ITunesItemDetailsViewModelInputs { get }
    var outputs: ITunesItemDetailsViewModelOutputs { get }
}
