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
    let collectionView = NSCollectionView().configure { view in
        view.backgroundColors = [.clear]
        view.allowsMultipleSelection = false
        view.isSelectable = true
        view.collectionViewLayout = NSCollectionViewFlowLayout().configure {
            $0.minimumLineSpacing = 0
            $0.scrollDirection = .vertical
        }
        view.registerItem(forClass: ThreeLabelsCollectionViewItem.self)
        view.registerHeader(forClass: ThreeLabelsView.self)
    }
    
    lazy var scrollView = NSScrollView().configure { $0.documentView = self.collectionView }
    
    let bag = DisposeBag()

    var favorites: [GMusicTrack] {
        return Current.currentState.state.favorites
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
        
        Current.state.filter { state in
            switch state.setBy {
            case PlayerAction.loadFavorites: return true
            default: return false
            }
            }.observeOn(MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.collectionView.reloadSections(IndexSet(integer: 0))
            })
            .subscribe()
            .disposed(by: bag)
        
        Current.currentTrack
            .filter { $0?.source.isFavorites == true }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.updateCollectionView(selectedIndex: $0?.index) })
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
    
    func updateCollectionView(selectedIndex: Int?) {
        guard let index = selectedIndex else {
            collectionView.deselectAll(self)
            return
        }
        
        collectionView.deselectAll(self)
        collectionView.selectItems(at: Set([IndexPath(item: index, section: 0)]),
                                   scrollPosition: NSCollectionView.ScrollPosition.bottom)
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
            Current.dispatch(CompositeActions.play(tracks: favorites, startIndex: index))
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
            let view: ThreeLabelsView = collectionView.makeHeader(for: indexPath)
            return view.configure {
                $0.first.textField.stringValue = "Title"
                $0.second.textField.stringValue = "Album"
                $0.third.textField.stringValue = "Artist"
            }
        }
        
        return NSView()
    }
    
    func collectionView(_ itemForRepresentedObjectAtcollectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item: ThreeLabelsCollectionViewItem = collectionView.makeItem(for: indexPath)
        let track = favorites[indexPath.item]
        
        item.musicTrackView.first.textField.stringValue = track.title
        item.musicTrackView.second.textField.stringValue = track.album
        item.musicTrackView.third.textField.stringValue = track.artist
        
        return item
    }
}

