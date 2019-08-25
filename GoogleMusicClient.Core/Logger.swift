//
//  Logger.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 22/08/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Foundation
import os.log

public extension OSLog {
    static let dispatchAction = OSLog(subsystem: "\(Bundle.main.bundleIdentifier!)", category: "DispatchAction")
    static let general = OSLog(subsystem: "\(Bundle.main.bundleIdentifier!)", category: "General")
    static let player = OSLog(subsystem: "\(Bundle.main.bundleIdentifier!)", category: "Player")
}
