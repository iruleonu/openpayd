// Generated using Sourcery 0.16.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


//swiftlint:disable identifier_name
//swiftlint:disable function_body_length
//swiftlint:disable force_cast
//swiftlint:disable vertical_whitespace

#if MockyCustom
import SwiftyMocky
import ReactiveSwift
import Result
@testable import IRShowcase

    public final class MockyAssertion {
        public static var handler: ((Bool, String, StaticString, UInt) -> Void)?
    }

    func MockyAssert(_ expression: @autoclosure () -> Bool, _ message: @autoclosure () -> String = "Verification failed", file: StaticString = #file, line: UInt = #line) {
        guard let handler = MockyAssertion.handler else {
            assert(expression, message, file: file, line: line)
            return
        }

        handler(expression(), message(), file, line)
    }
#elseif Mocky
import SwiftyMocky
import XCTest
import ReactiveSwift
import Result
@testable import IRShowcase

    func MockyAssert(_ expression: @autoclosure () -> Bool, _ message: @autoclosure () -> String = "Verification failed", file: StaticString = #file, line: UInt = #line) {
        XCTAssert(expression(), message(), file: file, line: line)
    }
#else
import Sourcery
import SourceryRuntime
#endif


// MARK: - APIService
open class APIServiceMock: APIService, Mock {
    init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    public var serverConfig: ServerConfigProtocol {
		get {	invocations.append(.p_serverConfig_get); return __p_serverConfig ?? givenGetterValue(.p_serverConfig_get, "APIServiceMock - stub value for serverConfig was not defined") }
		@available(*, deprecated, message: "Using setters on readonly variables is deprecated, and will be removed in 3.1. Use Given to define stubbed property return value.")
		set {	__p_serverConfig = newValue }
	}
	private var __p_serverConfig: (ServerConfigProtocol)?

    public var apiBaseUrl: URL {
		get {	invocations.append(.p_apiBaseUrl_get); return __p_apiBaseUrl ?? givenGetterValue(.p_apiBaseUrl_get, "APIServiceMock - stub value for apiBaseUrl was not defined") }
		@available(*, deprecated, message: "Using setters on readonly variables is deprecated, and will be removed in 3.1. Use Given to define stubbed property return value.")
		set {	__p_apiBaseUrl = newValue }
	}
	private var __p_apiBaseUrl: (URL)?





    public required init(serverConfig: ServerConfigProtocol) { }

    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        addInvocation(.m_application__applicationdidFinishLaunchingWithOptions_launchOptions(Parameter<UIApplication>.value(`application`), Parameter<[UIApplication.LaunchOptionsKey: Any]?>.value(`launchOptions`)))
		let perform = methodPerformValue(.m_application__applicationdidFinishLaunchingWithOptions_launchOptions(Parameter<UIApplication>.value(`application`), Parameter<[UIApplication.LaunchOptionsKey: Any]?>.value(`launchOptions`))) as? (UIApplication, [UIApplication.LaunchOptionsKey: Any]?) -> Void
		perform?(`application`, `launchOptions`)
		var __value: Bool
		do {
		    __value = try methodReturnValue(.m_application__applicationdidFinishLaunchingWithOptions_launchOptions(Parameter<UIApplication>.value(`application`), Parameter<[UIApplication.LaunchOptionsKey: Any]?>.value(`launchOptions`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?). Use given")
			Failure("Stub return value not specified for application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?). Use given")
		}
		return __value
    }

    open func buildUrlRequest(resource: Resource) -> URLRequest {
        addInvocation(.m_buildUrlRequest__resource_resource(Parameter<Resource>.value(`resource`)))
		let perform = methodPerformValue(.m_buildUrlRequest__resource_resource(Parameter<Resource>.value(`resource`))) as? (Resource) -> Void
		perform?(`resource`)
		var __value: URLRequest
		do {
		    __value = try methodReturnValue(.m_buildUrlRequest__resource_resource(Parameter<Resource>.value(`resource`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for buildUrlRequest(resource: Resource). Use given")
			Failure("Stub return value not specified for buildUrlRequest(resource: Resource). Use given")
		}
		return __value
    }

    open func fetchData(request: URLRequest) -> SignalProducer<(Data, URLResponse), DataProviderError> {
        addInvocation(.m_fetchData__request_request(Parameter<URLRequest>.value(`request`)))
		let perform = methodPerformValue(.m_fetchData__request_request(Parameter<URLRequest>.value(`request`))) as? (URLRequest) -> Void
		perform?(`request`)
		var __value: SignalProducer<(Data, URLResponse), DataProviderError>
		do {
		    __value = try methodReturnValue(.m_fetchData__request_request(Parameter<URLRequest>.value(`request`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for fetchData(request: URLRequest). Use given")
			Failure("Stub return value not specified for fetchData(request: URLRequest). Use given")
		}
		return __value
    }


    fileprivate enum MethodType {
        case m_application__applicationdidFinishLaunchingWithOptions_launchOptions(Parameter<UIApplication>, Parameter<[UIApplication.LaunchOptionsKey: Any]?>)
        case m_buildUrlRequest__resource_resource(Parameter<Resource>)
        case m_fetchData__request_request(Parameter<URLRequest>)
        case p_serverConfig_get
        case p_apiBaseUrl_get

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Bool {
            switch (lhs, rhs) {
            case (.m_application__applicationdidFinishLaunchingWithOptions_launchOptions(let lhsApplication, let lhsLaunchoptions), .m_application__applicationdidFinishLaunchingWithOptions_launchOptions(let rhsApplication, let rhsLaunchoptions)):
                guard Parameter.compare(lhs: lhsApplication, rhs: rhsApplication, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsLaunchoptions, rhs: rhsLaunchoptions, with: matcher) else { return false } 
                return true 
            case (.m_buildUrlRequest__resource_resource(let lhsResource), .m_buildUrlRequest__resource_resource(let rhsResource)):
                guard Parameter.compare(lhs: lhsResource, rhs: rhsResource, with: matcher) else { return false } 
                return true 
            case (.m_fetchData__request_request(let lhsRequest), .m_fetchData__request_request(let rhsRequest)):
                guard Parameter.compare(lhs: lhsRequest, rhs: rhsRequest, with: matcher) else { return false } 
                return true 
            case (.p_serverConfig_get,.p_serverConfig_get): return true
            case (.p_apiBaseUrl_get,.p_apiBaseUrl_get): return true
            default: return false
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_application__applicationdidFinishLaunchingWithOptions_launchOptions(p0, p1): return p0.intValue + p1.intValue
            case let .m_buildUrlRequest__resource_resource(p0): return p0.intValue
            case let .m_fetchData__request_request(p0): return p0.intValue
            case .p_serverConfig_get: return 0
            case .p_apiBaseUrl_get: return 0
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }

        public static func serverConfig(getter defaultValue: ServerConfigProtocol...) -> PropertyStub {
            return Given(method: .p_serverConfig_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func apiBaseUrl(getter defaultValue: URL...) -> PropertyStub {
            return Given(method: .p_apiBaseUrl_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }

        public static func application(_ application: Parameter<UIApplication>, didFinishLaunchingWithOptions launchOptions: Parameter<[UIApplication.LaunchOptionsKey: Any]?>, willReturn: Bool...) -> MethodStub {
            return Given(method: .m_application__applicationdidFinishLaunchingWithOptions_launchOptions(`application`, `launchOptions`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func buildUrlRequest(resource: Parameter<Resource>, willReturn: URLRequest...) -> MethodStub {
            return Given(method: .m_buildUrlRequest__resource_resource(`resource`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func fetchData(request: Parameter<URLRequest>, willReturn: SignalProducer<(Data, URLResponse), DataProviderError>...) -> MethodStub {
            return Given(method: .m_fetchData__request_request(`request`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func application(_ application: Parameter<UIApplication>, didFinishLaunchingWithOptions launchOptions: Parameter<[UIApplication.LaunchOptionsKey: Any]?>, willProduce: (Stubber<Bool>) -> Void) -> MethodStub {
            let willReturn: [Bool] = []
			let given: Given = { return Given(method: .m_application__applicationdidFinishLaunchingWithOptions_launchOptions(`application`, `launchOptions`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (Bool).self)
			willProduce(stubber)
			return given
        }
        public static func buildUrlRequest(resource: Parameter<Resource>, willProduce: (Stubber<URLRequest>) -> Void) -> MethodStub {
            let willReturn: [URLRequest] = []
			let given: Given = { return Given(method: .m_buildUrlRequest__resource_resource(`resource`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (URLRequest).self)
			willProduce(stubber)
			return given
        }
        public static func fetchData(request: Parameter<URLRequest>, willProduce: (Stubber<SignalProducer<(Data, URLResponse), DataProviderError>>) -> Void) -> MethodStub {
            let willReturn: [SignalProducer<(Data, URLResponse), DataProviderError>] = []
			let given: Given = { return Given(method: .m_fetchData__request_request(`request`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (SignalProducer<(Data, URLResponse), DataProviderError>).self)
			willProduce(stubber)
			return given
        }
    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func application(_ application: Parameter<UIApplication>, didFinishLaunchingWithOptions launchOptions: Parameter<[UIApplication.LaunchOptionsKey: Any]?>) -> Verify { return Verify(method: .m_application__applicationdidFinishLaunchingWithOptions_launchOptions(`application`, `launchOptions`))}
        public static func buildUrlRequest(resource: Parameter<Resource>) -> Verify { return Verify(method: .m_buildUrlRequest__resource_resource(`resource`))}
        public static func fetchData(request: Parameter<URLRequest>) -> Verify { return Verify(method: .m_fetchData__request_request(`request`))}
        public static var serverConfig: Verify { return Verify(method: .p_serverConfig_get) }
        public static var apiBaseUrl: Verify { return Verify(method: .p_apiBaseUrl_get) }
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func application(_ application: Parameter<UIApplication>, didFinishLaunchingWithOptions launchOptions: Parameter<[UIApplication.LaunchOptionsKey: Any]?>, perform: @escaping (UIApplication, [UIApplication.LaunchOptionsKey: Any]?) -> Void) -> Perform {
            return Perform(method: .m_application__applicationdidFinishLaunchingWithOptions_launchOptions(`application`, `launchOptions`), performs: perform)
        }
        public static func buildUrlRequest(resource: Parameter<Resource>, perform: @escaping (Resource) -> Void) -> Perform {
            return Perform(method: .m_buildUrlRequest__resource_resource(`resource`), performs: perform)
        }
        public static func fetchData(request: Parameter<URLRequest>, perform: @escaping (URLRequest) -> Void) -> Perform {
            return Perform(method: .m_fetchData__request_request(`request`), performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let invocations = matchingCalls(method.method)
        MockyAssert(count.matches(invocations.count), "Expected: \(count) invocations of `\(method.method)`, but was: \(invocations.count)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        invocations.append(call)
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType) -> [MethodType] {
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher) }
    }
    private func matchingCalls(_ method: Verify) -> Int {
        return matchingCalls(method.method).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        #if Mocky
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleMissingStubError(message: message, file: file, line: line)
        #endif
    }
}

// MARK: - ConnectivityService
open class ConnectivityServiceMock: ConnectivityService, Mock {
    init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    public var status: MutableProperty<ConnectivityServiceStatus> {
		get {	invocations.append(.p_status_get); return __p_status ?? givenGetterValue(.p_status_get, "ConnectivityServiceMock - stub value for status was not defined") }
		@available(*, deprecated, message: "Using setters on readonly variables is deprecated, and will be removed in 3.1. Use Given to define stubbed property return value.")
		set {	__p_status = newValue }
	}
	private var __p_status: (MutableProperty<ConnectivityServiceStatus>)?

    public var isReachableProperty: MutableProperty<Bool> {
		get {	invocations.append(.p_isReachableProperty_get); return __p_isReachableProperty ?? givenGetterValue(.p_isReachableProperty_get, "ConnectivityServiceMock - stub value for isReachableProperty was not defined") }
		@available(*, deprecated, message: "Using setters on readonly variables is deprecated, and will be removed in 3.1. Use Given to define stubbed property return value.")
		set {	__p_isReachableProperty = newValue }
	}
	private var __p_isReachableProperty: (MutableProperty<Bool>)?





    open func performSingleConnectivityCheck() -> SignalProducer<ConnectivityServiceStatus, NoError> {
        addInvocation(.m_performSingleConnectivityCheck)
		let perform = methodPerformValue(.m_performSingleConnectivityCheck) as? () -> Void
		perform?()
		var __value: SignalProducer<ConnectivityServiceStatus, NoError>
		do {
		    __value = try methodReturnValue(.m_performSingleConnectivityCheck).casted()
		} catch {
			onFatalFailure("Stub return value not specified for performSingleConnectivityCheck(). Use given")
			Failure("Stub return value not specified for performSingleConnectivityCheck(). Use given")
		}
		return __value
    }


    fileprivate enum MethodType {
        case m_performSingleConnectivityCheck
        case p_status_get
        case p_isReachableProperty_get

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Bool {
            switch (lhs, rhs) {
            case (.m_performSingleConnectivityCheck, .m_performSingleConnectivityCheck):
                return true 
            case (.p_status_get,.p_status_get): return true
            case (.p_isReachableProperty_get,.p_isReachableProperty_get): return true
            default: return false
            }
        }

        func intValue() -> Int {
            switch self {
            case .m_performSingleConnectivityCheck: return 0
            case .p_status_get: return 0
            case .p_isReachableProperty_get: return 0
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }

        public static func status(getter defaultValue: MutableProperty<ConnectivityServiceStatus>...) -> PropertyStub {
            return Given(method: .p_status_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func isReachableProperty(getter defaultValue: MutableProperty<Bool>...) -> PropertyStub {
            return Given(method: .p_isReachableProperty_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }

        public static func performSingleConnectivityCheck(willReturn: SignalProducer<ConnectivityServiceStatus, NoError>...) -> MethodStub {
            return Given(method: .m_performSingleConnectivityCheck, products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func performSingleConnectivityCheck(willProduce: (Stubber<SignalProducer<ConnectivityServiceStatus, NoError>>) -> Void) -> MethodStub {
            let willReturn: [SignalProducer<ConnectivityServiceStatus, NoError>] = []
			let given: Given = { return Given(method: .m_performSingleConnectivityCheck, products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (SignalProducer<ConnectivityServiceStatus, NoError>).self)
			willProduce(stubber)
			return given
        }
    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func performSingleConnectivityCheck() -> Verify { return Verify(method: .m_performSingleConnectivityCheck)}
        public static var status: Verify { return Verify(method: .p_status_get) }
        public static var isReachableProperty: Verify { return Verify(method: .p_isReachableProperty_get) }
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func performSingleConnectivityCheck(perform: @escaping () -> Void) -> Perform {
            return Perform(method: .m_performSingleConnectivityCheck, performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let invocations = matchingCalls(method.method)
        MockyAssert(count.matches(invocations.count), "Expected: \(count) invocations of `\(method.method)`, but was: \(invocations.count)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        invocations.append(call)
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType) -> [MethodType] {
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher) }
    }
    private func matchingCalls(_ method: Verify) -> Int {
        return matchingCalls(method.method).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        #if Mocky
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleMissingStubError(message: message, file: file, line: line)
        #endif
    }
}

// MARK: - ITunesItemDetailsRouting
open class ITunesItemDetailsRoutingMock: ITunesItemDetailsRouting, Mock {
    init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }





    open func dismissScreen() {
        addInvocation(.m_dismissScreen)
		let perform = methodPerformValue(.m_dismissScreen) as? () -> Void
		perform?()
    }


    fileprivate enum MethodType {
        case m_dismissScreen

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Bool {
            switch (lhs, rhs) {
            case (.m_dismissScreen, .m_dismissScreen):
                return true 
            }
        }

        func intValue() -> Int {
            switch self {
            case .m_dismissScreen: return 0
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func dismissScreen() -> Verify { return Verify(method: .m_dismissScreen)}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func dismissScreen(perform: @escaping () -> Void) -> Perform {
            return Perform(method: .m_dismissScreen, performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let invocations = matchingCalls(method.method)
        MockyAssert(count.matches(invocations.count), "Expected: \(count) invocations of `\(method.method)`, but was: \(invocations.count)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        invocations.append(call)
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType) -> [MethodType] {
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher) }
    }
    private func matchingCalls(_ method: Verify) -> Int {
        return matchingCalls(method.method).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        #if Mocky
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleMissingStubError(message: message, file: file, line: line)
        #endif
    }
}

// MARK: - ITunesSearchListRouting
open class ITunesSearchListRoutingMock: ITunesSearchListRouting, Mock {
    init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }





    open func showTrack(id: Int64, action: @escaping (ITunesSearchListAction) -> Void) {
        addInvocation(.m_showTrack__id_idaction_action(Parameter<Int64>.value(`id`), Parameter<(ITunesSearchListAction) -> Void>.value(`action`)))
		let perform = methodPerformValue(.m_showTrack__id_idaction_action(Parameter<Int64>.value(`id`), Parameter<(ITunesSearchListAction) -> Void>.value(`action`))) as? (Int64, @escaping (ITunesSearchListAction) -> Void) -> Void
		perform?(`id`, `action`)
    }

    open func showAudioBook(id: Int64, action: @escaping (ITunesSearchListAction) -> Void) {
        addInvocation(.m_showAudioBook__id_idaction_action(Parameter<Int64>.value(`id`), Parameter<(ITunesSearchListAction) -> Void>.value(`action`)))
		let perform = methodPerformValue(.m_showAudioBook__id_idaction_action(Parameter<Int64>.value(`id`), Parameter<(ITunesSearchListAction) -> Void>.value(`action`))) as? (Int64, @escaping (ITunesSearchListAction) -> Void) -> Void
		perform?(`id`, `action`)
    }


    fileprivate enum MethodType {
        case m_showTrack__id_idaction_action(Parameter<Int64>, Parameter<(ITunesSearchListAction) -> Void>)
        case m_showAudioBook__id_idaction_action(Parameter<Int64>, Parameter<(ITunesSearchListAction) -> Void>)

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Bool {
            switch (lhs, rhs) {
            case (.m_showTrack__id_idaction_action(let lhsId, let lhsAction), .m_showTrack__id_idaction_action(let rhsId, let rhsAction)):
                guard Parameter.compare(lhs: lhsId, rhs: rhsId, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsAction, rhs: rhsAction, with: matcher) else { return false } 
                return true 
            case (.m_showAudioBook__id_idaction_action(let lhsId, let lhsAction), .m_showAudioBook__id_idaction_action(let rhsId, let rhsAction)):
                guard Parameter.compare(lhs: lhsId, rhs: rhsId, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsAction, rhs: rhsAction, with: matcher) else { return false } 
                return true 
            default: return false
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_showTrack__id_idaction_action(p0, p1): return p0.intValue + p1.intValue
            case let .m_showAudioBook__id_idaction_action(p0, p1): return p0.intValue + p1.intValue
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func showTrack(id: Parameter<Int64>, action: Parameter<(ITunesSearchListAction) -> Void>) -> Verify { return Verify(method: .m_showTrack__id_idaction_action(`id`, `action`))}
        public static func showAudioBook(id: Parameter<Int64>, action: Parameter<(ITunesSearchListAction) -> Void>) -> Verify { return Verify(method: .m_showAudioBook__id_idaction_action(`id`, `action`))}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func showTrack(id: Parameter<Int64>, action: Parameter<(ITunesSearchListAction) -> Void>, perform: @escaping (Int64, @escaping (ITunesSearchListAction) -> Void) -> Void) -> Perform {
            return Perform(method: .m_showTrack__id_idaction_action(`id`, `action`), performs: perform)
        }
        public static func showAudioBook(id: Parameter<Int64>, action: Parameter<(ITunesSearchListAction) -> Void>, perform: @escaping (Int64, @escaping (ITunesSearchListAction) -> Void) -> Void) -> Perform {
            return Perform(method: .m_showAudioBook__id_idaction_action(`id`, `action`), performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let invocations = matchingCalls(method.method)
        MockyAssert(count.matches(invocations.count), "Expected: \(count) invocations of `\(method.method)`, but was: \(invocations.count)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        invocations.append(call)
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType) -> [MethodType] {
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher) }
    }
    private func matchingCalls(_ method: Verify) -> Int {
        return matchingCalls(method.method).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        #if Mocky
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleMissingStubError(message: message, file: file, line: line)
        #endif
    }
}

// MARK: - PersistenceLayer
open class PersistenceLayerMock: PersistenceLayer, Mock {
    init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }





    open func fetchAudiobook(id: Int64) -> SignalProducer<[AudioBook], PersistenceLayerError> {
        addInvocation(.m_fetchAudiobook__id_id(Parameter<Int64>.value(`id`)))
		let perform = methodPerformValue(.m_fetchAudiobook__id_id(Parameter<Int64>.value(`id`))) as? (Int64) -> Void
		perform?(`id`)
		var __value: SignalProducer<[AudioBook], PersistenceLayerError>
		do {
		    __value = try methodReturnValue(.m_fetchAudiobook__id_id(Parameter<Int64>.value(`id`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for fetchAudiobook(id: Int64). Use given")
			Failure("Stub return value not specified for fetchAudiobook(id: Int64). Use given")
		}
		return __value
    }

    open func fetchAudiobooks(ids: [Int64]) -> SignalProducer<[AudioBook], PersistenceLayerError> {
        addInvocation(.m_fetchAudiobooks__ids_ids(Parameter<[Int64]>.value(`ids`)))
		let perform = methodPerformValue(.m_fetchAudiobooks__ids_ids(Parameter<[Int64]>.value(`ids`))) as? ([Int64]) -> Void
		perform?(`ids`)
		var __value: SignalProducer<[AudioBook], PersistenceLayerError>
		do {
		    __value = try methodReturnValue(.m_fetchAudiobooks__ids_ids(Parameter<[Int64]>.value(`ids`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for fetchAudiobooks(ids: [Int64]). Use given")
			Failure("Stub return value not specified for fetchAudiobooks(ids: [Int64]). Use given")
		}
		return __value
    }

    open func fetchTrack(id: Int64) -> SignalProducer<[Track], PersistenceLayerError> {
        addInvocation(.m_fetchTrack__id_id(Parameter<Int64>.value(`id`)))
		let perform = methodPerformValue(.m_fetchTrack__id_id(Parameter<Int64>.value(`id`))) as? (Int64) -> Void
		perform?(`id`)
		var __value: SignalProducer<[Track], PersistenceLayerError>
		do {
		    __value = try methodReturnValue(.m_fetchTrack__id_id(Parameter<Int64>.value(`id`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for fetchTrack(id: Int64). Use given")
			Failure("Stub return value not specified for fetchTrack(id: Int64). Use given")
		}
		return __value
    }

    open func fetchTracks(ids: [Int64]) -> SignalProducer<[Track], PersistenceLayerError> {
        addInvocation(.m_fetchTracks__ids_ids(Parameter<[Int64]>.value(`ids`)))
		let perform = methodPerformValue(.m_fetchTracks__ids_ids(Parameter<[Int64]>.value(`ids`))) as? ([Int64]) -> Void
		perform?(`ids`)
		var __value: SignalProducer<[Track], PersistenceLayerError>
		do {
		    __value = try methodReturnValue(.m_fetchTracks__ids_ids(Parameter<[Int64]>.value(`ids`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for fetchTracks(ids: [Int64]). Use given")
			Failure("Stub return value not specified for fetchTracks(ids: [Int64]). Use given")
		}
		return __value
    }

    open func fetchResource<T>(_ resource: Resource) -> SignalProducer<T, PersistenceLayerError> {
        addInvocation(.m_fetchResource__resource(Parameter<Resource>.value(`resource`)))
		let perform = methodPerformValue(.m_fetchResource__resource(Parameter<Resource>.value(`resource`))) as? (Resource) -> Void
		perform?(`resource`)
		var __value: SignalProducer<T, PersistenceLayerError>
		do {
		    __value = try methodReturnValue(.m_fetchResource__resource(Parameter<Resource>.value(`resource`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for fetchResource<T>(_ resource: Resource). Use given")
			Failure("Stub return value not specified for fetchResource<T>(_ resource: Resource). Use given")
		}
		return __value
    }

    open func removeResource(_ resource: Resource) -> SignalProducer<Bool, PersistenceLayerError> {
        addInvocation(.m_removeResource__resource(Parameter<Resource>.value(`resource`)))
		let perform = methodPerformValue(.m_removeResource__resource(Parameter<Resource>.value(`resource`))) as? (Resource) -> Void
		perform?(`resource`)
		var __value: SignalProducer<Bool, PersistenceLayerError>
		do {
		    __value = try methodReturnValue(.m_removeResource__resource(Parameter<Resource>.value(`resource`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for removeResource(_ resource: Resource). Use given")
			Failure("Stub return value not specified for removeResource(_ resource: Resource). Use given")
		}
		return __value
    }

    open func persistObjects<T>(_ objects: T, saveCompletion: @escaping PersistenceSaveCompletion) {
        addInvocation(.m_persistObjects__objectssaveCompletion_saveCompletion(Parameter<T>.value(`objects`).wrapAsGeneric(), Parameter<PersistenceSaveCompletion>.any))
		let perform = methodPerformValue(.m_persistObjects__objectssaveCompletion_saveCompletion(Parameter<T>.value(`objects`).wrapAsGeneric(), Parameter<PersistenceSaveCompletion>.any)) as? (T, @escaping PersistenceSaveCompletion) -> Void
		perform?(`objects`, `saveCompletion`)
    }


    fileprivate enum MethodType {
        case m_fetchAudiobook__id_id(Parameter<Int64>)
        case m_fetchAudiobooks__ids_ids(Parameter<[Int64]>)
        case m_fetchTrack__id_id(Parameter<Int64>)
        case m_fetchTracks__ids_ids(Parameter<[Int64]>)
        case m_fetchResource__resource(Parameter<Resource>)
        case m_removeResource__resource(Parameter<Resource>)
        case m_persistObjects__objectssaveCompletion_saveCompletion(Parameter<GenericAttribute>, Parameter<PersistenceSaveCompletion>)

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Bool {
            switch (lhs, rhs) {
            case (.m_fetchAudiobook__id_id(let lhsId), .m_fetchAudiobook__id_id(let rhsId)):
                guard Parameter.compare(lhs: lhsId, rhs: rhsId, with: matcher) else { return false } 
                return true 
            case (.m_fetchAudiobooks__ids_ids(let lhsIds), .m_fetchAudiobooks__ids_ids(let rhsIds)):
                guard Parameter.compare(lhs: lhsIds, rhs: rhsIds, with: matcher) else { return false } 
                return true 
            case (.m_fetchTrack__id_id(let lhsId), .m_fetchTrack__id_id(let rhsId)):
                guard Parameter.compare(lhs: lhsId, rhs: rhsId, with: matcher) else { return false } 
                return true 
            case (.m_fetchTracks__ids_ids(let lhsIds), .m_fetchTracks__ids_ids(let rhsIds)):
                guard Parameter.compare(lhs: lhsIds, rhs: rhsIds, with: matcher) else { return false } 
                return true 
            case (.m_fetchResource__resource(let lhsResource), .m_fetchResource__resource(let rhsResource)):
                guard Parameter.compare(lhs: lhsResource, rhs: rhsResource, with: matcher) else { return false } 
                return true 
            case (.m_removeResource__resource(let lhsResource), .m_removeResource__resource(let rhsResource)):
                guard Parameter.compare(lhs: lhsResource, rhs: rhsResource, with: matcher) else { return false } 
                return true 
            case (.m_persistObjects__objectssaveCompletion_saveCompletion(let lhsObjects, let lhsSavecompletion), .m_persistObjects__objectssaveCompletion_saveCompletion(let rhsObjects, let rhsSavecompletion)):
                guard Parameter.compare(lhs: lhsObjects, rhs: rhsObjects, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsSavecompletion, rhs: rhsSavecompletion, with: matcher) else { return false } 
                return true 
            default: return false
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_fetchAudiobook__id_id(p0): return p0.intValue
            case let .m_fetchAudiobooks__ids_ids(p0): return p0.intValue
            case let .m_fetchTrack__id_id(p0): return p0.intValue
            case let .m_fetchTracks__ids_ids(p0): return p0.intValue
            case let .m_fetchResource__resource(p0): return p0.intValue
            case let .m_removeResource__resource(p0): return p0.intValue
            case let .m_persistObjects__objectssaveCompletion_saveCompletion(p0, p1): return p0.intValue + p1.intValue
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


        public static func fetchAudiobook(id: Parameter<Int64>, willReturn: SignalProducer<[AudioBook], PersistenceLayerError>...) -> MethodStub {
            return Given(method: .m_fetchAudiobook__id_id(`id`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func fetchAudiobooks(ids: Parameter<[Int64]>, willReturn: SignalProducer<[AudioBook], PersistenceLayerError>...) -> MethodStub {
            return Given(method: .m_fetchAudiobooks__ids_ids(`ids`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func fetchTrack(id: Parameter<Int64>, willReturn: SignalProducer<[Track], PersistenceLayerError>...) -> MethodStub {
            return Given(method: .m_fetchTrack__id_id(`id`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func fetchTracks(ids: Parameter<[Int64]>, willReturn: SignalProducer<[Track], PersistenceLayerError>...) -> MethodStub {
            return Given(method: .m_fetchTracks__ids_ids(`ids`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func fetchResource<T>(_ resource: Parameter<Resource>, willReturn: SignalProducer<T, PersistenceLayerError>...) -> MethodStub {
            return Given(method: .m_fetchResource__resource(`resource`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func removeResource(_ resource: Parameter<Resource>, willReturn: SignalProducer<Bool, PersistenceLayerError>...) -> MethodStub {
            return Given(method: .m_removeResource__resource(`resource`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func fetchAudiobook(id: Parameter<Int64>, willProduce: (Stubber<SignalProducer<[AudioBook], PersistenceLayerError>>) -> Void) -> MethodStub {
            let willReturn: [SignalProducer<[AudioBook], PersistenceLayerError>] = []
			let given: Given = { return Given(method: .m_fetchAudiobook__id_id(`id`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (SignalProducer<[AudioBook], PersistenceLayerError>).self)
			willProduce(stubber)
			return given
        }
        public static func fetchAudiobooks(ids: Parameter<[Int64]>, willProduce: (Stubber<SignalProducer<[AudioBook], PersistenceLayerError>>) -> Void) -> MethodStub {
            let willReturn: [SignalProducer<[AudioBook], PersistenceLayerError>] = []
			let given: Given = { return Given(method: .m_fetchAudiobooks__ids_ids(`ids`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (SignalProducer<[AudioBook], PersistenceLayerError>).self)
			willProduce(stubber)
			return given
        }
        public static func fetchTrack(id: Parameter<Int64>, willProduce: (Stubber<SignalProducer<[Track], PersistenceLayerError>>) -> Void) -> MethodStub {
            let willReturn: [SignalProducer<[Track], PersistenceLayerError>] = []
			let given: Given = { return Given(method: .m_fetchTrack__id_id(`id`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (SignalProducer<[Track], PersistenceLayerError>).self)
			willProduce(stubber)
			return given
        }
        public static func fetchTracks(ids: Parameter<[Int64]>, willProduce: (Stubber<SignalProducer<[Track], PersistenceLayerError>>) -> Void) -> MethodStub {
            let willReturn: [SignalProducer<[Track], PersistenceLayerError>] = []
			let given: Given = { return Given(method: .m_fetchTracks__ids_ids(`ids`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (SignalProducer<[Track], PersistenceLayerError>).self)
			willProduce(stubber)
			return given
        }
        public static func fetchResource<T>(_ resource: Parameter<Resource>, willProduce: (Stubber<SignalProducer<T, PersistenceLayerError>>) -> Void) -> MethodStub {
            let willReturn: [SignalProducer<T, PersistenceLayerError>] = []
			let given: Given = { return Given(method: .m_fetchResource__resource(`resource`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (SignalProducer<T, PersistenceLayerError>).self)
			willProduce(stubber)
			return given
        }
        public static func removeResource(_ resource: Parameter<Resource>, willProduce: (Stubber<SignalProducer<Bool, PersistenceLayerError>>) -> Void) -> MethodStub {
            let willReturn: [SignalProducer<Bool, PersistenceLayerError>] = []
			let given: Given = { return Given(method: .m_removeResource__resource(`resource`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (SignalProducer<Bool, PersistenceLayerError>).self)
			willProduce(stubber)
			return given
        }
    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func fetchAudiobook(id: Parameter<Int64>) -> Verify { return Verify(method: .m_fetchAudiobook__id_id(`id`))}
        public static func fetchAudiobooks(ids: Parameter<[Int64]>) -> Verify { return Verify(method: .m_fetchAudiobooks__ids_ids(`ids`))}
        public static func fetchTrack(id: Parameter<Int64>) -> Verify { return Verify(method: .m_fetchTrack__id_id(`id`))}
        public static func fetchTracks(ids: Parameter<[Int64]>) -> Verify { return Verify(method: .m_fetchTracks__ids_ids(`ids`))}
        public static func fetchResource(_ resource: Parameter<Resource>) -> Verify { return Verify(method: .m_fetchResource__resource(`resource`))}
        public static func removeResource(_ resource: Parameter<Resource>) -> Verify { return Verify(method: .m_removeResource__resource(`resource`))}
        public static func persistObjects<T>(_ objects: Parameter<T>, saveCompletion: Parameter<PersistenceSaveCompletion>) -> Verify { return Verify(method: .m_persistObjects__objectssaveCompletion_saveCompletion(`objects`.wrapAsGeneric(), `saveCompletion`))}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func fetchAudiobook(id: Parameter<Int64>, perform: @escaping (Int64) -> Void) -> Perform {
            return Perform(method: .m_fetchAudiobook__id_id(`id`), performs: perform)
        }
        public static func fetchAudiobooks(ids: Parameter<[Int64]>, perform: @escaping ([Int64]) -> Void) -> Perform {
            return Perform(method: .m_fetchAudiobooks__ids_ids(`ids`), performs: perform)
        }
        public static func fetchTrack(id: Parameter<Int64>, perform: @escaping (Int64) -> Void) -> Perform {
            return Perform(method: .m_fetchTrack__id_id(`id`), performs: perform)
        }
        public static func fetchTracks(ids: Parameter<[Int64]>, perform: @escaping ([Int64]) -> Void) -> Perform {
            return Perform(method: .m_fetchTracks__ids_ids(`ids`), performs: perform)
        }
        public static func fetchResource(_ resource: Parameter<Resource>, perform: @escaping (Resource) -> Void) -> Perform {
            return Perform(method: .m_fetchResource__resource(`resource`), performs: perform)
        }
        public static func removeResource(_ resource: Parameter<Resource>, perform: @escaping (Resource) -> Void) -> Perform {
            return Perform(method: .m_removeResource__resource(`resource`), performs: perform)
        }
        public static func persistObjects<T>(_ objects: Parameter<T>, saveCompletion: Parameter<PersistenceSaveCompletion>, perform: @escaping (T, @escaping PersistenceSaveCompletion) -> Void) -> Perform {
            return Perform(method: .m_persistObjects__objectssaveCompletion_saveCompletion(`objects`.wrapAsGeneric(), `saveCompletion`), performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let invocations = matchingCalls(method.method)
        MockyAssert(count.matches(invocations.count), "Expected: \(count) invocations of `\(method.method)`, but was: \(invocations.count)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        invocations.append(call)
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType) -> [MethodType] {
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher) }
    }
    private func matchingCalls(_ method: Verify) -> Int {
        return matchingCalls(method.method).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        #if Mocky
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleMissingStubError(message: message, file: file, line: line)
        #endif
    }
}

