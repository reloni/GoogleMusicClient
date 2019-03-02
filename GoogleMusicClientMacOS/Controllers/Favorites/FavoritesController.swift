//
//  FavoritesController.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 29/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Cocoa
import RxSwift
import RxGoogleMusic
import RxDataFlow

final class FavoritesController: NSViewController {
    let collectionView = NSCollectionView()
        |> baseCollectionView()
        |> layout(singleColumnCollectionViewLayout)
        |> register(item: MusicTrackCollectionViewItem.self)
        |> register(header: MusicTrackView.self)
    
    lazy var scrollView = NSScrollView().configure { $0.documentView = self.collectionView }
    
    let bag = DisposeBag()

    var favorites: [GMusicTrack] {
        return Current.currentState.state.favorites.all()
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
        
        Current.state
            .filter(isSetBy(PlayerAction.loadFavorites))
            .observeOn(MainScheduler.instance)
            .do(onNext: { [weak collectionView] _ in collectionView?.reloadSections(IndexSet(integer: 0)) })
            .subscribe()
            .disposed(by: bag)
        
        Current.currentTrack
            .filter { $0?.source.isFavorites == true }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak collectionView] in collectionView?.selectItem(index: $0?.source.list?.indexOfOptioal($0?.track)) })
            .disposed(by: bag)
        
        if favorites.count == 0 {
            let action = RxCompositeAction(UIAction.showProgressIndicator,
                                           PlayerAction.loadFavorites,
                                           UIAction.hideProgressIndicator,
                                           fallbackAction: UIAction.hideProgressIndicator)
            Current.dispatch(action)
        }
        
        if Current.currentState.state.queueSource?.isFavorites != true {
            collectionView.deselectAll(self)
        }
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        collectionView.collectionViewLayout?.invalidateLayout()
    }
    
    deinit {
        print("FavoritesController deinit")
    }
}

extension FavoritesController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSSize(width: collectionView.bounds.width, height: 30)
    }
}

extension FavoritesController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let index = indexPaths.first?.item else { return }
        if Current.currentState.state.queueSource?.isFavorites == true {
            Current.dispatch(PlayerAction.playAtIndex(index))
        } else {
//            Current.dispatch(CompositeActions.play(tracks: favorites, startIndex: index))
            Current.dispatch(CompositeActions.playShuffled(tracks: favorites, startIndex: index))
        }
    }
}

extension FavoritesController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorites.count
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
        let track = favorites[indexPath.item]
        
        item.musicTrackView.title.textField.stringValue = track.title
        item.musicTrackView.album.textField.stringValue = track.album
        item.musicTrackView.artist.textField.stringValue = track.artist
        item.musicTrackView.duration.textField.stringValue = track.duration.timeString ?? "--:--"
        
        return item
    }
}

