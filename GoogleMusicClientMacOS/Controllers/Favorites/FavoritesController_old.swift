//
//  FavoritesController_old.swift
//  GoogleMusicClientMacOS
//
//  Created by Anton Efimenko on 31/01/2019.
//  Copyright © 2019 Anton Efimenko. All rights reserved.
//

import Foundation

final class FavoritesController: NSViewController {
    //    @IBOutlet weak var tableView: ApplicationTableView!
    @IBOutlet weak var collectionView: NSCollectionView!
    
    let bag = DisposeBag()
    
    var player: Player<GMusicTrack>? {
        return Current.currentState.state.player
    }
    
    var favorites: [GMusicTrack] {
        return Current.currentState.state.favorites
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(CollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier ("CollectionViewItem"))
        collectionView.delegate = self
        collectionView.dataSource = self
        
        configureCollectionView()
    }
    
    func configureCollectionView() {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .vertical
        collectionView.collectionViewLayout = flowLayout
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
        return NSSize(width: collectionView.bounds.width - 20, height: 25)
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
        
        collectionViewItem.titleLabel.stringValue = "ololo"
        return item
    }
    
}
