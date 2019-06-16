//
//  AlbumPreviewController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 16/06/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxGoogleMusic
import RxSwift
import RxDataFlow
import GoogleMusicClientCore

final class AlbumPreviewController: NSViewController {
    let bag = DisposeBag()
    let image = NSImageView()
    
    static let textField = { (placeholder: String) in
        return baseLabel()
            |> mutate(^\NSTextField.alignment, NSTextAlignment.center)
            |> mutate(^\NSTextField.placeholderString, placeholder)
            |> mutate(^\NSTextField.lineBreakMode, .byWordWrapping)
            |> mutate(^\NSTextField.usesSingleLineMode, false)
    }
    
    lazy var stack = NSStackView()
        |> mutate(^\NSStackView.distribution, .fill)
        |> mutate(^\NSStackView.orientation, .vertical)
        |> mutate(^\NSStackView.spacing, 5)
        |> mutate { $0.addArrangedSubview(self.albumTitle) }
        |> mutate { $0.addArrangedSubview(self.artistName) }
        |> mutate { $0.addArrangedSubview(self.trackTitle) }
        
    let albumTitle = textField("Album title")
    let artistName = textField("Artist name")
    let trackTitle = textField("Track title")
    
    override func loadView() {
        view = NSView()
            |> mutate { $0.addSubviews(self.image, self.stack) }

        makeConstraints()
    }
    
    func makeConstraints() {
        image.lt.height.equal(to: 250)
        image.lt.width.equal(to: 250)
        image.lt.top.equal(to: view.lt.top, constant: 10)
        image.lt.leading.equal(to: view.lt.leading, constant: 10)
        image.lt.trailing.equal(to: view.lt.trailing, constant: -10)

        stack.lt.top.equal(to: image.lt.bottom, constant: 10)
        stack.lt.leading.equal(to: image.lt.leading)
        stack.lt.trailing.equal(to: image.lt.trailing)
        stack.lt.bottom.equal(to: view.lt.bottom, constant: -10)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Current.currentTrackImage
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak image] in image?.image = $0 })
            .disposed(by: bag)
        
        Current.currentTrack
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.setTrackInfo($0?.track) })
            .disposed(by: bag)
    }
    
    func setTrackInfo(_ track: GMusicTrack?) {
        albumTitle.stringValue = track?.album ?? ""
        artistName.stringValue = track?.artist ?? ""
        trackTitle.stringValue = track?.title ?? ""
    }
}
