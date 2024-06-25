//
//  CloudCache.swift
//  Know Maps
//
//  Created by Michael A Edgcumbe on 11/28/23.
//

import Foundation
import CloudKit

public enum CloudCacheError : Error {
    case ThrottleRequests
    case ServerErrorMessage
    case ServiceNotFound
}

open class CloudCache : NSObject, ObservableObject {
    @Published var hasPrivateCloudAccess:Bool = false
    @Published var isFetchingCachedRecords:Bool = false
    @Published public var queuedGroups = Set<String>()
    let keysContainer = CKContainer(identifier:"iCloud.com.noisederived.Tula.Cache")
    static let shopifyWebAddressString = "tula.house"
    private var serviceAPIKey:String = ""
    
    public enum CloudCacheService : String {
        case shopifyStorefront
    }
    
    
    public func fetch(url:URL, from cloudService:CloudCacheService) async throws -> Any {
        let configuredSession = try await session(service: cloudService.rawValue)
        return try await fetch(url: url, apiKey: serviceAPIKey, session: configuredSession)
    }

    internal func fetch(url:URL, apiKey:String, session:URLSession) async throws -> Any {
        print("Requesting URL: \(url)")
        var request = URLRequest(url:url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        let responseAny:Any = try await withCheckedThrowingContinuation({checkedContinuation in
            let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
                if let e = error {
                    print(e)
                    checkedContinuation.resume(throwing:e)
                } else {
                    if let d = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: d, options: [.fragmentsAllowed])
                            checkedContinuation.resume(returning:json)
                        } catch {
                            print(error)
                            let returnedString = String(data: d, encoding: String.Encoding.utf8) ?? ""
                            print(returnedString)
                            checkedContinuation.resume(throwing: CloudCacheError.ServerErrorMessage)
                        }
                    }
                }
            })
            
            dataTask.resume()
        })
        
        return responseAny
    }
    
    
    internal func session(service:String) async throws -> URLSession {
            let predicate = NSPredicate(format: "service == %@", service)
            let query = CKQuery(recordType: "KeyString", predicate: predicate)
            let operation = CKQueryOperation(query: query)
            operation.desiredKeys = ["value", "service"]
            operation.resultsLimit = 1
            operation.recordMatchedBlock = { [weak self] recordId, result in
                guard let strongSelf = self else { return }

                do {
                    let record = try result.get()
                    if let apiKey = record["value"] as? String {
                        print("\(String(describing: record["service"]))")
                        strongSelf.serviceAPIKey = apiKey
                    } else {
                        print("Did not find API Key")
                    }
                } catch {
                    print(error)
                }
            }
            
            operation.queuePriority = .veryHigh
            operation.qualityOfService = .userInitiated
        
        
        let success = try await withCheckedThrowingContinuation { checkedContinuation in
            operation.queryResultBlock = { result in
                
                switch result {
                case .success(_):
                    checkedContinuation.resume(with: .success(true))
                case .failure(let error):
                    print(error)
                    checkedContinuation.resume(with: .success(false))
                }
            }
            
            keysContainer.publicCloudDatabase.add(operation)
        }
        
        if success {
            return defaultSession()
        } else {
            throw CloudCacheError.ServiceNotFound
        }
    }
    
    
    public func apiKey(for service:CloudCacheService) async throws -> String {
        let predicate = NSPredicate(format: "service == %@", service.rawValue)
            let query = CKQuery(recordType: "KeyString", predicate: predicate)
            let operation = CKQueryOperation(query: query)
            operation.desiredKeys = ["value", "service"]
            operation.resultsLimit = 1
            operation.recordMatchedBlock = { [weak self] recordId, result in
                guard let strongSelf = self else { return }

                do {
                    let record = try result.get()
                    if let apiKey = record["value"] as? String {
                        print("\(String(describing: record["service"]))")
                        strongSelf.serviceAPIKey = apiKey
                    } else {
                        print("Did not find API Key")
                    }
                } catch {
                    print(error)
                }
            }
            
            operation.queuePriority = .veryHigh
            operation.qualityOfService = .userInitiated
        
        
        let success = try await withCheckedThrowingContinuation { checkedContinuation in
            operation.queryResultBlock = { result in
                
                switch result {
                case .success(_):
                    checkedContinuation.resume(with: .success(true))
                case .failure(let error):
                    print(error)
                    checkedContinuation.resume(with: .success(false))
                }
            }
            
            keysContainer.publicCloudDatabase.add(operation)
        }
        
        if success {
            return serviceAPIKey
        } else {
            throw CloudCacheError.ServiceNotFound
        }
    }
    
    
    /*
    public func fetchCloudKitUserRecordID() async throws -> CKRecord.ID?{
        
        let userRecord:CKRecord.ID? = try await withCheckedThrowingContinuation { checkedContinuation in
            cacheContainer.fetchUserRecordID { recordId, error in
                if let e = error {
                    checkedContinuation.resume(throwing: e)
                } else if let record = recordId {
                    checkedContinuation.resume(returning: record)
                } else {
                    checkedContinuation.resume(returning: nil)
                }
            }
        }
        return userRecord
    }
    */

}


private extension CloudCache {
    func defaultSession()->URLSession {
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration)
        return session
    }
}
