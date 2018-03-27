//
//  GridViewCell.swift
//  LearnPhotos
//
//  Created by yiqiwang(王一棋) on 2018/3/22.
//

import UIKit

class GridViewCell: UICollectionViewCell {

    private var imageView = UIImageView()
    private var livePhotoBadgeImageView = UIImageView()

    var representedAssetIdentifier: String!

    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }

    var livePhotoBadgeImage: UIImage! {
        didSet {
            livePhotoBadgeImageView.image = livePhotoBadgeImage
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: initUI

    private func initUI() {
        contentView.addSubview(imageView)
        imageView.bounds = self.bounds
        contentView.addSubview(livePhotoBadgeImageView)
        livePhotoBadgeImageView.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 28, height: 28))
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        thumbnailImage = nil
        livePhotoBadgeImage = nil
    }

}
