//
//  ApplicationSlider.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 17/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa
import AppKit

final class SliderCell: NSSliderCell {
    var shouldDrawKnob = false
    override func drawKnob() {
        if shouldDrawKnob {
            super.drawKnob()
        }
    }
}

final class ApplicationSlider: NSSlider {
    var sliderCell: SliderCell? {
        return cell as? SliderCell
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        postsBoundsChangedNotifications = true
        postsFrameChangedNotifications = true
        NotificationCenter.default.addObserver(self, selector: #selector(boundsChanged), name: NSView.boundsDidChangeNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(boundsChanged), name: NSView.frameDidChangeNotification, object: self)
    }
    
    func refreshTrackingArea() {
        for a in trackingAreas {
            removeTrackingArea(a)
        }
        
        let trackingArea = NSTrackingArea(rect:bounds,
                                          options: [NSTrackingArea.Options.activeInActiveApp,
                                                    NSTrackingArea.Options.mouseEnteredAndExited],
                                          owner: self,
                                          userInfo: nil)
        addTrackingArea(trackingArea)
    }
    
    @objc func boundsChanged() {
        refreshTrackingArea()
    }
    
    override func mouseExited(with event: NSEvent) {
        sliderCell?.shouldDrawKnob = false
        setNeedsDisplay(bounds)
    }
    
    override func mouseEntered(with event: NSEvent) {
        sliderCell?.shouldDrawKnob = true
        setNeedsDisplay(bounds)
    }
}
