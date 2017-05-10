//
//  SubscriptionInformation.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import StoreKit

public protocol SubscriptionLoaderType: Resettable {
    var results: Result<[Subscription]>? { get }
    func start(completion: ((Result<[Subscription]>) -> Void)?)
}

public protocol HasSubscriptionType {
    var subscriptionLoader: SubscriptionLoaderType { get set }
}

public extension HasSubscriptionType {
    mutating func configure(with subscriptionLoader: SubscriptionLoaderType?) {
        if let subscriptionLoader = subscriptionLoader {
            self.subscriptionLoader = subscriptionLoader
        }
    }
}

public class SubscriptionLoader: NSObject, SubscriptionLoaderType, SKProductsRequestDelegate {
    
    private static let productIdentifiers: Set<String> = [PrivateKeys.kBasicSubscriptionProductKey, PrivateKeys.kProSubscriptionProductKey]
    
    private let request: SKProductsRequest
    
    private(set) public var results: Result<[Subscription]>?
    private(set) public var completion: ((Result<[Subscription]>) -> Void)?
    
    public override init() {
        self.request = SKProductsRequest(productIdentifiers: SubscriptionLoader.productIdentifiers)
        super.init()
        request.delegate = self
    }
    
    public func start(completion: ((Result<[Subscription]>) -> Void)?) {
        self.completion = completion
        self.results = nil
        self.request.start()
    }
    
    public func reset() {
        self.completion = nil
        self.results = nil
        self.request.cancel()
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        let result = Result<[Subscription]>.error(error)
        self.results = result
        completion?(result)
        self.completion = nil
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let subscriptions = Subscription.subscriptions(from: response.products)
        let result = Result.success(subscriptions)
        self.results = result
        completion?(result)
    }
}

internal extension Subscription {
    internal static func subscriptions(from products: [SKProduct]) -> [Subscription] {
        let subscriptions = products.flatMap() { product -> Subscription? in
            let level: Subscription.Level
            switch product.productIdentifier {
            case PrivateKeys.kBasicSubscriptionProductKey:
                level = .basic
            case PrivateKeys.kProSubscriptionProductKey:
                level = .pro
            default:
                assert(false, "Invalid ProductID Found: \(product.productIdentifier)")
                return nil
            }
            let subscription = Subscription(level: level,
                                            localizedTitle: product.localizedTitle,
                                            localizedDescription: product.localizedDescription,
                                            price: .paid(price: product.price.doubleValue, locale: product.priceLocale))
            return subscription
        }
        return subscriptions + [Subscription.free()]
    }
}
