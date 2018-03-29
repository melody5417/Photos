# iOS开发：获取最近截屏的图片

## 前言
产品大大提了个需求「最近截屏图片的快捷提示」，开发初期被 **截屏** 误导，导致走了歪路。这里记录下开发思路和相关知识点。之前也没有开发过 **相册** 相关模块，所以借此机会学习下 **PhotoKit** 并整理了脑图，先立个flag，坐等 PhotoKit 的分享。

## 预研
这个需求具体是这样：

1. 当用户进入App主界面时，检测到30s内有截屏操作，进行图片快捷提示（样式可参考微信发送图片的快捷提示).
<p align="center">
	<img src="https://github.com/melody5417/Photos/blob/master/Resources/wechatDemo.jpg" width="90" height="160">
</p>
	
2. 若用户未点击提示，3s自动消失。

如前言所说，我最开始被截屏这个操作误导，去调研截屏相关的知识。了解到有用户按下 Home 和 Lock 截屏的通知： **UIApplicationUserDidTakeScreenshotNotification**，以为监听该通知就可以了。但是这个需求的应用场景是：用户在我们的App处于后台的情况下截屏，App处于后台根本无法收到该通知了。所以这个思路肯定不对。

仔细体验了微信的发送图片提示功能后，确定微信的实现原理应该和截屏没有一毛钱关系！应该是当用户点击 <img src="https://github.com/melody5417/Photos/blob/master/Resources/wechatSendButton.jpg" width="20" height="20"> 按钮时，去检索了截屏相册的图片，获取一定时间内最新添加的截屏图片。明白这个原理就OK了。

## 代码
1. 获取相册权限

	Info.plist 添加 Key: **NSPhotoLibraryUsageDescription**。 App启动后首次访问相册等操作 会呼出如下图的 申请权限 弹窗，用户确认后才能获得权限访问相册。
<p align="center">
	<img src="https://github.com/melody5417/Photos/blob/master/Resources/requestPermission.jpg" width="90" height="160">
</p>
2. 校验权限

	检测 PHPhotoLibrary.authorizationStatus() 状态：
	* authorized    顺序进行后续操作， 
   * notDetermined 可以呼出申请权限的弹窗，
   * denied        用户已拒绝授权，此时可以引导用户到设置页面开启权限，
   * restricted    若返回这个状态，说明第一步没有操作正确，如果还要强制操作必然crash。

	```
	func checkPermission(resultHandler: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    resultHandler(true)
                }
            }

        case .authorized:
            resultHandler(true)

        default:
            resultHandler(false)
        }
    }
	```

3. 检索截屏相册并获取图片数据

	```
	func getScreenShotRecentlyAdded(resultHandler: @escaping (UIImage?) -> Swift.Void) {

        guard let screenshotCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil).firstObject else {
            return
        }

        let options = PHFetchOptions()
        options.wantsIncrementalChangeDetails = true
        options.predicate = NSPredicate(format: "creationDate > %@", NSDate().addingTimeInterval(-30))
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        guard let screenshot = PHAsset.fetchAssets(in: screenshotCollection, options: options).firstObject else {
            return
        }

        PHImageManager.default().requestImage(for: screenshot,
                                              targetSize: PHImageManagerMaximumSize,
                                              contentMode: .aspectFit,
                                              options: nil) { (image, infoDic) in
            resultHandler(image)
        }
    }
	```

4. 优化
	主流程全部走通提测后，提测提了个bug：截屏30s内多次切换 App 到前后台，同一张截屏图片会提醒多次，这里也确实是自己考虑的不周，加了个 SHA1 去重检测。

