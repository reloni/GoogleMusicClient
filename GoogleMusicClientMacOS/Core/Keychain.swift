//
//  Keychain.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 13/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Security
import Foundation

protocol KeychainType: class {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
    var expiresIn: Int { get set }
}

extension Keychain {
    convenience init() {
        self.init(service: "GoogleMusicClient")
    }
}

extension Keychain: KeychainType {
    var accessToken: String? {
        get { return self.stringForAccount(account: "accessToken") }
        set { self.setString(string: newValue, forAccount: "accessToken") }
    }
    
    var refreshToken: String? {
        get { return self.stringForAccount(account: "refreshToken") }
        set { self.setString(string: newValue, forAccount: "refreshToken") }
    }
    
    var expiresIn: Int {
        get { return Int(stringForAccount(account: "expiresIn") ?? "") ?? 0 }
        set { self.setString(string: String(newValue), forAccount: "expiresIn") }
    }
}

enum KeychainError: Error {
    case Unimplemented
    case Param
    case Allocate
    case NotAvailable
    case AuthFailed
    case DuplicateItem
    case ItemNotFound
    case InteractionNotAllowed
    case Decode
    case Unknown
    
    /// Returns the appropriate error for the status, or nil if it
    /// was successful, or Unknown for a code that doesn't match.
    static func errorFromOSStatus(rawStatus: OSStatus) ->
        KeychainError? {
            if rawStatus == errSecSuccess {
                return nil
            } else {
                // If the mapping doesn't find a match, return unknown.
                return mapping[rawStatus] ?? .Unknown
            }
    }
    
    static let mapping: [Int32: KeychainError] = [
        errSecUnimplemented: .Unimplemented,
        errSecParam: .Param,
        errSecAllocate: .Allocate,
        errSecNotAvailable: .NotAvailable,
        errSecAuthFailed: .AuthFailed,
        errSecDuplicateItem: .DuplicateItem,
        errSecItemNotFound: .ItemNotFound,
        errSecInteractionNotAllowed: .InteractionNotAllowed,
        errSecDecode: .Decode
    ]
}

struct SecItemWrapper {
    static func matching(query: [String: AnyObject]) throws -> AnyObject? {
        var rawResult: AnyObject?
        let rawStatus = SecItemCopyMatching(query as CFDictionary, &rawResult)
        // Immediately take the retained value, so it won't leak
        // in case it needs to throw.
        
        if let error = KeychainError.errorFromOSStatus(rawStatus: rawStatus) {
            throw error
        }
        
        return rawResult
    }
    
    static func add(attributes: [String: AnyObject]) throws -> AnyObject? {
        var rawResult: AnyObject?
        let rawStatus = SecItemAdd(attributes as CFDictionary, &rawResult)
        
        if let error = KeychainError.errorFromOSStatus(rawStatus: rawStatus) {
            throw error
        }
        
        return rawResult
    }
    
    static func update(query: [String: AnyObject],
                       attributesToUpdate: [String: AnyObject]) throws {
        let rawStatus = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        if let error = KeychainError.errorFromOSStatus(rawStatus: rawStatus) {
            throw error
        }
    }
    static func delete(query: [String: AnyObject]) throws {
        let rawStatus = SecItemDelete(query as CFDictionary)
        if let error = KeychainError.errorFromOSStatus(rawStatus: rawStatus) {
            throw error
        }
    }
}

class Keychain {
    let service: String
    init(service: String) {
        self.service = service
    }
    
    func deleteAccount(account: String) {
        do {
            try SecItemWrapper.delete(query: [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service as AnyObject,
                kSecAttrAccount as String: account as AnyObject,
                kSecAttrSynchronizable as String: kSecAttrSynchronizableAny,
                ])
        } catch KeychainError.ItemNotFound {
            // Ignore this error.
        } catch let error {
            NSLog("keychain deleteAccount error: \(error)")
        }
    }
    
    func dataForAccount(account: String) -> Data? {
        do {
            let query = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service as AnyObject,
                kSecAttrAccount as String: account as AnyObject,
                kSecAttrSynchronizable as String: kSecAttrSynchronizableAny,
                kSecReturnData as String: kCFBooleanTrue as CFTypeRef,
                ] as [String : AnyObject]
            let result = try SecItemWrapper.matching(query: query)
            return result as? Data
        } catch KeychainError.ItemNotFound {
            // Ignore this error, simply return nil.
            return nil
        } catch let error {
            NSLog("keychain dataForAccount error: \(error)")
            return nil
        }
    }
    
    func stringForAccount(account: String) -> String? {
        if let data = dataForAccount(account: account) {
            return NSString(data: data,
                            encoding: String.Encoding.utf8.rawValue) as String?
        } else {
            return nil
        }
    }
    
    func setData(data: Data,
                 forAccount account: String,
                 synchronizable: Bool,
                 background: Bool) {
        do {
            // Remove the item if it already exists.
            // This saves having to deal with SecItemUpdate.
            // Reasonable people may disagree with this approach.
            deleteAccount(account: account)
            
            // Add it.
            _ = try SecItemWrapper.add(attributes: [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service as AnyObject,
                kSecAttrAccount as String: account as AnyObject,
                kSecAttrSynchronizable as String: synchronizable ? kCFBooleanTrue : kCFBooleanFalse,
                kSecValueData as String: data as AnyObject,
                kSecAttrAccessible as String: background ? kSecAttrAccessibleAlwaysThisDeviceOnly : kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
                ])
        } catch let error {
            NSLog("keychain setData error: \(error)")
        }
    }
    
    func setString(string: String?,
                   forAccount account: String,
                   synchronizable: Bool = false,
                   background: Bool = true) {
        if let string = string {
            let data = string.data(using: String.Encoding.utf8)!
            setData(data: data,
                    forAccount: account,
                    synchronizable: synchronizable,
                    background: background)
        } else {
            deleteAccount(account: account)
        }
    }
}
