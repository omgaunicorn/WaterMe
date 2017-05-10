//
//  SubscriptionInformation.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeData
import StoreKit

protocol Resettable {
    func reset()
}

protocol SubscriptionLoaderType: Resettable {
    var results: Result<[Subscription]>? { get }
    func start(completion: ((Result<[Subscription]>) -> Void)?)
    
}

protocol HasSubscriptionType {
    var subscriptionLoader: SubscriptionLoaderType { get set }
}

extension HasSubscriptionType {
    mutating func configure(with subscriptionLoader: SubscriptionLoaderType?) {
        if let subscriptionLoader = subscriptionLoader {
            self.subscriptionLoader = subscriptionLoader
        }
    }
}

class SubscriptionLoader: NSObject, SubscriptionLoaderType, SKProductsRequestDelegate {
    
    private static let productIdentifiers: Set<String> = [PrivateKeys.kBasicSubscriptionProductKey, PrivateKeys.kProSubscriptionProductKey]
    
    private let request: SKProductsRequest
    
    private(set) var results: Result<[Subscription]>?
    private var completion: ((Result<[Subscription]>) -> Void)?
    
    override init() {
        self.request = SKProductsRequest(productIdentifiers: SubscriptionLoader.productIdentifiers)
        super.init()
        request.delegate = self
    }
    
    func start(completion: ((Result<[Subscription]>) -> Void)?) {
        self.completion = completion
        self.results = nil
        self.request.start()
    }
    
    func reset() {
        self.completion = nil
        self.results = nil
        self.request.cancel()
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        let result = Result<[Subscription]>.error(error)
        self.results = result
        completion?(result)
        self.completion = nil
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let subscriptions = response.products.flatMap() { product -> Subscription? in
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
        let freeSubscription = Subscription(level: .free,
                                            localizedTitle: "Free",
                                            localizedDescription: "• Unlimited number of plants\n• Unlimited number of reminders",
                                            price: .free)
        
        let result = Result.success(subscriptions + [freeSubscription])
        self.results = result
        completion?(result)
    }
}
