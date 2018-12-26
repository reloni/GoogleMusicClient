//
//  Extensions.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 26/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import Cocoa

extension Double {
    var timeString: String? {
        guard !isInfinite, !isNaN else { return nil }
        
        let int = Int(self)
        let minutes = int / 60
        let seconds = int - (minutes * 60)
        
        guard let date = Calendar.current.date(from: DateComponents(minute: minutes, second: seconds)) else { return nil }
        
        return Global.trackTimeFormatter.string(from: date)
    }
}

extension Int {
    var asNsDecimalNumber: NSDecimalNumber? {
        return NSDecimalNumber(value: self)
    }
}

extension NSImage {
    static var pause: NSImage { return NSImage(imageLiteralResourceName: "Pause") }
    static var play: NSImage { return NSImage(imageLiteralResourceName: "Play") }
}
