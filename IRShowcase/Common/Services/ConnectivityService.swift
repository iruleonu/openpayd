//
//  ConnectivityService.swift
//  IRShowcase
//
//  Created by Nuno Salvador on 03/04/2019.
//  Copyright © 2019 Nuno Salvador. All rights reserved.
//

import Foundation
import Connectivity
import ReactiveSwift
import enum Result.Result
import enum Result.NoError

//sourcery: AutoMockable
protocol ConnectivityService {
    var status: MutableProperty<ConnectivityServiceStatus> { get }
    var isReachableProperty: MutableProperty<Bool> { get }
    func performSingleConnectivityCheck() -> SignalProducer<ConnectivityServiceStatus, NoError>
}

enum ConnectivityServiceStatus: CustomStringConvertible {
    case connected
    case connectedViaCellular
    case connectedViaCellularWithoutInternet
    case connectedViaWiFi
    case connectedViaWiFiWithoutInternet
    case notConnected
    
    var isReachable: Bool {
        return [.connected, .connectedViaCellular, .connectedViaWiFi].contains(self)
    }
    
    var description: String {
        switch self {
        case .connected:
            return "Connected"
        case .connectedViaCellular:
            return "Connected via celullar"
        case .connectedViaCellularWithoutInternet:
            return "Connected via celullar without internet"
        case .connectedViaWiFi:
            return "Connected via wifi"
        case .connectedViaWiFiWithoutInternet:
            return "Connected via wifi without internet"
        default:
            return "Not connected"
        }
    }
}

class ConnectivityServiceImpl: ConnectivityService {
    static let `default` = ConnectivityServiceBuilder.make()
    
    let connectivity: Connectivity
    let status: MutableProperty<ConnectivityServiceStatus>
    let isReachableProperty: MutableProperty<Bool>

    init(connectivity c: Connectivity) {
        connectivity = c
        status = MutableProperty(ConnectivityServiceImpl.mapConnectivityStatusToServiceConnectivityStatus(c.status))
        isReachableProperty = MutableProperty(ConnectivityServiceImpl.mapConnectivityStatusToBinary(connectivity: c.status))
        setupConnectivityUrl()
        startConnectivityObserver()
        
        performConnectivityCheck(connectivity: connectivity).startWithValues { [weak self] (status) in
            self?.updateConnectionStatus(status)
        }
    }
    
    func performSingleConnectivityCheck() -> SignalProducer<ConnectivityServiceStatus, NoError> {
        return performConnectivityCheck(connectivity: connectivity).map({ ConnectivityServiceImpl.mapConnectivityStatusToServiceConnectivityStatus($0) })
    }
    
    private func setupConnectivityUrl() {
        connectivity.validationMode = .matchesRegularExpression
        let regex = """
        (ok)|(graphql)|(true)|(Success)
        """
        connectivity.expectedResponseRegEx = regex
        var allUrls = connectivity.connectivityURLs
        allUrls.append(contentsOf: connectivityUrls)
        connectivity.connectivityURLs = connectivityUrls
    }
    
    private var connectivityUrls: [URL] {
        let urlStrings = ["https://www.apple.com/library/test/success.html"]
        return urlStrings.compactMap({ $0 }).compactMap({ URL(string: $0)?.deletingLastPathComponent().appendingPathComponent("status") })
    }
    
    private func startConnectivityObserver() {
        let connectivityChanged: (Connectivity) -> Void = { [weak self] connectivity in
            self?.updateConnectionStatus(connectivity.status)
        }
        connectivity.whenConnected = connectivityChanged
        connectivity.whenDisconnected = connectivityChanged
        connectivity.startNotifier()
    }
    
    private func updateConnectionStatus(_ s: Connectivity.Status) {
        status.value = ConnectivityServiceImpl.mapConnectivityStatusToServiceConnectivityStatus(s)
        
        let isReachable = ConnectivityServiceImpl.mapConnectivityStatusToBinary(connectivity: s)
        guard isReachableProperty.value != isReachable else { return }
        isReachableProperty.value = isReachable
    }
    
    private func performConnectivityCheck(connectivity: Connectivity) -> SignalProducer<Connectivity.Status, NoError> {
        return SignalProducer({ (observer, _) in
            connectivity.checkConnectivity { connectivity in
                observer.send(value: connectivity.status)
                observer.sendCompleted()
            }
        })
    }
    
    private static func mapConnectivityStatusToBinary(connectivity: Connectivity.Status) -> Bool {
        return [.connected, .connectedViaCellular, .connectedViaWiFi].contains(connectivity)
    }
    
    private static func mapConnectivityStatusToServiceConnectivityStatus(_ connectivity: Connectivity.Status) -> ConnectivityServiceStatus {
        var aux: ConnectivityServiceStatus
        
        switch connectivity {
        case .connected:
            aux = .connected
        case .connectedViaCellular:
            aux = .connectedViaCellular
        case .connectedViaCellularWithoutInternet:
            aux = .connectedViaCellularWithoutInternet
        case .connectedViaWiFi:
            aux = .connectedViaWiFi
        case .connectedViaWiFiWithoutInternet:
            aux = .connectedViaWiFiWithoutInternet
        case .notConnected:
            aux = .notConnected
        }
        
        return aux
    }
}

extension ConnectivityServiceImpl: AppService {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
