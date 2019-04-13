//
//  RadioStationCollectionViewItem.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 09/03/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

private final class PlayPauseView: NSView {
    enum State {
        case hidden
        case play
        case pause
    }
    
    private let circle = NSVisualEffectView()
        |> mutate(^\NSVisualEffectView.blendingMode, .withinWindow)
        |> mutate(^\NSVisualEffectView.material, .appearanceBased)
    
    private let image = NSImageView()
        |> mutate(^\NSImageView.imageScaling, NSImageScaling.scaleProportionallyUpOrDown)
    
    override func layout() {
        super.layout()
        circle.layer?.cornerRadius = circle.bounds.height / 2
    }
    
    init() {
        super.init(frame: .zero)
        
        addSubviews(circle, image)
                
        circle.lt.edges(to: self)
        image.lt.edges(to: circle, constant: 5)
        
        setState(.hidden)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setState(_ value: State) {
        switch value {
        case .hidden: isHidden = true
        case .pause:
            isHidden = false
            image.image = NSImage.pauseFilled.tinted(tintColor: NSColor.onImagePlayPauseMainColor)
        case .play:
            isHidden = false
            image.image = NSImage.playFilled.tinted(tintColor: NSColor.onImagePlayPauseMainColor)
        }
    }
}

final class RadioStationCollectionViewItem: NSCollectionViewItem {
    let bag = DisposeBag()
    private let playPauseView = PlayPauseView()
    
    private let progressIndicator = NSProgressIndicator()
        |> mutate(^\NSProgressIndicator.style, .spinning)
    
    private let image = NSImageView()
        |> mutate(^\NSImageView.imageScaling, NSImageScaling.scaleProportionallyUpOrDown)
    
    private let titleLabel = baseLabel()
        |> mutate(^\NSTextField.font, ApplicationFont.semibold.value)
        |> mutate(^\NSTextField.alignment, NSTextAlignment.center)
        |> mutate { $0.setContentPriority(.hugging(1000, .vertical)) }
        |> mutate { $0.setContentPriority(.compression(1000, .vertical)) }
    
    override var title: String? {
        get { return titleLabel.stringValue }
        set { titleLabel.stringValue = newValue ?? "" }
    }
    
    private var selectableView: SelectableNSView { return view as! SelectableNSView }
    
    private var imageLoaderDisposable: Disposable? = nil
    
    private let isPlayingRelay = BehaviorRelay(value: false)
    private var isPlayingDisposable: Disposable? = nil
    
    override func prepareForReuse() {
        imageLoaderDisposable?.dispose()
        imageLoaderDisposable = nil
        isPlayingDisposable?.dispose()
        isPlayingDisposable = nil
    }
    
    func setImage(from loader: Observable<NSImage?>) {
        imageLoaderDisposable = loader
            .observeOn(MainScheduler.instance)
            .do(onSubscribe: { [weak self] in self?.toggleSpiner(animating: true); self?.updateImage(with: nil) })
            .do(onNext: { [weak self] in self?.updateImage(with: $0) })
            .do(onError: { [weak self] _ in self?.image.image = NSImage.album; })
            .do(onDispose: { [weak self] in self?.toggleSpiner(animating: false) })
            .subscribe()
    }
    
    func subscribeToIsPlaying(_ isPlaying: Observable<Bool>) {
       isPlayingDisposable = isPlaying.bind(to: isPlayingRelay)
    }
    
    func toggleSpiner(animating: Bool) {
        if animating {
            progressIndicator.startAnimation(nil)
            progressIndicator.isHidden = false
        } else {
            progressIndicator.stopAnimation(nil)
            progressIndicator.isHidden = true
        }
    }
    
    func updateImage(with image: NSImage?) {
        self.image.image = image
    }
    
    override func loadView() {
        view = SelectableNSView()
        view.addSubviews(image, titleLabel, progressIndicator, playPauseView)
        
        selectableView.drawHoverBackground = false
        selectableView.setupTrackingArea()

        selectableView.isSelectedChanged = { [weak self] _ in self?.togglePlayPauseIndicator() }
        selectableView.isHoveredChanged = { [weak self] _ in self?.togglePlayPauseIndicator() }
        isPlayingRelay
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.togglePlayPauseIndicator() })
            .subscribe()
            .disposed(by: bag)
        
        createConstraints()
    }

    override var isSelected: Bool {
        didSet {
            selectableView.isSelected = isSelected
        }
    }
    
    func togglePlayPauseIndicator() {
        switch (selectableView.isSelected, selectableView.isHovered, isPlayingRelay.value) {
        case (true, true, true): playPauseView.setState(.pause)
        case (true, true, false): playPauseView.setState(.play)
        case (true, false, true): playPauseView.setState(.play)
        case (true, _, false): playPauseView.setState(.pause)
        case (false, true, _): playPauseView.setState(.play)
        default: playPauseView.setState(.hidden)
        }
    }
    
    func createConstraints() {
        image.lt.top.equal(to: view.lt.top, constant: 5)
        image.lt.leading.equal(to: view.lt.leading, constant: 5)
        image.lt.trailing.equal(to: view.lt.trailing, constant: -5)
                
        progressIndicator.lt.edges(to: image, constant: 20)

        playPauseView.lt.top.equal(to: image.lt.top, constant: 10)
        playPauseView.lt.leading.equal(to: image.lt.leading, constant: 10)
        playPauseView.lt.width.equal(to: 30)
        playPauseView.lt.height.equal(to: 30)
        
        titleLabel.lt.top.equal(to: image.lt.bottom, constant: 10)
        titleLabel.lt.leading.equal(to: image.lt.leading)
        titleLabel.lt.trailing.equal(to: image.lt.trailing)
        titleLabel.lt.bottom.equal(to: view.lt.bottom, constant: -5)
    }
}
