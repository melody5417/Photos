//
//  MasterViewController.swift
//  LearnPhotos
//
//  Created by yiqiwang(王一棋) on 2018/3/21.
//

import UIKit
import Photos

class MasterViewController: UITableViewController {

    // MARK: Types for managing sections, cell and segue identifiers

    enum Section: Int {
        case allPhotos = 0
        case smartAlbums
        case userCollections

        static let count = 3
    }

    enum CellIdentifier: String {
        case allPhotos, collection
    }

    // MARK: Properites

    var allPhotos: PHFetchResult<PHAsset>!
    var smartAlbums: PHFetchResult<PHAssetCollection>!
    var userCollections: PHFetchResult<PHCollection>!
    let sectionLocalizedTitles = ["", NSLocalizedString("Smart Albums", comment: ""), NSLocalizedString("Albums", comment: "")]

    // MARK: UIViewController / Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlbum(_:)))
        navigationItem.rightBarButtonItem = addButton

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.allPhotos.rawValue)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.collection.rawValue)

        // Create a PHFetchResult object for each section in the table view.
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)

        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)

        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)

        // To get updated content for a fetch, register a change observer with the shared PHPhotoLibrary object
        PHPhotoLibrary.shared().register(self)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.clearsSelectionOnViewWillAppear = true
    }

    // MARK: Action

    @objc private func addAlbum(_ sender: AnyObject) {
        let alertController = UIAlertController(title: NSLocalizedString("New Album", comment: ""), message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Album name", comment: "")
        }

        alertController.addAction(UIAlertAction(title: NSLocalizedString("Create", comment: ""), style: .default, handler: { (_) in
            let textField = alertController.textFields!.first!
            if let title = textField.text, !title.isEmpty {
                // Create a new album with the title entered
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
                }, completionHandler: { (success, error) in
                    if !success {
                        print("error creating album:\(String(describing: error))")
                    }
                })
            }
        }))

        self.present(alertController, animated: true, completion: nil)
    }

}

// MARK: UITableViewDelegate / DataSource
extension MasterViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .allPhotos: return 1
        case .smartAlbums: return smartAlbums.count
        case .userCollections: return userCollections.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .allPhotos:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.allPhotos.rawValue, for: indexPath)
            cell.textLabel!.text = NSLocalizedString("All Photos", comment: "")
            return cell

        case .smartAlbums:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.collection.rawValue, for: indexPath)
            let collection = smartAlbums.object(at: indexPath.row)
            cell.textLabel!.text = collection.localizedTitle
            return cell

        case .userCollections:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.collection.rawValue, for: indexPath)
            let collection = userCollections.object(at: indexPath.row)
            cell.textLabel!.text = collection.localizedTitle
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionLocalizedTitles[section]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let assetGridViewController = AssetGridViewController(collectionViewLayout: layout)
        let collection: PHCollection

        switch Section(rawValue: indexPath.section)! {
        case .allPhotos:
            assetGridViewController.title = "All Photos"
            // configure the view controller with the asset collection
            assetGridViewController.fetchResult = allPhotos
        case .smartAlbums:
            collection = smartAlbums.object(at: indexPath.item)
            assetGridViewController.title = collection.localizedTitle
            // configure the view controller with the asset collection
            guard let assetCollection = collection as? PHAssetCollection
                else { fatalError("expected asset collection") }
            assetGridViewController.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
        case .userCollections:
            collection = userCollections.object(at: indexPath.item)
            assetGridViewController.title = collection.localizedTitle
            // configure the view controller with the asset collection
            guard let assetCollection = collection as? PHAssetCollection
                else { fatalError("expected asset collection") }
            assetGridViewController.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
        }

        navigationController?.pushViewController(assetGridViewController, animated: true)
    }

}

// MARK: PHPhotoLibraryChangeObserver

extension MasterViewController: PHPhotoLibraryChangeObserver {

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Change notifications may be made on a background queue.
        DispatchQueue.main.async {
            // check each of the three top-level fetches for changes

            if let changeDetails = changeInstance.changeDetails(for: self.allPhotos) {
                // update the cached fetch result
                self.allPhotos = changeDetails.fetchResultAfterChanges
            }

            if let changeDetails = changeInstance.changeDetails(for: self.smartAlbums) {
                self.smartAlbums = changeDetails.fetchResultAfterChanges
                self.tableView.reloadSections(IndexSet(integer: Section.smartAlbums.rawValue), with: .automatic)
            }

            if let changeDetails = changeInstance.changeDetails(for: self.userCollections) {
                self.userCollections  = changeDetails.fetchResultAfterChanges
                self.tableView.reloadSections(IndexSet(integer: Section.userCollections.rawValue), with: .automatic)
            }
        }
    }

}
