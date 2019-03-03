//
//  UserDefaultsType.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 26/02/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Foundation

protocol UserDefaultsType: class {
    var isRepeatQueueEnabled: Bool { get set }
    var isShuffleEnabled: Bool { get set }
}

extension UserDefaults: UserDefaultsType {
    var isRepeatQueueEnabled: Bool {
        get { return bool(forKey: "isRepeatQueueEnabled") }
        set { set(newValue, forKey: "isRepeatQueueEnabled") }
    }
    
    var isShuffleEnabled: Bool {
        get { return bool(forKey: "isShuffleEnabled") }
        set { set(newValue, forKey: "isShuffleEnabled") }
    }
}
