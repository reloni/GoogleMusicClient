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
            .do(onNext: { [weak self] in self?.backgroundImage.image = $0; self?.image.image = $0 })
            .do(onError: { [weak self] _ in self?.backgroundImage.image = NSImage.album; self?.image.image = NSImage.album })
            .subscribe()
    }
    
    override var title: String? {
        get { return titleLabel.stringValue }
        set { titleLabel.stringValue = newValue ?? "" }
    }
    
    override func loadView() {
        view = NSView()
        view.addSubview(backgroundImage)
        view.addSubview(image)

        view.addSubview(titleLabel)
        createConstraints()
    }
    
    func createConstraints() {
        backgroundImage.lt.top.equal(to: view.lt.top, constant: 5)
        backgroundImage.lt.leading.equal(to: view.lt.leading, constant: 5)
        backgroundImage.lt.trailing.equal(to: view.lt.trailing, constant: 5)
        
        image.lt.centerX.equal(to: backgroundImage.lt.centerX, constant: 0)
        image.lt.centerY.equal(to: backgroundImage.lt.centerY, constant: 0)
        
        image.lt.height.equal(to: image.lt.width)
        image.lt.leading.equal(to: backgroundImage.lt.leading)
        image.lt.trailing.equal(to: backgroundImage.lt.trailing)

        titleLabel.lt.top.equal(to: backgroundImage.lt.bottom, constant: 15)
        titleLabel.lt.leading.equal(to: backgroundImage.lt.leading)
        titleLabel.lt.trailing.equal(to: backgroundImage.lt.trailing)
        titleLabel.lt.bottom.equal(to: view.lt.bottom, constant: -5)
    }
}
