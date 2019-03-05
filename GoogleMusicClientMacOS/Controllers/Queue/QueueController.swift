//
//  QueueController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 28/12/2018.
//  Copyright © 2018 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxGoogleMusic
import RxSwift
import GoogleMusicClient_Core

final class QueueController: NSViewController {
    let collectionView = NSCollectionView()
        |> baseCollectionView()
        |> layout(singleColumnCollectionViewLayout)
        |> register(item: MusicTrackCollectionViewItem.self)
        |> register(header: MusicTrackView.self)
    
    lazy var scrollView = NSScrollView().configure { $0.documentView = self.collectionView; $0.hasHorizontalScroller = false }
    
    let bag = DisposeBag()
    
    var queue: [GMusicTrack] {
        return Current.currentState.state.queue.items
    }
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = NSView()
        view.addSubview(scrollView)
        scrollView.lt.edges(to: view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        Current.currentTrack
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak collectionView] in collectionView?.selectItem(index: $0?.queueIndex) })
            .disposed(by: bag)
        
        Current.state
            .filter(isSetBy(PlayerAction.initializeQueueFromSource))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak collectionView] _ in
                collectionView?.scrollToTop()
                collectionView?.reloadData()
            })
            .disposed(by: bag)
        
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        collectionView.collectionViewLayout?.invalidateLayout()
    }
    
    deinit {
        print("QueueController deinit")
    }
}

extension QueueController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSSize(width: collectionView.bounds.width, height: 30)
    }
}

extension QueueController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let index = indexPaths.first?.item else { return }
        Current.dispatch(PlayerAction.playAtIndex(index))
    }
}

extension QueueController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return queue.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        if kind == NSCollectionView.elementKindSectionHeader {
            let view: MusicTrackView = collectionView.makeHeader(for: indexPath)
            return view.configure {
                $0.title.textField.stringValue = "Title"
                $0.album.textField.stringValue = "Album"
                $0.artist.textField.stringValue = "Artist"
                $0.duration.textField.stringValue = "Duration"
            }
        }
        
        return NSView()
    }
    
    func collectionView(_ itemForRepresentedObjectAtcollectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item: MusicTrackCollectionViewItem = collectionView.makeItem(for: indexPath)
        let track = queue[indexPath.item]
        
        item.musicTrackView.title.textField.stringValue = track.title
        item.musicTrackView.album.textField.stringValue = track.album
        item.musicTrackView.artist.textField.stringValue = track.artist
        item.musicTrackView.duration.textField.stringValue = track.duration.timeString ?? "--:--"
        
        return item
    }
}

