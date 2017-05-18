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

public protocol HasSubscriptionLoaderType {
    var subscriptionLoader: SubscriptionLoaderType { get set }
}

public extension HasSubscriptionLoaderType {
    mutating func configure(with subscriptionLoader: SubscriptionLoaderType?) {
        if let subscriptionLoader = subscriptionLoader {
            self.subscriptionLoader = subscriptionLoader
        }
    }
}

public class SubscriptionLoader: NSObject, SubscriptionLoaderType, SKProductsRequestDelegate {
    
    private static let productIdentifiers: Set<String> = [
        PrivateKeys.kSubscriptionProYearly,
        PrivateKeys.kSubscriptionProMonthly,
        PrivateKeys.kSubscriptionBasicYearly,
        PrivateKeys.kSubscriptionBasicMonthly
    ]
    
    private let request: SKProductsRequest
    
    private(set) public var results: Result<[Subscription]>?
    private(set) public var completion: ((Result<[Subscription]>) -> Void)?
    
    public override init() {
        self.request = SKProductsRequest(productIdentifiers: SubscriptionLoader.productIdentifiers)
        super.init()
        request.delegate = self
    }
    
    public func start(completion: ((Result<[Subscription]>) -> Void)?) {
        if let existingResults = self.results {
            completion?(existingResults)
        } else {
            self.completion = completion
            self.request.start()
        }
    }
    
    public func reset() {
        self.completion = nil
        self.results = nil
        self.request.cancel()
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        let result = Result<[Subscription]>.error(error)
        self.results = result
        self.completion?(result)
        self.completion = nil
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        var subscriptions = Subscription.subscriptions(from: response.products)
        subscriptions.sort(by: { $0.0.price < $0.1.price })
        let result = Result.success(subscriptions)
        self.results = result
        completion?(result)
    }
}
