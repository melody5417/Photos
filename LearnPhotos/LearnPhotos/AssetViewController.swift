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

    fileprivate var isPlayingHint = false

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

        // Make sure the view layout happends before requesting an image sized to fit the view.
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

        livePhotoView.delegate = self
        view.addSubview(livePhotoView)
        livePhotoView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }

        livePhotoView.isHidden = true

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
        case .livePhoto:
            updateLivePhoto()
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

    private func updateLivePhoto() {
        // Prepare the options to pass when fetching the live photo
        let options = PHLivePhotoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestLivePhoto(for: asset,
                                                  targetSize: targetSize,
                                                  contentMode: PHImageContentMode.aspectFit,
                                                  options: options) { (livePhoto, info) in
            // If successful, show the live photo view and display the live photo
            guard let livePhoto = livePhoto else { return }

            // Now that we have the live photo, show it
            self.imageView.isHidden = true
            self.livePhotoView.isHidden = false
            self.livePhotoView.livePhoto = livePhoto

            if !self.isPlayingHint {
                self.isPlayingHint = true
                self.livePhotoView.startPlayback(with: .hint)
            }
        }
    }

    // MARK: Properties

    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    let livePhotoView: PHLivePhotoView = {
        let view = PHLivePhotoView()
        return view
    }()
}

extension AssetViewController: PHPhotoLibraryChangeObserver {

    func photoLibraryDidChange(_ changeInstance: PHChange) {

    }

}

extension AssetViewController: PHLivePhotoViewDelegate {

    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        isPlayingHint = (playbackStyle == .hint)
    }

    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        isPlayingHint = (playbackStyle == .hint)
    }
}
