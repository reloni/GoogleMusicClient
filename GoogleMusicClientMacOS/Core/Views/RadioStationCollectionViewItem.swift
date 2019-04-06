//
//  RadioStationCollectionViewItem.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 09/03/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxSwift

final class RadioStationCollectionViewItem: NSCollectionViewItem {
    private let playPauseCircle = NSView()
        |> mutate(^\NSView.isHidden, true)
        |> mutate(^\NSView.wantsLayer, true)
        |> mutate(^?\NSView.layer!.backgroundColor, NSColor.white.cgColor)
        |> mutate(^\NSView.layer!.masksToBounds, true)
    
    private let playPauseImage = NSImageView()
        |> mutate(^\NSImageView.imageScaling, NSImageScaling.scaleProportionallyUpOrDown)
    
    private let progressIndicator = NSProgressIndicator()
        |> mutate(^\NSProgressIndicator.style, .spinning)
    
    private let image = NSImageView()
        |> mutate(^\NSImageView.imageScaling, NSImageScaling.scaleProportionallyUpOrDown)
    
    private let backgroundImage = NSImageView()
        |> mutate(^\NSImageView.imageScaling, NSImageScaling.scaleNone)
        |> addBlur(radius: 20.0)
    
    private let titleLabel = baseLabel()
        |> mutate(^\NSTextField.font, ApplicationFont.semibold.value)
        |> mutate(^\NSTextField.alignment, NSTextAlignment.center)
        |> mutate { $0.setContentPriority(.hugging(1000, .vertical)) }
        |> mutate { $0.setContentPriority(.compression(1000, .vertical)) }
    
    private var imageLoader: Disposable? = nil
    
    override func prepareForReuse() {
        imageLoader?.dispose()
        imageLoader = nil
    }
    
    func setImage(from loader: Observable<NSImage?>) {
        imageLoader = loader
            .observeOn(MainScheduler.instance)
            .do(onSubscribe: { [weak self] in self?.toggleSpiner(animating: true); self?.updateImages(with: nil) })
            .do(onNext: { [weak self] in self?.backgroundImage.image = $0; self?.image.image = $0 })
            .do(onError: { [weak self] _ in self?.backgroundImage.image = NSImage.album; self?.image.image = NSImage.album; })
            .do(onDispose: { [weak self] in self?.toggleSpiner(animating: false) })
            .subscribe()
    }
    
    override var title: String? {
        get { return titleLabel.stringValue }
        set { titleLabel.stringValue = newValue ?? "" }
    }
    
    private var selectableView: SelectableNSView { return view as! SelectableNSView }
    
    func toggleSpiner(animating: Bool) {
        if animating {
            progressIndicator.startAnimation(nil)
            progressIndicator.isHidden = false
        } else {
            progressIndicator.stopAnimation(nil)
            progressIndicator.isHidden = true
        }
    }
    
    func updateImages(with image: NSImage?) {
        self.image.image = image
        self.backgroundImage.image = image
    }
    
    override func loadView() {
        view = SelectableNSView()
        view.addSubviews(backgroundImage, image, titleLabel, progressIndicator, playPauseCircle, playPauseImage)
        
        selectableView.drawHoverBackground = false
        selectableView.setupTrackingArea()
        selectableView.isSelectedChanged = { isSelected in
            print("isSelected: \(isSelected)")
        }
        selectableView.isHoveredChanged = { [weak self] isHovered in
            print("isHovered: \(isHovered)")
            self?.toggleIsHovered(isHovered)
        }
        
        createConstraints()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        playPauseCircle.layer?.cornerRadius = playPauseCircle.bounds.height / 2
    }
    
    override var isSelected: Bool {
        didSet {
            selectableView.isSelected = isSelected
        }
    }
    
    func toggleIsHovered(_ isHovered: Bool) {
        playPauseCircle.isHidden = !isHovered
        playPauseImage.image = isHovered ? NSImage.play.tinted(tintColor: NSColor.black) : nil
    }
    
    func createConstraints() {
        backgroundImage.lt.top.equal(to: view.lt.top, constant: 5)
        backgroundImage.lt.leading.equal(to: view.lt.leading, constant: 5)
        backgroundImage.lt.trailing.equal(to: view.lt.trailing, constant: 5)
        
        progressIndicator.lt.edges(to: backgroundImage, constant: 20)

        playPauseCircle.lt.top.equal(to: backgroundImage.lt.top, constant: 10)
        playPauseCircle.lt.leading.equal(to: backgroundImage.lt.leading, constant: 10)
        playPauseCircle.lt.width.equal(to: 30)
        playPauseCircle.lt.height.equal(to: 30)
        
        playPauseImage.lt.edges(to: playPauseCircle)
        
        image.lt.top.equal(to: backgroundImage.lt.top)
        image.lt.leading.equal(to: backgroundImage.lt.leading)
        image.lt.trailing.equal(to: backgroundImage.lt.trailing)
        image.lt.bottom.equal(to: backgroundImage.lt.bottom)
        
        titleLabel.lt.top.equal(to: backgroundImage.lt.bottom, constant: 15)
        titleLabel.lt.leading.equal(to: backgroundImage.lt.leading)
        titleLabel.lt.trailing.equal(to: backgroundImage.lt.trailing)
        titleLabel.lt.bottom.equal(to: view.lt.bottom, constant: -5)
    }
}
