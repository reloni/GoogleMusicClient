//
//  ApplicationSlider.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 17/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa
import AppKit
import RxSwift

final class SliderCell: NSSliderCell {
    var shouldDrawKnob = false

    override func drawKnob() {
        if shouldDrawKnob {
            super.drawKnob()
        }
    }
}

final class ApplicationSlider: NSSlider {
    override var trackingAreaOptions: NSTrackingArea.Options {
        get { return [NSTrackingArea.Options.activeInActiveApp, NSTrackingArea.Options.mouseEnteredAndExited] }
        set { }
    }
    
    var sliderCell: SliderCell? {
        return cell as? SliderCell
    }
    
    var isUserInteracting: Bool = false
    
    private let userSetValueSubject = PublishSubject<Double>()
    var userSetValue: Observable<Double> {
        return userSetValueSubject.asObservable().share(replay: 1, scope: .whileConnected)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupTrackingArea()
        
        target = self
        action = #selector(valueChaged)
    }
    
    @objc func valueChaged() {
        let event = NSApplication.shared.currentEvent
        
        let leftMouseDown = event?.type == NSEvent.EventType.leftMouseDown
        if leftMouseDown {
            isUserInteracting = true
            return
        }
        
        let leftMouseUp = event?.type == NSEvent.EventType.leftMouseUp
        if leftMouseUp {
            userSetValueSubject.onNext(cell?.doubleValue ?? 0)
            isUserInteracting = false
            return
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        sliderCell?.shouldDrawKnob = false
        setNeedsDisplay(bounds)
    }
    
    override func mouseEntered(with event: NSEvent) {
        guard isEnabled else { return }
        sliderCell?.shouldDrawKnob = true
        setNeedsDisplay(bounds)
    }
}
