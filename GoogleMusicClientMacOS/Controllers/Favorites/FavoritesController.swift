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
    let collectionView: NSCollectionView = {
        let view = NSCollectionView()
        view.backgroundColors = [.clear]
        view.collectionViewLayout = NSCollectionViewFlowLayout().configure {
            $0.minimumLineSpacing = 0
            $0.scrollDirection = .vertical
        }
        view.register(CollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier ("CollectionViewItem"))
        return view
    }()
    
    lazy var scrollView: NSScrollView = {
        let scroll = NSScrollView()
        scroll.documentView = self.collectionView
        return scroll
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let bag = DisposeBag()
    
    var player: Player<GMusicTrack>? {
        return Current.currentState.state.player
    }
    
    var favorites: [GMusicTrack] {
        return Current.currentState.state.favorites
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
}

extension FavoritesController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 500
    }
    
    func collectionView(_ itemForRepresentedObjectAtcollectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem"), for: indexPath)
        guard let collectionViewItem = item as? CollectionViewItem else { return item }
        
        collectionViewItem.trackTitle.textField.stringValue = "Title"
        collectionViewItem.album.textField.stringValue = "Album"
        collectionViewItem.artist.textField.stringValue = "Artist"
        return item
    }
    
}

