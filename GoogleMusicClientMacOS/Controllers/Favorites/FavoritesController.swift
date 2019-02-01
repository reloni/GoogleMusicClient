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

extension NSUserInterfaceItemIdentifier {
    static let collectionViewItem: NSUserInterfaceItemIdentifier = {
        return NSUserInterfaceItemIdentifier("NavCollectionViewCell")
    }()
}

final class FavoritesController: NSViewController {
    let collectionView = NSCollectionView().configure { view in
        view.backgroundColors = [.clear]
        view.collectionViewLayout = NSCollectionViewFlowLayout().configure {
            $0.minimumLineSpacing = 0
            $0.scrollDirection = .vertical
        }
        view.register(ThreeLabelsView.self, forSupplementaryViewOfKind: NSCollectionView.elementKindSectionHeader, withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Header"))
        view.register(CollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier ("CollectionViewItem"))
    }
    
    lazy var scrollView = NSScrollView().configure {
        $0.documentView = self.collectionView
    }
    
    let bag = DisposeBag()
    
    var player: Player<GMusicTrack>? {
        return Current.currentState.state.player
    }
    
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
            .do(onNext: { [weak self] _ in self?.collectionView.reloadSections(IndexSet(integer: 0)) })
            .subscribe()
            .disposed(by: bag)
        
        if favorites.count == 0 {
            let action = RxCompositeAction(UIAction.showProgressIndicator,
                                           PlayerAction.loadFavorites,
                                           UIAction.hideProgressIndicator,
                                           fallbackAction: UIAction.hideProgressIndicator)
            Current.dispatch(action)
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

extension FavoritesController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorites.count
    }

    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        if kind == NSCollectionView.elementKindSectionHeader {
            let view = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Header"), for: indexPath) as! ThreeLabelsView
            return view.configure {
                $0.first.textField.stringValue = "Title"
                $0.second.textField.stringValue = "Album"
                $0.third.textField.stringValue = "Artist"
            }
        } else if kind == NSCollectionView.elementKindSectionFooter {
            print("footer")
        }
        
        return NSView()
    }
    
    func collectionView(_ itemForRepresentedObjectAtcollectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem"), for: indexPath)
        guard let collectionViewItem = item as? CollectionViewItem else { return item }
        
        let track = favorites[indexPath.item]
        
        collectionViewItem.musicTrackView.first.textField.stringValue = track.title
        collectionViewItem.musicTrackView.second.textField.stringValue = track.album
        collectionViewItem.musicTrackView.third.textField.stringValue = track.artist
        
        return item
    }
}

