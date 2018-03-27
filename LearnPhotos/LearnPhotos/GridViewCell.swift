//
//  GridViewCell.swift
//  LearnPhotos
//
//  Created by yiqiwang(王一棋) on 2018/3/22.
//

import UIKit
import SnapKit

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

    // MARK: Life cycle

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
        imageView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
        contentView.addSubview(livePhotoBadgeImageView)
        livePhotoBadgeImageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 28, height: 28))
            make.top.left.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        thumbnailImage = nil
        livePhotoBadgeImage = nil
    }

}
