//
//  Extensions.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 26/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Foundation
import Cocoa
import RxDataFlow
import RxSwift
import RxGoogleMusic

extension RxDataFlowController where State == AppState {
    var currentTrack: Observable<(track: GMusicTrack, index: Int)?> {
        return state.filter { result in
            switch result.setBy {
            case PlayerAction.playNext, PlayerAction.playPrevious, PlayerAction.playAtIndex: return true
            default: return false
            }
        }.map { $0.state.currentTrack }.startWith(currentState.state.currentTrack)
    }
}

enum WindowSize: Codable {
    case fullScreen
    case rect(NSRect)
    
    enum CodingKeys: String, CodingKey {
        case type
        case width
        case height
        case x
        case y
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "fullScreen": self = .fullScreen
        case "rect":
            let width: CGFloat = try container.decode(.width)
            let height: CGFloat = try container.decode(.height)
            let x: CGFloat = try container.decode(.x)
            let y: CGFloat = try container.decode(.y)
            self = .rect(NSRect(x: x, y: y, width: width, height: height))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unable to deserialize WindowSize")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .fullScreen:
            try container.encode("fullScreen", forKey: .type)
        case .rect(let rect):
            try container.encode("rect", forKey: .type)
            try container.encode(rect.height, forKey: .height)
            try container.encode(rect.width, forKey: .width)
            try container.encode(rect.origin.x, forKey: .x)
            try container.encode(rect.origin.y, forKey: .y)
        }
    }
}

extension UserDefaults {
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

extension TimeInterval {
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

extension Int {
    var asNsDecimalNumber: NSDecimalNumber? {
        return NSDecimalNumber(value: self)
    }
}

extension NSImage {
    static var pause: NSImage { return NSImage(imageLiteralResourceName: "Pause") }
    static var play: NSImage { return NSImage(imageLiteralResourceName: "Play") }
}
