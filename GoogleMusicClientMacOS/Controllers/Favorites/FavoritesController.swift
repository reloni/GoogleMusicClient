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
        let nib = NSNib (nibNamed: "CollectionViewItem", bundle: nil)!
        collectionView.register (nib, forItemWithIdentifier: NSUserInterfaceItemIdentifier ("CollectionViewItem"))
//        collectionView.delegate = self
        collectionView.dataSource = self
        
        configureCollectionView()
//
//        Current.state.filter { state in
//            switch state.setBy {
//            case PlayerAction.loadFavorites: return true
//            default: return false
//            }
//            }.observeOn(MainScheduler.instance)
//            .do(onNext: { [weak self] _ in self?.tableView.reloadData() })
//            .subscribe()
//            .disposed(by: bag)
//
//        if favorites.count == 0 {
//            let action = RxCompositeAction(UIAction.showProgressIndicator,
//                                           PlayerAction.loadFavorites,
//                                           UIAction.hideProgressIndicator,
//                                           fallbackAction: UIAction.hideProgressIndicator)
//            Current.dispatch(action)
//        }
    }
    
    func configureCollectionView() {
        // 1
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        collectionView.collectionViewLayout = flowLayout
        // 2
        view.wantsLayer = true
        // 3
        collectionView.layer?.backgroundColor = NSColor.black.cgColor
    }
    
    deinit {
        print("FavoritesController deinit")
    }
}

extension FavoritesController : NSCollectionViewDataSource {
    
    // 1
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    // 2
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    // 3
    func collectionView(_ itemForRepresentedObjectAtcollectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        // 4
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem"), for: indexPath)
        guard let collectionViewItem = item as? CollectionViewItem else {return item}
        
        // 5
//        let imageFile = imageDirectoryLoader.imageFileForIndexPath(indexPath)
//        collectionViewItem.imageFile = imageFile
        collectionViewItem.label.stringValue = "ololo"
        return item
    }
    
}

//extension FavoritesController: NSTableViewDataSource {
//    func numberOfRows(in tableView: NSTableView) -> Int {
//        return favorites.count
//    }
//}
//
//extension FavoritesController: NSTableViewDelegate {
//    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        let c = cell(in: tableView, for: tableColumn)
//        switch c?.identifier?.rawValue {
//        case "Title": c?.textField?.stringValue = favorites[row].title
//        case "Album": c?.textField?.stringValue = favorites[row].album
//        case "Artist": c?.textField?.stringValue = favorites[row].artist
//        case "Duration": c?.textField?.stringValue = favorites[row].duration.timeString ?? "--:--"
//        default: break
//        }
//        return c
//    }
//
//    func cell(in tableView: NSTableView, for column: NSTableColumn?) -> NSTableCellView? {
//        if column == tableView.tableColumns[0] {
//            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Title"), owner: self) as? NSTableCellView
//        } else if column == tableView.tableColumns[1] {
//            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Album"), owner: self) as? NSTableCellView
//        } else if column == tableView.tableColumns[2] {
//            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Artist"), owner: self) as? NSTableCellView
//        } else if column == tableView.tableColumns[3] {
//            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Duration"), owner: self) as? NSTableCellView
//        } else {
//            return nil
//        }
//    }
//
//    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
//        return HighlightOnHoverTableRowView()
//    }
//}
