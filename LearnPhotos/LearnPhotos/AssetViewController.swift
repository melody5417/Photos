//
//  AssetViewController.swift
//  LearnPhotos
//
//  Created by yiqiwang(王一棋) on 2018/3/27.
//

import UIKit
import Photos
import PhotosUI

class AssetViewController: UIViewController {

    // MARK: Properties
    var asset: PHAsset!
    var assetCollection: PHAssetCollection!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        PHPhotoLibrary.shared().register(self)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.layoutIfNeeded()
        updateContent()
    }

    // MARK: Init UI

    private func initUI() {
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }

    // MARK: Image Display

    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: imageView.bounds.width * scale,
                      height: imageView.bounds.height * scale)
    }

    private func updateContent() {
        switch self.asset.playbackStyle {
        case .image:
            updateStillImage()
        default:
            print()
        }
    }

    private func updateStillImage() {
        // Prepare the options to pass when fetching the image.
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: targetSize,
                                              contentMode: .aspectFit,
                                              options: options) { (image, info) in
            guard let image = image  else { return }
            self.imageView.isHidden = false
            self.imageView.image = image
        }
    }

    // MARK: Properties

    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
}

extension AssetViewController: PHPhotoLibraryChangeObserver {

    func photoLibraryDidChange(_ changeInstance: PHChange) {

    }

}
