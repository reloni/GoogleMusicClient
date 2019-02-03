//
//  Styles.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 01/02/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa

enum ApplicationFont {
    case regular
    case semibold
    case bold

    var value: NSFont {
        switch self {
        case .regular: return NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: NSFont.Weight.regular)
        case .bold: return NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: NSFont.Weight.bold)
        case .semibold: return NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: NSFont.Weight.semibold)
        }
    }
}

func baseLabel() -> (NSTextField) -> NSTextField {
    return { label in
        label.isEditable = false
        label.isBezeled = false
        label.drawsBackground = true
        label.backgroundColor = NSColor.clear
        label.usesSingleLineMode = true
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }
}

func font(_ font: ApplicationFont) -> (NSTextField) -> NSTextField {
    return { label in
        label.font = font.value
        return label
    }
}
