//
//  Support.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 01/02/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Foundation
import RxDataFlow

public protocol Configure { }

public extension Configure where Self: AnyObject {
    func configure(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: Configure { }

public enum WindowSize: Codable {
    case fullScreen
    case rect(NSRect)
    
    enum CodingKeys: String, CodingKey {
        case type
        case width
        case height
        case x
        case y
    }
    
    public init(from decoder: Decoder) throws {
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
    
    public func encode(to encoder: Encoder) throws {
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

public func isSetBy<Action: RxActionType & Equatable, State: RxStateType>(_ action: Action) -> ((setBy: RxActionType, state: State)) -> Bool {
    return { value in
        return value.setBy.equalTo(action)
    }
}

public func id<T>(_ value: T) -> T {
    return value
}
