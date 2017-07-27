/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import StoreKit
import SystemConfiguration

func isInternetAvailable() -> Bool
{
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
        return false
    }
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    return (isReachable && !needsConnection)
}

func checkInterConnection(controller: UIViewController) -> Bool{
    guard isInternetAvailable() else {
        let alert = UIAlertController(title: "Error!!!", message: "Mobie network is not available. Please check your internet connection and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        controller.present(alert, animated: true, completion: nil)
        
        return false
    }
    return true
}

open class SubscriptionService: NSObject {
  
  static let sessionIdSetNotification = Notification.Name("SubscriptionServiceSessionIdSetNotification")
  static let optionsLoadedNotification = Notification.Name("SubscriptionServiceOptionsLoadedNotification")
  static let restoreSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
  static let purchaseSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
    static let purchaseFailedNotification = Notification.Name("SubscriptionServiceFailedNotification")
  
  
  static let shared = SubscriptionService()
  
  var hasReceiptData: Bool {
    return loadReceipt() != nil
  }
  

  
  var options: [Subscription]? {
    didSet {
      NotificationCenter.default.post(name: SubscriptionService.optionsLoadedNotification, object: options)
    }
  }
  
  func loadSubscriptionOptions() {
    
    let productIDs = Set([AppConfig.Purchase.trialProductId, AppConfig.Purchase.upgradeProductId])
    
    let request = SKProductsRequest(productIdentifiers: productIDs)
    request.delegate = self
    request.start()
  }
  
  func purchase(subscription: Subscription) {
    
    let payment = SKPayment(product: subscription.product)
    SKPaymentQueue.default().add(payment)
  }
  
  func restorePurchases() {
    
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
  
  func receiptValidation(completion: ((_ success: Bool) -> Void)? = nil) {
 
    if let receiptData = loadReceipt() {
        if isInternetAvailable() {
            ReceiptService.shared.upload(receipt: receiptData) { (result) in
                switch result {
                case .success(let result):
                    if let expireDate = result.currentSubscription?.expiresDate {
                        UserDefaults.purchasedExpiresDate = expireDate
                    }else {
                        UserDefaults.purchasedExpiresDate = nil
                    }
                    completion?(true)
                case .failure(let error):
                    print("🚫 Receipt Upload Failed: \(error)")
                    UserDefaults.purchasedExpiresDate = nil
                    completion?(false)
                    
                }
            }
        }else {
            completion?(false)
            
        }
        
    }else {
        completion?(false)
    }
      
  }
    
    func purchasedValidation() -> Bool {
        guard self.hasReceiptData, let expiresDate = UserDefaults.purchasedExpiresDate else {
            return false
        }
        return expiresDate > Date()
    }
  
  private func loadReceipt() -> Data? {
    guard let url = Bundle.main.appStoreReceiptURL else {
      return nil
    }
    
    do {
      let data = try Data(contentsOf: url)
      return data
    } catch {
      print("Error loading receipt data: \(error.localizedDescription)")
      return nil
    }
  }
}

// MARK: - SKProductsRequestDelegate

extension SubscriptionService: SKProductsRequestDelegate {
  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    options = response.products.map { Subscription(product: $0) }
  }
  
  public func request(_ request: SKRequest, didFailWithError error: Error) {
    if request is SKProductsRequest {
      print("Subscription Options Failed Loading: \(error.localizedDescription)")
    }
  }
}
