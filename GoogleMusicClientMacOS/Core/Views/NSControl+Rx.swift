//
//  NSControl+Rx.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 23/04/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

extension Reactive where Base: NSControl {
    var clicked: ControlEvent<NSEvent> {
        let source = self.methodInvoked(#selector(Base.mouseDown)).map { $0.first as! NSEvent }.takeUntil(self.deallocated).share()
        return ControlEvent(events: source)
    }
    
    var mouseEntered: ControlEvent<NSEvent> {
        self.base.setupTrackingArea()
        let source = self.methodInvoked(#selector(Base.mouseEntered)).map { $0.first as! NSEvent }.takeUntil(self.deallocated).share()
        return ControlEvent(events: source)
    }
    
    var mouseExited: ControlEvent<NSEvent> {
        self.base.setupTrackingArea()
        let source = self.methodInvoked(#selector(Base.mouseExited)).map { $0.first as! NSEvent }.takeUntil(self.deallocated).share()
        return ControlEvent(events: source)
    }
}
