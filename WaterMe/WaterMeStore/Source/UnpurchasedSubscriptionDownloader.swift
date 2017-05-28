//
//  SubscriptionInformation.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import Result
import StoreKit

public typealias UnpurchasedSubscriptionDownloadResult = Result<[UnpurchasedSubscription], AnyError>

public protocol UnpurchasedSubscriptionDownloaderType: Resettable {
    var results: UnpurchasedSubscriptionDownloadResult? { get }
    func start(completion: ((UnpurchasedSubscriptionDownloadResult) -> Void)?)
}

public protocol HasUnpurchasedSubscriptionDownloaderType {
    var subscriptionLoader: UnpurchasedSubscriptionDownloaderType { get set }
}

public extension HasUnpurchasedSubscriptionDownloaderType {
    mutating func configure(with subscriptionLoader: UnpurchasedSubscriptionDownloaderType?) {
        if let subscriptionLoader = subscriptionLoader {
            self.subscriptionLoader = subscriptionLoader
        }
    }
}

public class UnpurchasedSubscriptionDownloader: NSObject, UnpurchasedSubscriptionDownloaderType, SKProductsRequestDelegate {
    
    private static let productIdentifiers: Set<String> = [
        PrivateKeys.kSubscriptionProYearly,
        PrivateKeys.kSubscriptionProMonthly,
        PrivateKeys.kSubscriptionBasicYearly,
        PrivateKeys.kSubscriptionBasicMonthly
    ]
    
    private let request: SKProductsRequest
    
    private(set) public var results: UnpurchasedSubscriptionDownloadResult?
    private(set) public var completion: ((UnpurchasedSubscriptionDownloadResult) -> Void)?
    
    public override init() {
        self.request = SKProductsRequest(productIdentifiers: UnpurchasedSubscriptionDownloader.productIdentifiers)
        super.init()
        request.delegate = self
    }
    
    public func start(completion: ((UnpurchasedSubscriptionDownloadResult) -> Void)?) {
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
        let result = UnpurchasedSubscriptionDownloadResult.failure(AnyError(error))
        self.results = result
        self.completion?(result)
        self.completion = nil
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        var subscriptions = UnpurchasedSubscription.subscriptions(from: response.products)
        subscriptions.sort(by: { $0.0.price < $0.1.price })
        let result = UnpurchasedSubscriptionDownloadResult.success(subscriptions)
        self.results = result
        completion?(result)
    }
}
