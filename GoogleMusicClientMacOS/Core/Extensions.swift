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
    var currentTrack: Observable<(track: GMusicTrack, index: Int, source: QueueSource)?> {
        return state.filter { result in
            switch result.setBy {
            case PlayerAction.playNext, PlayerAction.playPrevious, PlayerAction.playAtIndex: return true
            default: return false
            }
        }.map { $0.state.currentTrack }.startWith(currentState.state.currentTrack)
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
}
