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
import GoogleMusicClient_Core

extension RxDataFlowController where State == AppState {
    var currentTrack: Observable<(track: GMusicTrack, queueIndex: Int, source: QueueSource)?> {
        return state.filter { result in
            switch result.setBy {
            case PlayerAction.playNext, PlayerAction.playPrevious, PlayerAction.playAtIndex: return true
            default: return false
            }
        }.map { $0.state.currentTrack }.startWith(currentState.state.currentTrack)
    }
    
    var currentRadio: Observable<(radio: GMusicRadioStation, index: Int)?> {
        return state.filter { result in
            switch result.setBy {
            case PlayerAction.setQueueSource(let s) where s.isRadio: return true
            default: return false
            }
            }.map { $0.state.currentRadio }.startWith(currentState.state.currentRadio)
    }
}

extension NSColor {
    static var textColor: NSColor { return NSColor.init(named: "TextColor")! }
    static var selectedItemTextColor: NSColor { return NSColor.init(named: "SelectedItemTextColor")! }
}

extension NSImage {
    static var pause: NSImage { return NSImage(imageLiteralResourceName: "Pause") }
    static var play: NSImage { return NSImage(imageLiteralResourceName: "Play") }
    static var album: NSImage { return NSImage(imageLiteralResourceName: "Album") }
    
    convenience init?(_ optionalData: Data?) {
        guard let data = optionalData else {
            return nil
        }
        self.init(data: data)
    }
}

extension NSCollectionView {
    func registerItem(forClass itemClass: AnyClass) {
        register(itemClass, forItemWithIdentifier: NSUserInterfaceItemIdentifier (String(describing: itemClass)))
    }
    
    func registerItem(classes: AnyClass...) {
        classes.forEach { registerItem(forClass: $0) }
    }
    
    func registerSupplementaryView(forClass viewClass: AnyClass, kind: String) {
        register(viewClass,
                 forSupplementaryViewOfKind: kind,
                 withIdentifier: NSUserInterfaceItemIdentifier (String(describing: viewClass)))
    }
    
    func registerHeader(forClass viewClass: AnyClass) {
        registerSupplementaryView(forClass: viewClass, kind: NSCollectionView.elementKindSectionHeader)
    }
    
    func makeItem<T>(for path: IndexPath) -> T {
        return makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: T.self)), for: path) as! T
    }
    
    func makeSupplementaryView<T>(for path: IndexPath, kind: String) -> T {
        return makeSupplementaryView(ofKind: kind,
                                     withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: T.self)),
                                     for: path) as! T
    }
    
    func makeHeader<T>(for path: IndexPath) -> T {
        return makeSupplementaryView(for: path, kind: NSCollectionView.elementKindSectionHeader)
    }
    
    func selectItem(index selectedIndex: Int?) {
        guard let index = selectedIndex else {
            deselectAllItems()
            return
        }
        
        deselectAllItems()
        selectItems(at: Set([IndexPath(item: index, section: 0)]),
                                   scrollPosition: NSCollectionView.ScrollPosition.left)
    }
    
    func scrollToTop() {
        guard numberOfSections > 0 else { return }
        guard numberOfItems(inSection: 0) > 0 else { return }
        
        scrollToItems(at: Set([IndexPath(item: 0, section: 0)]), scrollPosition: NSCollectionView.ScrollPosition.top)
    }
    
    func deselectAllItems() {
        let currentAllowsEmptySelection = allowsEmptySelection
        allowsEmptySelection = true
        deselectAll(self)
        allowsEmptySelection = currentAllowsEmptySelection
    }
}
