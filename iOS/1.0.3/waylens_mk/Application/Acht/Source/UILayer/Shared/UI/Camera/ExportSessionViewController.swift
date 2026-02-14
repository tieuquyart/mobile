//
//  ExportSessionViewController.swift
//  Acht
//
//  Created by Chester Shen on 1/17/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import Photos
import GPUImage
#if useMixpanel
import Mixpanel
#endif
import WaylensPiedPiper
import WaylensFoundation
import WaylensCameraSDK
import WaylensVideoSDK

enum ExportState {
    case idle
    case exportTriggered
    case exporting
    case exported
    case failed
}

enum ExportDestination {
    case albumInApp
    case photoLibrary
    case waylens
}

class ExportSessionViewController: BaseViewController {
    @IBOutlet weak var previewContainer: UIView!
    @IBOutlet weak var videoArea: UIView!
//    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var timestampSwitch: UISwitch!
    @IBOutlet weak var slider: HNSegmentedSlider!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var tipContainer: UIStackView!
    @IBOutlet weak var gestureTipView: UIView!
    @IBOutlet weak var passThroughView: PassThroughView!
    @IBOutlet weak var itemsContainingView: UIView!
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var topProgressLength: NSLayoutConstraint!
    @IBOutlet weak var bottomProgressLength: NSLayoutConstraint!
    @IBOutlet weak var rightProgressLength: NSLayoutConstraint!
    @IBOutlet weak var leftProgressLength: NSLayoutConstraint!
    @IBOutlet weak var itemsContainingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewContainerAspectRatio: NSLayoutConstraint!

    // used for vdb request, stream index
    public var streamIndex = Int32(0)

    private var transcoder : WLVideoTranscoder?
    private var transcodedURL: URL?
    private var downloadUrl: URL?
    private var expectedSize: Int64?
    private var camera: UnifiedCamera? {
        didSet {
            camera?.local?.vdbClient.delegate = self
        }
    }
    private var clip: EditableClip!

    private var playUrl: Promise<String>? {
        didSet {
            playUrl?.onSuccess({ [weak self] (url) in
                guard let self = self else {
                    return
                }

                var fixedUrl = url

                if let lastPathComponent = (url as NSString).pathComponents.last {
                    fixedUrl = fixedUrl.replacingOccurrences(of: "/0/\(lastPathComponent)", with: "/\(self.streamIndex)/\(lastPathComponent)")
                }

                self.playVideo(url: fixedUrl)
            })
        }
    }

    private var isVisible: Bool = false
    private var downloadInfo: VDBDownloadInfo?
    private weak var progressVC: ExportProgressViewController?
    private let exportingDirName = "Exporting"
    private enum ExportError: Error {
        case failToGetUrl
        case failToDownload
        case failToMoveToDirectory
        case failToTranscode
        case failToImportToLibrary
        case failToUploadToWaylens
    }
    private var state: ExportState = .idle {
        didSet {
            progressVC?.state = state
            if isViewLoaded {
                refreshUI()
            }

            reevaluateIdleTimerDisabled()
        }
    }
    private var error: ExportError?
    private var errorMsg: String?
    private var isFromLocal: Bool = false
    private var progress: Float = 0 {
        didSet {
            if isViewLoaded {
                refreshProgress(progress)
                progressVC?.progress = progress

                reevaluateIdleTimerDisabled()
            }
        }
    }
    private let projectionModes: [WLVideoRenderMode] = [.split, .immersive(direction: nil)]
    private var isTouched: Bool = false {
        didSet {
            if isTouched == oldValue {
                return
            }
            if isTouched && !gestureTipView.isHidden {
                UIView.animate(withDuration: 0.3, animations: {
                    self.gestureTipView.alpha = 0
                }) { (_) in
                    self.gestureTipView.isHidden = true
                }
            }
        }
    }

    private var videoPlayer: WLVideoPlayer?
    private var exportDestination: ExportDestination = .albumInApp
    private var _mp4Uploader: MP4UploaderAdapter? = nil
    private var mp4Uploader: MP4UploaderAdapter? {
        return _mp4Uploader
    }
    private lazy var shareDescriptionViewController: ExportSessionShareDescriptionViewController = { [unowned self] in
        let vc = ExportSessionShareDescriptionViewController()
        vc.acceptanceStateChangeHandler = { accepted in
            self.actionButton.isEnabled = accepted
        }
        return vc
    }()
    private var videoRotationUtil: VideoRotationUtil?

    private var streamPickerView: ItemPickerView<HNVideoResolution>?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    static func createViewController(
        clip: EditableClip,
        camera: UnifiedCamera?,
        streamIndex: Int32,
        exportDestination: ExportDestination
    ) -> ExportSessionViewController {
        let vc = UIStoryboard(name: "CameraDetail", bundle: nil).instantiateViewController(withIdentifier: "ExportSessionViewController") as! ExportSessionViewController
        vc.clip = clip
        vc.camera = camera
        vc.streamIndex = streamIndex
        vc.exportDestination = exportDestination
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        title = NSLocalizedString("Export", comment: "Export")
        initHeader(text: NSLocalizedString("Export", comment: "Export"), leftButton: false)
        state = .idle
        progress = 0
        infoView.alpha = 0
        tipLabel.text = NSLocalizedString("export_session_tip", comment: "For higher video quality and completeness, try to export videos from SD card via Wi-Fi connection.")
        tipLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 12)
        slider.bouncesOnChange = false
        slider.announcesValueImmediately = true
        slider.alwaysAnnouncesValue = false

        var titles = [HNViewMode.frontBack.displayNameForExport, HNViewMode.panorama.displayNameForExport]

        if UserSetting.shared.debugEnabled || !clip.needDewarp {
            titles.append("Raw")
        }

        slider.titles = titles

        if !clip.needDewarp {
            slider.isHidden = true
            try! slider.setIndex(2)
            gestureTipView.isHidden = true
        }

        passThroughView.hitDelegate = self
        if #available(iOS 11.0, *) {
            gestureTipView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        }
        gestureTipView.layer.cornerRadius = gestureTipView.bounds.height * 0.5
        fetchThumbnail()

        videoPlayer = WLVideoPlayer(container: videoArea)
        videoPlayer?.isLooping = true
        videoPlayer?.delegate = self
        videoPlayer?.dewarpParams = WLVideoDewarpParams(
            renderMode: clip.originalClip.needDewarp ? .split : .original,
            rotate180Degrees: clip.facedown,
            showTimeStamp: false,
            showGPS: false
        )

        switch exportDestination {
        case .waylens:
            shareDescriptionViewController.addToParent(self, containingView: itemsContainingView)
        default:
            break
        }

        setupStreamPickerViewIfNeed()
        applyTheme()

        NotificationCenter.default.addObserver(self, selector: #selector(onDownloadStateChanged), name: Notification.Name.Downloader.stateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)

        getPlayUrl()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Notification.Name.ReloadNotiList.reload, object: nil,userInfo: nil)
        self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchClipInfo()
        onSwitchTimestamp(timestampSwitch)
        onSliderChanged(slider)
        tipContainer.isHidden = !shouldShowTip

        if previousViewControllerInNavigationStack is VideosSharedByUsersViewController {
            if videoRotationUtil == nil {
                videoRotationUtil = VideoRotationUtil(rotationHandler: { [weak self] (facedown) in
                    self?.videoPlayer?.dewarpParams.rotate180Degrees = facedown
                })
                videoRotationUtil?.addRotationButton(to: videoArea)
            }
        }

        refreshUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isVisible = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
        videoPlayer?.shutdown()
//        thumbnail.isHidden = false
        playUrl?.cancel()
        if isMovingFromParent {
            VideoDownloadManager.shared.cancel()
            if progressVC?.viewIfLoaded?.window != nil {
                progressVC?.dismiss(animated: false, completion: nil)
            }
        }
    }

    override func applyTheme() {
        super.applyTheme()

        videoContainer.backgroundColor = UIColor.semanticColor(.playerContainerBackground)
        videoArea.backgroundColor = UIColor.semanticColor(.background(.senary))

        slider.titleFont = UIFont(name: "BeVietnamPro-Bold", size: 12)!
        slider.indicatorColor = UIColor.semanticColor(.fill(.octonary))
        slider.backgroundColor = UIColor.semanticColor(.background(.secondary))
        slider.titleColor = UIColor.semanticColor(.label(.secondary))
        slider.coveredTitleColor = UIColor.semanticColor(.label(.secondary))
        slider.coverColor = UIColor.semanticColor(.background(.secondary))
        slider.selectedTitleColor = UIColor.semanticColor(.tint(.primary))

        streamPickerView?.backgroundColor = UIColor.semanticColor(.background(.primary))
        streamPickerView?.titleLabel.textColor = UIColor.semanticColor(.label(.secondary))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func onEnterBackground() {
        if state == .exportTriggered || state == .exporting {
            NotificationsManager().scheduleContinueExportingNotification()
        }
    }

    func fetchThumbnail() {
        if let rawClip = clip.originalClip.rawClip {
            _ = camera?.local?.vdbManager?.getThumbnail(forClip: rawClip, atTime: rawClip.startTime + clip.offset, completion: { [weak self] (result) in
                if self?.videoPlayer?.state == .unloaded, result.isSuccess, let thumbnail = result.value as? WLVDBThumbnail, let image = UIImage(data: thumbnail.imageData) {
                    self?.videoPlayer?.replaceCurrentItem(with: .image(image)).start()
                }
            })
        } else if let urlString = clip.originalClip.thumbnailUrl, let url = URL(string: urlString) {
            CacheManager.shared.imageFetcher.get(url).onSuccess { [weak self] (image) in
                if self?.videoPlayer?.state == .unloaded {
                    self?.videoPlayer?.replaceCurrentItem(with: .image(image)).start()
                }
            }
        }
    }

    func playVideo(url: String) {
        if let url = URL(string: url)  {
            videoPlayer?.replaceCurrentItem(with: .video(url: url)).start()
            videoPlayer?.duration = clip.duration
        }
    }

    func refreshProgress(_ progress: Float) {
        let progress = CGFloat(progress)
        let la = previewContainer.bounds.width
        let lb = previewContainer.bounds.height - 5
        let lc = la - 5
        let ld = lb - 5
        var lp = (la + lb + lc + ld) * progress
        topProgressLength.constant = min(la, max(0, lp))
        lp -= la
        rightProgressLength.constant = min(lb, max(0, lp))
        lp -= lb
        bottomProgressLength.constant = min(lc, max(0, lp))
        lp -= lc
        leftProgressLength.constant = min(ld, max(0, lp))
        previewContainer.setNeedsLayout()
    }

    private func refreshInfo(duration: TimeInterval, bytes: Int64?=nil) {
        let estimatedSize = Int64(2621440 * duration)
        infoLabel.text = "\(duration.toString(.hms))  \(String.fromBytes(bytes ?? estimatedSize, countStyle: .file))"
        progressVC?.infoLabel.text = infoLabel.text
        UIView.animate(withDuration: 0.3) {
            self.infoView.alpha = 1.0
            self.progressVC?.infoView.alpha = 1.0
        }
    }

    func refreshUI() {
        let margin: CGFloat = 20.0
        actionButton.titleLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)
        if clip.needDewarp {
            if exportDestination == .albumInApp {
                itemsContainingViewHeightConstraint.constant = 54.0
            }
            else {
                itemsContainingViewHeightConstraint.constant = 174.0
            }
        }
        else {
            if streamPickerView != nil {
                if actionButton.frame.maxY > view.layoutMarginsGuide.layoutFrame.height - margin {
                    itemsContainingViewHeightConstraint.constant = view.layoutMarginsGuide.layoutFrame.height - itemsContainingView.frame.origin.y - actionButton.frame.height - (actionButton.topConstraint?.constant ?? 0.0) - margin
                }
                else {
                    itemsContainingViewHeightConstraint.constant = 140.0
                }
            }
            else {
                itemsContainingViewHeightConstraint.constant = 54.0
            }
        }

        if state == .idle {
            switch exportDestination {
            case .albumInApp:
                actionButton.setTitle(NSLocalizedString("Save to Album", comment: "Save to Album"), for: .normal)
            case .photoLibrary:
                actionButton.setTitle(NSLocalizedString("Export to Photo Library", comment: "Export to Photo Library"), for: .normal)
            case .waylens:
                actionButton.setTitle(NSLocalizedString("Share to Waylens", comment: "Share to Waylens"), for: .normal)
            }
            actionButton.titleLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 14)
            actionButton.applyMainStyle()
            actionButton.setTitleColor(.white, for: .normal)
            videoRotationUtil?.showRotationButton()
        } else if state == .exporting {
            actionButton.isHidden = true
            videoRotationUtil?.hideRotationButton()
        } else if state == .exported {
            actionButton.isHidden = true
        } else if state == .failed {
            progressVC?.progressInfoLabel.text = NSLocalizedString("Exporting failed", comment: "Exporting failed")
            HNMessage.showError(message: errorMsg ?? NSLocalizedString("Fail to export video!", comment: "Fail to export video!"))
            actionButton.isHidden = true
        }
    }

    @IBAction func onMainAction(_ sender: Any) {
        self.videoPlayer?.shutdownAndKeepCurrentFrameImage()

        let rect = previewContainer.convert(self.previewContainer.bounds, to: view.window)
        let progressVC = ExportProgressViewController.createViewController()

        func start() {
            self.progressVC = progressVC
            self.progressVC?.delegate = self
            self.progressVC?.view.inverseMask(roundedRect: rect, radius: 0)
            self.progressVC?.maskView.frame = rect
            self.progressVC?.maskView.translatesAutoresizingMaskIntoConstraints = true
            self.progressVC?.infoView.alpha = self.infoView.alpha
            self.progressVC?.infoLabel.text = self.infoLabel.text
            self.progressVC?.progress = self.progress
            self.startExport()
            self.present(self.progressVC!, animated: false, completion: nil)
        }

        if exportDestination == .photoLibrary {
            if streamPickerView?.selectedItem == .frontHD, !UIDevice.current.supports4KVideo {
                alert(title: nil, message: NSLocalizedString("This device does not support the export of 4K video. The video will be exported after converting.", comment: "This phone does not support the export of 4K video. The video will be exported after converting."), action1: { () -> UIAlertAction in
                    return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) { _ in

                    }
                }) { () -> UIAlertAction in
                    return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { [weak self] _ in
                        guard let self = self else {
                            return
                        }

                        self.gestureTipView.isHidden = true
                        self.checkPhotoAuth(authed: {
                            start()
                        })
                    }
                }
            }
            else {
                gestureTipView.isHidden = true
                checkPhotoAuth(authed: {
                    start()
                })
            }
        } else {
            start()
        }
    }

    func downloadStatusFor(_ clip: BasicClip) -> VideoDownloadManager.DownloadTaskStatus? {
        if SavedClipManager.shared.clipIsSaved(clip, index: streamIndex) {
            return .completed
        }
        return VideoDownloadManager.shared.downloadStatusFor(clip, index: streamIndex)
    }

    func startExport() {
        if error != nil {
            state = .failed
            return
        }

        state = .exportTriggered

        if let status = downloadStatusFor(clip) {
            switch status {
            case .completed:
                export()
            case .failed:
                break
            case .downloading:
                break
            default: // downloading or added to queue, wait for download to complete
                break
            }
        } else { // not in queue
            startDownloading()
//            if let url = clip.originalClip.url, let size = expectedSize {
//                download(url: url, bytes: size)
//            }
        }
    }

    private func export() {
        state = .exporting

        switch exportDestination {
        case .albumInApp:
            doneExport()
        case .photoLibrary:
            if slider.index == 2 { // export raw
                if streamPickerView?.selectedItem == .frontHD, !UIDevice.current.supports4KVideo {
                    let outputSize = CGSize(width: 2560, height: 1440)

                    /*
                    if let highestResolutionSupported = AVCaptureDevice.highestResolutionSupported {
                        outputSize = CGSize(width: Double(highestResolutionSupported.width), height: Double(highestResolutionSupported.width) / (16.0 / 9.0))
                    }
                     */

                    transcode(with: outputSize)
                }
                else {
                    exportRaw()
                }
            } else {
                transcode()
            }
        case .waylens:
            uploadVideoToWaylens()
        }
    }

    func doneExport() {
        progress = 1.0
        state = .exported
        clearVideos()
    }

    func retry() {
        error = nil
        errorMsg = nil
        state = .exporting
        progress = 0
        startDownloading()
        startExport()
    }

    func cancel() {
        if transcoder?.isTranscoding == true {
            transcoder?.cancel()
        } else if VideoDownloadManager.shared.status == .downloading {
            VideoDownloadManager.shared.cancel()
        }

        if mp4Uploader?.isUploading == true {
            mp4Uploader?.cancel()
        }

        state = .idle
        exit()
    }

    func exit() {
        progressVC?.dismiss(animated: false, completion: nil)

        #if FLEET
        if
//            (UserSetting.current.userProfile?.roles.contains(.installer) == true)
//                ||
                !AccountControlManager.shared.isLogin
        {
            if let savedClip = SavedClipManager.shared.findClip(forClip: clip, index: streamIndex) {
                SavedClipManager.shared.removeClip(savedClip)
            }
        }
        #endif

        guard let vcs = navigationController?.viewControllers.reversed() else {
            return
        }
        if let nc = navigationController {
            var popped = false
            for vc in vcs {
                if vc as? ExportSessionViewController == nil && vc as? SelectRangeViewController == nil {
                    popped = true
                    navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
            if !popped {
                nc.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    private func fetchClipInfo() {
        // get video's actual file size and duration, download vdb video in advance
        if let rawclip = clip.originalClip.rawClip, let vdbManager = camera?.local?.vdbManager {
            vdbManager.getDownloadUrl(
                forClip: rawclip,
                from: clip.offset,
                duration: clip.duration,
                stream: self.streamIndex,
                completion: { [weak self] (result) in
                guard let this = self else { return }

                if result.isSuccess {
                    let info = result.value as! VDBDownloadInfo
                    this.downloadInfo = info
                    Log.info("get download url:\(info.url) kbytes:\(info.kBytes)")

                    var size = info.kBytes

                    // make url for specified stream
                    if let streamIndex = self?.streamIndex {
                        if streamIndex == 1 {
                            size = info.subsizek
                        }
                        else if streamIndex > 1 {
                            size = info.subnsizek
                        }
                    }

                    this.clip.offset = info.date.timeIntervalSince(this.clip.originalClip.startDate)
                    this.clip.duration = info.duration
                    let bytes = Int64(size) * 1000
                    this.refreshInfo(duration: info.duration, bytes: bytes)
                } else {
                    this.fail(.failToGetUrl, message: NSLocalizedString("Fail to get download url", comment: "Fail to get download url"))
                }
            })
        } else if let urlString = clip.originalClip.url {
            if !urlString.starts(with: "http") { // video is from device's local disk
                isFromLocal = true
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: urlString) as NSDictionary
                    let size: Int64 = numericCast(attributes.fileSize())
                    refreshInfo(duration: clip.duration, bytes: size)
                } catch let error as NSError {
                    Log.error("Error while get attributes of file \(urlString): \(error)")
                }
            } else { // video is on cloud
                WaylensClientS.shared.getFileSize(url: urlString) { [weak self] (size) in
                    guard let this = self else { return }
                    if size < 0 {
                        this.fail(.failToDownload, message: NSLocalizedString("Fail to download the video", comment: "Fail to download the video"))
                    } else {
                        this.refreshInfo(duration: this.clip.duration, bytes: size)
                        this.expectedSize = size
                    }
                }
            }
        }
    }

    private func startDownloading() {
        // get video's actual file size and duration, download vdb video in advance
        if let rawclip = clip.originalClip.rawClip, let vdbManager = camera?.local?.vdbManager {
            vdbManager.getDownloadUrl(
                forClip: rawclip,
                from: clip.offset,
                duration: clip.duration,
                stream: self.streamIndex,
                completion: { [weak self] (result) in
                guard let this = self else { return }

                if result.isSuccess {
                    let info = result.value as! VDBDownloadInfo
                    this.downloadInfo = info
                    Log.info("get download url:\(info.url) kbytes:\(info.kBytes)")

                    var url = String(info.url)
                    var size = info.kBytes

                    // make url for specified stream
                    if let streamIndex = self?.streamIndex {
                        if streamIndex == 1, let subUrl = info.subUrl {
                            url = subUrl
                            size = info.subsizek
                        }
                        else if streamIndex > 1, let subnUrl = info.subnUrl {
                            url = subnUrl
                            size = info.subnsizek
                        }
                    }

                    this.clip.offset = info.date.timeIntervalSince(this.clip.originalClip.startDate)
                    this.clip.duration = info.duration
                    let bytes = Int64(size) * 1000
                    this.refreshInfo(duration: info.duration, bytes: bytes)
                    if let status = this.downloadStatusFor(this.clip) { // download video if not downloaded or failed before
                        switch status {
                        case .failed:
                            this.download(url: url, bytes: bytes)
                        default:
                            break
                        }
                    } else {
                        this.download(url: url, bytes: bytes)
                    }
                } else {
                    this.fail(.failToGetUrl, message: NSLocalizedString("Fail to get download url", comment: "Fail to get download url"))
                }
            })
        } else if let urlString = clip.originalClip.url {
            if !urlString.starts(with: "http") { // video is from device's local disk
                isFromLocal = true
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: urlString) as NSDictionary
                    let size: Int64 = numericCast(attributes.fileSize())
                    refreshInfo(duration: clip.duration, bytes: size)
                } catch let error as NSError {
                    Log.error("Error while get attributes of file \(urlString): \(error)")
                }
            } else { // video is on cloud
                WaylensClientS.shared.getFileSize(url: urlString) { [weak self] (size) in
                    guard let this = self else { return }
                    if size < 0 {
                        this.fail(.failToDownload, message: NSLocalizedString("Fail to download the video", comment: "Fail to download the video"))
                    } else {
                        this.refreshInfo(duration: this.clip.duration, bytes: size)
                        this.expectedSize = size
                        this.download(url: urlString, bytes: size)
                    }
                }
            }
        }
    }

    func download(url: String, bytes:Int64) {
        let remained = Int64(MySystemUtil.getFreeDiskspace()) - bytes * 3
        if remained < 0 {
            let size = String.fromBytes(-remained, countStyle: .file)
            let msg = String(format: NSLocalizedString("not_enough_free_space", comment: "Not enough free space.\nNeed at least %@ more"), size)
            fail(.failToDownload, message: msg)
            return
        }
        do {
            try VideoDownloadManager.shared.addTask(url: url, local: clip.originalClip.rawClip != nil, clip: clip, bytes: bytes, streamIndex: streamIndex)
        } catch VideoDownloadError.alreadyInQueue {
            Log.info("Download task already in queue")
        } catch VideoDownloadError.notEnoughSpace(let short) {
            let size = String.fromBytes(short, countStyle: .file)
            let msg = String(format: NSLocalizedString("not_enough_free_space", comment: "Not enough free space.\nNeed at least %@ more"), size)
            fail(.failToDownload, message: msg)
        } catch {
            // pass
        }
    }

    func uploadVideoToWaylens() {
        if _mp4Uploader == nil {
            _mp4Uploader = MP4UploaderAdapter()
        }

        if !mp4Uploader!.isUploading, let savedClip = SavedClipManager.shared.findClip(forClip: clip, index: 0) {
            mp4Uploader!.uploadClip(savedClip, progressClosure: { [weak self] (progress) in
                self?.progress = min((progress * 0.5 + 0.5), 1.0)
            }) { [weak self] (result) in
                switch result {
                case .success:
                    Log.info("Uploaded video to Waylens successfully!")
                    self?.doneExport()
                    MixpanelHelper.track(event: "Exported to Waylens")
                case .failure:
                    Log.info("Failed to upload video to Waylens.")
                    self?.fail(.failToUploadToWaylens, message: NSLocalizedString("Failed to upload video to Waylens!", comment: "Failed to upload video to Waylens!"))
                    self?.clearVideos()
                }
            }
        }
    }

    func exportRaw() {
        CacheManager.shared.thumbnailCache.clear()
        if let savedPath = SavedClipManager.shared.findClip(forClip: clip, index: streamIndex)?.url {
            transcodedURL = URL(fileURLWithPath: savedPath, isDirectory: false)
            transcodeCompleted()
        }
    }

    func transcode(with outputSize: CGSize = CGSize(width: 1920, height: 1080)) {
        CacheManager.shared.thumbnailCache.clear()
        if let savedPath = SavedClipManager.shared.findClip(forClip: clip, index: streamIndex)?.url {
            let inputURL = URL(fileURLWithPath: savedPath)

            do {
                let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true).appendingPathComponent(exportingDirName, isDirectory: true)
                guard SavedClipManager.shared.checkDirectoryExists(path: documentsDir) else { return }
                let name = "Secure360_\(clip.startDate.toString(format: .dateTimeSec))_\(Int(clip.duration * 1000)).mp4"
                transcodedURL = URL(string:name, relativeTo:documentsDir)

                transcoder = try WLVideoTranscoder(
                    input: WLVideoTranscoderInput(fileUrl: inputURL),
                    output: WLVideoTranscoderOutput(
                        destinationUrl: transcodedURL!,
                        resolution: WLVideoTranscodeResolution.custom(width: Float(outputSize.width), height: Float(outputSize.height)),
                        bitrateInKbps: 0,
                        dewarpParams: videoPlayer!.dewarpParams
                    )
                )
                .transcodeProgress(closure: { [weak self] (progress) in
                    guard let self = self else {
                        return
                    }

                    NSLog("On transcode progress %0.2f", progress)
                    var newProgress: Float = progress

                    if self.exportDestination == .photoLibrary {
                        newProgress = min(self.isFromLocal ? progress : (progress * 0.5 + 0.5), 0.99)
                    }

                    if newProgress > self.progress {
                        self.progress = newProgress
                    }
                })
                .completion { [weak self] in
                    self?.transcodeCompleted()
                }
                .failure { [weak self] in
                    guard let self = self else {
                        return
                    }

                    self.clearVideos()
                    self.fail(.failToTranscode, message: NSLocalizedString("Fail to export video", comment: "Fail to export video"))
                }
                .start()
            } catch {
                fail(.failToTranscode, message: String(format: NSLocalizedString("Fail to init transcoder: %@", comment: "Fail to init transcoder: %@"), error.localizedDescription))
            }
        }
    }

    private func transcodeCompleted() {
        Log.info("Transcode completed!")

        PHPhotoLibrary.saveVideo(videoUrl: self.transcodedURL!, albumName: HornAlbumName) { [weak self] (asset, error) in
            guard let self = self else {
                return
            }

            if asset == nil {
                self.clearVideos()
                self.fail(.failToImportToLibrary, message: NSLocalizedString("Fail to save exported video to album", comment: "Fail to save exported video to album") + (error != nil ? ":\(error!.localizedDescription)" : ""))
            } else {
                Log.info("Export video succeed, saved to album!")
                self.doneExport()
                MixpanelHelper.track(event: "Exported to Photo Library")

                if let videoPlayer = self.videoPlayer {
                    let renderMode = videoPlayer.dewarpParams.renderMode
                    switch renderMode {
                    case .split, .immersive(_):
                        var prop = Dictionary<String, Any>()
                        prop["mode"] = renderMode == .split ? "split" : "immersive"
                        MixpanelHelper.track(event: "ProjectionMode Export", properties: prop)
                    default:
                        break
                    }

                }
            }
        }
    }

    private func fail(_ error:ExportError, message: String?) {
        if let msg = message {
            Log.error(msg)
        }
        self.error = error
        errorMsg = message
        if state == .exporting {
            state = .failed
        }
    }

    @objc func onDownloadStateChanged() {
        let manager = VideoDownloadManager.shared
        switch manager.status {
        case .idle:
            break
        case .downloading:
            if (state == .exporting ||
                state == .exportTriggered) {
                switch exportDestination {
                case .albumInApp:
                    progress = Float(manager.progress)
                case .photoLibrary:
                    progress = Float(manager.progress * 0.5)
                case .waylens:
                    progress = Float(manager.progress * 0.5)
                }
            }
        case .canceled:
            break
        case .failed:
            fail(.failToDownload, message: NSLocalizedString("Download failed", comment: "Download failed"))
        case .completed:
            if let savedClip = manager.completedTasks.last?.savedClip {
                clip.duration = savedClip.duration

                if state == .idle {
                    refreshInfo(duration: clip.duration)
                }
            }

            if state == .exportTriggered {
                export()
            }
        }
    }

    func getPlayUrl() {
        playUrl = Promise<String>()
        if let rawClip = clip.originalClip.rawClip {
            if rawClip.isMP4(forStream: streamIndex) {
                camera?.local?.clipsAgent.vdb?.getMP4(forClip: rawClip.clipID,
                                                         in: WLVDBDomain(rawValue: UInt32(rawClip.clipType)),
                                                         from: rawClip.startTime + clip.offset,
                                                         length: 30*60.0,
                                                         stream: streamIndex,
                                                         withTag: 1000,
                                                         andID: rawClip.vdbID)
            } else {
                camera?.local?.clipsAgent.vdb?.getHLSForClip(rawClip.clipID,
                                                                    in: WLVDBDomain(rawValue: UInt32(rawClip.clipType)),
                                                                    from: rawClip.startTime + clip.offset,
                                                                    length: 30*60.0,
                                                                    stream: streamIndex,
                                                                    withTag: 1000,
                                                                    andID: rawClip.vdbID)
            }
        } else if let url = clip.originalClip.url {
            playUrl?.succeed(url)
        }
    }

    func clearVideos() {
        guard let documentsDir = try? FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true).appendingPathComponent(exportingDirName, isDirectory: true) else { return }
        if FileManager.default.fileExists(atPath: documentsDir.path) {
            try? FileManager.default.removeItem(at: documentsDir)
        }
    }

    @IBAction func onSwitchTimestamp(_ sender: UISwitch) {
        var showGPS = false
        if camera?.featureAvailability.isGPSInfoInVideoOverlayAvailable == true {
            showGPS = true
        }
        videoPlayer?.dewarpParams.showTimeStamp = sender.isOn
        videoPlayer?.dewarpParams.showGPS = showGPS
    }

    @IBAction func onSliderChanged(_ sender: HNSegmentedSlider) {
        if clip.needDewarp == false {
            return
        }
        Log.info("Export view mode is \(sender.index)")
        if sender.index < 2 {
            let mode = projectionModes[Int(sender.index)]
            videoPlayer?.dewarpParams.renderMode = mode
            gestureTipView.isHidden = isTouched || mode == .split
        }
    }
}

private extension ExportSessionViewController {

    var shouldShowTip: Bool {
        if (clip.originalClip.rawClip != nil) || (previousViewControllerInNavigationStack is HNAlbumViewController) { // export from camera or album
            return false
        } else {
            return true
        }
    }

    func updateActionButton() {

    }

    func reevaluateIdleTimerDisabled() {
        if state == .exporting && UIApplication.shared.isIdleTimerDisabled == false {
            UIApplication.shared.isIdleTimerDisabled = true
        } else {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    func setupStreamPickerViewIfNeed() {
        if !clip.needDewarp, let vdbClip = clip.originalClip.rawClip {
            let resolutions = HNVideoResolution.parse(vdbClip.resolutions)
            let selectedResolution = resolutions[Int(streamIndex)]

            var config = ItemPickerViewConfig()
            config.itemBackgroundColor = { UIColor.clear }

            streamPickerView = ItemPickerView<HNVideoResolution>(
                frame: CGRect.zero,
                layout: StreamPickerViewLayout(),
                config: config,
                items: resolutions.sorted{$0.rawValue < $1.rawValue},
                selectedItem: selectedResolution
            ) { [weak self] (selectedItem) in
                guard let self = self else {
                    return
                }

                if let selectedStreamIndex = resolutions.firstIndex(of: selectedItem) {
                    self.streamIndex = Int32(selectedStreamIndex)
                    self.fetchClipInfo()
                    self.getPlayUrl()
                }
            }
            streamPickerView?.titleLabel.text = NSLocalizedString("Exported video", comment: "Exported video")
            streamPickerView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            streamPickerView?.frame = itemsContainingView.bounds

            itemsContainingView.addSubview(streamPickerView!)
        }
    }

}

extension ExportSessionViewController: WLVideoPlayerDelegate {

    func player(_ player: WLVideoPlayer, aspectRatioDidChange aspectRatio: CGFloat) {
        let newPreviewContainerAspectRatio = previewContainerAspectRatio.constraintWithMultiplier(aspectRatio)

        previewContainer.removeConstraint(previewContainerAspectRatio)
        previewContainer.addConstraint(newPreviewContainerAspectRatio)

        previewContainerAspectRatio = newPreviewContainerAspectRatio

        UIView.animate(withDuration: Constants.Animation.defaultDuration) { [weak self] in
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
        }

        refreshUI()
    }

}

extension ExportSessionViewController: ExportProgressViewDelegate {

    func shouldShowGoToAlbumButtonWhenFinish() -> Bool {
        func commonFunc() -> Bool {
            func isFromAlbum() -> Bool {
                return navigationController?.viewControllers.contains(where: {$0 is HNAlbumViewController}) ?? false
            }

            return !isFromAlbum()
        }

        #if FLEET
        if
//            (UserSetting.current.userProfile?.roles.contains(.installer) == true)
//                ||
                !AccountControlManager.shared.isLogin
        {
            return false
        }
        else {
            return commonFunc()
        }
        #else
        return commonFunc()
        #endif
    }

    func onCancel() {
        cancel()
    }

    func onDone() {
        exit()
    }

    func onRetry() {
        retry()
    }

    func onGoToAlbum() {
        progressVC?.dismiss(animated: false, completion: nil)
        AppViewControllerManager.gotoAlbum()
    }
}

extension ExportSessionViewController: WLVDBDynamicRequestDelegate {
    func onGetPlayURL(_ url: String?, time: Double, tag: Int32) {
        guard let url = url else {
            Log.error("Get nil play url")
            return
        }
        Log.info("Get play url: \(url)")
        if tag == 1000 {
            playUrl?.succeed(url)
        }
    }
}

extension ExportSessionViewController: PassThroughViewDelegate {
    func shouldPassHit(_ point: CGPoint, with event: UIEvent?) -> Bool {
        isTouched = true
        return true
    }
}

private class VideoRotationUtil {
    typealias RotationHandler = (Bool) -> Void
    private var rotationButton: UIButton? = nil

    private(set) var facedown: Bool = false

    var rotationHandler: RotationHandler

    init(rotationHandler: @escaping RotationHandler) {
        self.rotationHandler = rotationHandler
    }

    func addRotationButton(to containerView: UIView) {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.setTitle("↻", for: UIControl.State.normal)
        button.addTarget(self, action: #selector(rotationButtonTapped(_:)), for: UIControl.Event.touchUpInside)

        containerView.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        button.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true

        rotationButton = button
    }

    func showRotationButton() {
        rotationButton?.isHidden = false
    }

    func hideRotationButton() {
        rotationButton?.isHidden = true
    }

    @objc private func rotationButtonTapped(_ sender: UIButton) {
        facedown = !facedown
        rotationHandler(facedown)
    }

}

class StreamPickerViewLayout: ItemPickerViewLayout {

    func layout(titleLabel: UILabel, scrollView: UIScrollView, itemViews: [UIView]) {
        guard titleLabel.superview === scrollView.superview, let containingView = titleLabel.superview else {
            return
        }

        let margin: CGFloat = 28.0

        let layoutFrameDivider = RectDivider(rect: containingView.bounds.inset(by: UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: margin)))

        titleLabel.sizeToFit()

        titleLabel.frame = layoutFrameDivider.divide(atDistance: titleLabel.frame.height, from: CGRectEdge.minYEdge)

        // padding
        layoutFrameDivider.divide(atDistance: 21.0, from: CGRectEdge.minYEdge)

        scrollView.frame = layoutFrameDivider.remainder

        var layoutedItemViews: [UIView] = []

        let itemViewHeight: CGFloat = 30.0
        let maxItemViewWidth: CGFloat = scrollView.frame.width
        let padding: CGFloat = 16.0

        for (i, itemView) in itemViews.enumerated() {
            itemView.sizeToFit()
            itemView.frame.size.height = itemViewHeight
            itemView.frame.size.width += 50.0

            itemView.frame.size.width = min(itemView.frame.width, maxItemViewWidth)

            itemView.layer.cornerRadius = 4.0

            if let lastLayoutedItemView = layoutedItemViews.last {
                if i == 1 {
                    itemView.frame.origin = CGPoint(x: 0.0, y: lastLayoutedItemView.frame.maxY + padding)
                }
                else {
                    itemView.frame.origin = CGPoint(x: lastLayoutedItemView.frame.maxX + padding, y: lastLayoutedItemView.frame.minY)

                    if itemView.frame.maxX > scrollView.bounds.width { // wrap
                        itemView.frame.origin = CGPoint(x: 0.0, y: lastLayoutedItemView.frame.maxY + padding)
                    }
                }
            }
            else {
                itemView.frame.origin = CGPoint.zero
            }

            layoutedItemViews.append(itemView)
        }

        if let lastLayoutedItemView = layoutedItemViews.last {
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: lastLayoutedItemView.frame.maxY)
        }
    }

}

