//
//  PermissionViewController.swift
//  LearnPhotos
//
//  Created by yiqiwang(王一棋) on 2018/3/29.
//

import UIKit
import SnapKit
import RxSwift

@objc enum PermissionType: Int {
    case audioRecord
    case speechRecognize
    case camera
    case photo

    func image() -> UIImage {
        switch self {
        case .audioRecord: return UIImage(named: "microphone")!
        case .speechRecognize: return UIImage(named: "speech")!
        case .camera: return UIImage(named: "camera")!
        case .photo: return UIImage(named: "photo")!
        }
    }

    func reportValue() -> Int {
        switch self {
        case .audioRecord: return 0
        case .camera: return 1
        case .photo: return 2
        case .speechRecognize: return 3
        }
    }

    func desc() -> NSAttributedString {

        var desc: String!
        switch self {
        case .audioRecord:
            desc = NSLocalizedString("需要“麦克风”权限，开启后可使用\nXXX", comment: "")
        case .speechRecognize:
            desc = NSLocalizedString("需要“语音识别”权限，开启后可提升\nXXX", comment: "")
        case .camera:
            desc = NSLocalizedString("需要“相机”权限，开启后可使用\nXXX", comment: "")
        case .photo:
            desc = NSLocalizedString("需要“照片”权限，开启后可使用\nXXX", comment: "")
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 5
        paragraphStyle.lineBreakMode = .byWordWrapping
        let attributedString = NSMutableAttributedString(string: desc, attributes: [NSAttributedStringKey.paragraphStyle: paragraphStyle])

        let fontAttribute = [NSAttributedStringKey.font: UIFont(name: "PingFang-SC-Medium", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)]
        for index in 0 ... 7 {
            let str = NSLocalizedString("permission_bold_\(index)", comment: "")
            if str.count == 0 { continue }
            let range = (desc as NSString).range(of: str)
            if range.length > 0 {
                attributedString.addAttributes(fontAttribute, range: range)
            }
        }

        return attributedString.copy() as! NSAttributedString
    }
}

class PermissionAlertController: UIViewController {

    private var window: UIWindow?
    private let disposeBag = DisposeBag()

    private var type: PermissionType!
    private var cancelHandler: (() -> Void)?

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        configEvents()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.alpha = 0
        self.contentView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 1
            self.contentView.transform = .identity
        }
    }

    // MAKR: Rotate

    override var shouldAutorotate: Bool {
        get{ return false }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get{ return .portrait }
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        get{ return .portrait }
    }

    // MARK: Init UI

    private func initUI() {
        view.backgroundColor = UIColor(rgb: 0x000000, alpha: 0.5)

        view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(promptView)
        promptView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }

        promptView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 80))
        }

        promptView.addSubview(descLabel)
        descLabel.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualToSuperview().offset(15)
            make.right.lessThanOrEqualToSuperview().offset(-15)
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        promptView.addSubview(separateLine)
        separateLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(descLabel.snp.bottom).offset(30.5)
            make.height.equalTo(0.5)
        }

        promptView.addSubview(settingButton)
        settingButton.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(separateLine)
            make.height.equalTo(55.5)
        }

        contentView.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(promptView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 35, height: 35))
        }
    }

    // MARK: Config Events

    private func configEvents() {
        closeButton.addTarget(self, action: #selector(self.closeAction), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(self.openSetting), for: .touchUpInside)
    }

    // MARK: Action

    @objc private func closeAction() {
        self.close({ self.cancelHandler?() })
    }

    @objc private func openSetting() {
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        self.close()
    }

    // MARK: Load Data

    private func loadData() {
        imageView.image = type.image()
        descLabel.attributedText = type.desc()
    }

    // MARK: Show

    class func show(with type: PermissionType, cancelHandler: (() -> Void)? = nil) {
        let vc = PermissionAlertController()
        vc.type = type
        vc.cancelHandler = cancelHandler

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = UIWindowLevelStatusBar + 1;
        window.isHidden = false;
        window.makeKeyAndVisible()
        window.rootViewController = vc
        vc.window = window
    }

    // MARK: Close

    private func close(_ completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.view.alpha = 0
        }, completion: { (finished) in
            self.window?.isHidden = true
            self.window = nil
            completion?()
        })
    }

    // MARK: Propertys

    private let contentView = UIView()

    private let promptView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0xffffff)
        view.layer.cornerRadius = 5 * UIScreen.main.scale
        view.clipsToBounds = true
        return view
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let descLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgb: 0x000000, alpha: 0.8)
        label.font = UIFont(name: "PingFang-SC-Light", size: 14) ?? UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()

    private let separateLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0x000000, alpha: 0.2)
        return view
    }()

    private let settingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitle(NSLocalizedString("去设置", comment: ""), for: .normal)
        button.setTitleColor(UIColor(rgb: 0xa04cf7), for: .normal)
        button.setTitleColor(UIColor(rgb: 0xa04cf7, alpha: 0.5), for: .highlighted)
        return button
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "close"), for: .normal)
        return button
    }()
}
