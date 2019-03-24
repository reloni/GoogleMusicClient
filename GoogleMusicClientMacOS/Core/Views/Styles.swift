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

let baseLabel = {
    return NSTextField()
        |> mutate(^\.isEditable, false)
        |> mutate(^\.isBezeled, false)
        |> mutate(^\.drawsBackground, true)
        |> mutate(^\.usesSingleLineMode, true)
        |> mutate(^\NSTextField.backgroundColor, NSColor.clear)
        |> mutate(^\.lineBreakMode, NSLineBreakMode.byTruncatingTail)
}

let singleColumnCollectionViewLayout = NSCollectionViewFlowLayout().configure {
    $0.minimumLineSpacing = 0
    $0.scrollDirection = .vertical
}

let radioListCollectionViewLayout = NSCollectionViewFlowLayout().configure {
    $0.scrollDirection = .vertical
    $0.itemSize = NSSize(width: 220, height: 150)
    $0.sectionInset = NSEdgeInsets(top: 10, left: 20, bottom: 10, right: 30)
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

func addBlur<T: NSView>(radius: Double) -> (inout T) -> Void {
    return { view in
        guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return }
        
        let blurView = NSView(frame: .zero)
        blurView.wantsLayer = true
        blurView.layer?.backgroundColor = NSColor.clear.cgColor
        blurView.layer?.masksToBounds = true
        blurView.layerUsesCoreImageFilters = true
        blurView.layer?.needsDisplayOnBoundsChange = true
        
        blurFilter.setDefaults()
        
        blurFilter.setValue(NSNumber(value: radius), forKey: "inputRadius")
        blurView.layer?.backgroundFilters = [blurFilter]
        view.addSubview(blurView)
        
        blurView.lt.edges(to: view)
    }
}
