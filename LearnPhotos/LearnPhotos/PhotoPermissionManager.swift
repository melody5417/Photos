//
//  PhotoPermissionManager.swift
//  LearnPhotos
//
//  Created by yiqiwang(王一棋) on 2018/3/29.
//

import UIKit
import Photos

class PhotoPermissionManager: NSObject {

    static func requestPermission(resultHandler: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            resultHandler(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    resultHandler(true)
                } else {
                    resultHandler(false)
                }
            }
        case .denied:
            PermissionAlertController.show(with: .photo)
        default:
            resultHandler(false)
        }
    }
    
}
