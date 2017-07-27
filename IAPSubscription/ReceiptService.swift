//
//  WebRecorderService.swift
//  WebRecorder
//
//  Created by cong on 6/26/17.
//  Copyright © 2017 cong. All rights reserved.
//

import UIKit


public enum Result<T> {
    case failure(ReceiptServiceError)
    case success(T)
}

public typealias UploadReceiptCompletion = (_ result: Result<(sessionId: String, currentSubscription: PaidSubscription?)>) -> Void

public typealias SessionId = String

public enum ReceiptServiceError: Error {
    case missingAccountSecret
    case invalidSession
    case noActiveSubscription
    case other(Error)
}

class ReceiptService {
    
    public static let shared = ReceiptService()
    
    private var sessions = [SessionId: Session]()
    
    /// Trade receipt for session id
    public func upload(receipt data: Data, completion: @escaping UploadReceiptCompletion) {
        let body = [
            "receipt-data": data.base64EncodedString(),
            "password": AppConfig.Purchase.itcAccountSecret
        ]
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        let url = URL(string: AppConfig.verifyReceiptLink)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
            if let error = error {
                completion(.failure(.other(error)))
            } else if let responseData = responseData {
                let json = try! JSONSerialization.jsonObject(with: responseData, options: []) as! Dictionary<String, Any>
                print(json)
                let session = Session(receiptData: data, parsedReceipt: json)
                self.sessions[session.id] = session
                let result = (sessionId: session.id, currentSubscription: session.currentSubscription)
                completion(.success(result))
            }
        }
        
        task.resume()
    }

}
