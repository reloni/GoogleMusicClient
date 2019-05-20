//
//  UserDefaultsType.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 26/02/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Foundation

public protocol UserDefaultsType: class {
    var isRepeatQueueEnabled: Bool { get set }
    var isShuffleEnabled: Bool { get set }
    var deviceId: UUID { get set }
}

extension UserDefaults: UserDefaultsType {
    public var isRepeatQueueEnabled: Bool {
        get { return bool(forKey: "isRepeatQueueEnabled") }
        set { set(newValue, forKey: "isRepeatQueueEnabled") }
    }
    
    public var isShuffleEnabled: Bool {
        get { return bool(forKey: "isShuffleEnabled") }
        set { set(newValue, forKey: "isShuffleEnabled") }
    }
    
    public var deviceId: UUID {
        get {
            guard let uuidString = string(forKey: "deviceId") else {
                let newUuid = UUID()
                set(newUuid.uuidString, forKey: "deviceId")
                return newUuid
            }
            return UUID(uuidString: uuidString)!
            
        }
        set { set(newValue.uuidString, forKey: "deviceId") }
    }
}
