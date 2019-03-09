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

func alignment(_ alignment: NSTextAlignment) -> (NSTextField) -> NSTextField {
    return { label in
        label.alignment = alignment
        return label
    }
}

let singleColumnCollectionViewLayout = NSCollectionViewFlowLayout().configure {
    $0.minimumLineSpacing = 0
    $0.scrollDirection = .vertical
}

let radioListCollectionViewLayout = NSCollectionViewFlowLayout().configure {
    $0.scrollDirection = .vertical
    $0.itemSize = NSSize(width: 200, height: 200)
}

func baseCollectionView() -> (NSCollectionView) -> NSCollectionView {
    return { collection in
        collection.backgroundColors = [.clear]
        collection.allowsMultipleSelection = false
        collection.isSelectable = true
        collection.allowsEmptySelection = false
        return collection
    }
}

func layout(_ value: NSCollectionViewLayout) -> (NSCollectionView) -> NSCollectionView {
    return { $0.collectionViewLayout = value; return $0 }
}

func register(item: AnyClass) -> (NSCollectionView) -> NSCollectionView {
    return { collection in
        collection.registerItem(forClass: item)
        return collection
    }
}

func register(items: AnyClass...) -> (NSCollectionView) -> NSCollectionView {
    return { collection in
        items.forEach { collection.registerItem(forClass: $0) }
        return collection
    }
}

func register(header: AnyClass) -> (NSCollectionView) -> NSCollectionView {
    return { collection in
        collection.registerHeader(forClass: header)
        return collection
    }
}
