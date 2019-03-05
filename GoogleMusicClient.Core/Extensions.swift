//
//  Extensions.swift
//  GoogleMusicClient.Core
//
//  Created by Anton Efimenko on 05/03/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Foundation
import RxDataFlow

public extension KeyedDecodingContainer {
    func decode<T: Decodable>(_ key: Key, as type: T.Type = T.self) throws -> T {
        return try self.decode(T.self, forKey: key)
    }
    
    func decodeIfPresent<T: Decodable>(_ key: KeyedDecodingContainer.Key) throws -> T? {
        return try decodeIfPresent(T.self, forKey: key)
    }
}

public extension RxActionType {
    func equalTo<T: RxActionType & Equatable>(_ value: T) -> Bool {
        guard let casted = self as? T else { return false }
        return casted == value
    }
}

public extension UserDefaults {
    var mainWindowFrame: WindowSize? {
        set {
            guard let size = newValue else {
                set(nil, forKey: "mainWindowFrame")
                return
            }
            let data = try? JSONEncoder().encode(size)
            set(data, forKey: "mainWindowFrame")
        }
        get {
            guard let data = self.data(forKey: "mainWindowFrame") else {
                return nil
            }
            return try? JSONDecoder().decode(WindowSize.self, from: data)
        }
    }
}

public extension TimeInterval {
    var timeString: String? {
        guard !isInfinite, !isNaN else { return nil }
        return String(format:"%02d:%02d", minute, second)
    }
    
    var minute: Int {
        return Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    
    var second: Int {
        return Int(truncatingRemainder(dividingBy: 60))
    }
}

public extension Int {
    var asNsDecimalNumber: NSDecimalNumber? {
        return NSDecimalNumber(value: self)
    }
}
