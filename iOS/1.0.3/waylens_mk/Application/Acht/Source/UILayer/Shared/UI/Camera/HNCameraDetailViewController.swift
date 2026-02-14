//
//  HNCameraDetailViewController.swift
//  Acht
//
//  Created by Chester Shen on 7/7/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
#if useMixpanel
import Mixpanel
#endif
import WaylensPiedPiper
import SVProgressHUD
import AVKit
import WaylensFoundation
import WaylensCameraSDK

enum HNVideoSource {
    case sdcard
    case cloud
    
    var title: String {
        switch self {
        case .sdcard:
            return NSLocalizedString("SD Card", comment: "SD Card")
        case .cloud:
            return NSLocalizedString("Cloud", comment: "Cloud")
        }
    }
}

struct ThumbnailTransition {
    var fromImage: UIImage?
    var toImage: UIImage?
    func mergedImage(progress:CGFloat) -> UIImage? {
        if fromImage != nil && toImage == nil {
            return fromImage
        }
        if fromImage == nil && toImage != nil {
            return toImage
        }
        if fromImage == nil && toImage == nil {
            return nil
        }
        let size = fromImage!.size
        UIGraphicsBeginImageContext(size)
        let frame = CGRect(origin: CGPoint.zero, size: size)
        fromImage!.draw(in: frame)
        toImage!.draw(in: frame, blendMode: .normal, alpha: progress)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

private extension HNCameraDetailViewController {
    func add(viewController : UIViewController , asChildViewController childController : UIViewController , direction : UIView.AnimationOptions) -> Void {
        viewController.addChild(childController)
        UIView.transition(with: viewController.view, duration: 0.3, options: direction, animations: {
            [viewController] in
            viewController.view.addSubview(childController.view)
        }, completion: nil)
        childController.view.frame = viewController.view.bounds
        childController.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        childController.didMove(toParent: viewController)
    }
    
    func remove(asChildViewController childController: UIViewController) -> Void {
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }
}
class HNCameraDetailViewController: BaseViewController,
                                    HNPlayerPanelDelegate,
                                    CameraTimeLineDataSourceDelegate,
                                    WLVDBDynamicRequestDelegate,
                                    CameraRelated
{
    @IBOutlet weak var reportView: ButtonCustomMK!
    @IBOutlet weak var viewContainerConfigCameraMK: UIView!
    @IBOutlet weak var stackInfoCameraView: UIStackView!
    @IBOutlet weak var heightInfoView: NSLayoutConstraint!
    @IBOutlet weak var dataMemorySDView: ButtonCustomMK!
    @IBOutlet weak var informationBasicView: ButtonCustomMK!
    @IBOutlet weak var configurationView: ButtonCustomMK!
    @IBOutlet weak var checkSimCardView: ButtonCustomMK!
    @IBOutlet weak var loginFaceMKButton: UIButton!
    @IBOutlet weak var checkLoginCamera: ButtonCustomMK!
    @IBOutlet weak var playerContainer: UIView!
    @IBOutlet weak var timelineViewContainer: UIView!
    @IBOutlet weak var filterBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var portraitPlaySourceViewContainer: UIView!
    @IBOutlet weak var playerContainerTopConstraint: NSLayoutConstraint!
    
    var actionBar: HNActionBar?
    var clipInfoBar: ClipInfoBar?
    var timeLineHorizontalView: CameraTimeLineHorizontalView?
    var timeLineVerticalView: CameraTimelineVerticalViewController?
    var playerPanel = PlayerPanelCreator.createDefaultPlayerPanel()
    let localModel = CTLLocalDataSource()
    let cloudModel = CTLCloudDataSource()
    var sources = [HNVideoSource]()
    var dataModel: CameraTimeLineDataSource {
        return isLocalSource ? localModel : cloudModel
    }
    var startPlayTime: Double = 0
    var currentRawClipStartTime: Double = 0
    var startError = TimeInterval(0.0)
    var scrollTimer: Timer?
    var lastThumbnailRequestTime: Date?
    let scrollTimerInterval = 0.1
    let requestThumbnailInterval = 0.1
    var userSelectedIndex: IndexPath?
    var nextClipToPlay: HNClip?
    var storageStateObservation: NSKeyValueObservation?
    var dmsFaceList : DMSFaceIDList?
    var timer: Timer?
    var isTapDataMemorySDView = false
    var isCheckLoginCamera: Bool = false
    private weak var filterVC: VideoFilterViewController?
    private lazy var highlightController = HNCameraDetailHighlightController(cameraDetailViewController: self)
    private enum TimelineSource {
        case `default`
        case player
        case timeline
    }
    private var timelineSource: TimelineSource = .default
    private var userPausedOnCurrentTime: Bool = false
    private var cameraPickerButton: DropDownArrowButton?
    fileprivate var isCameraPickerEnabled: Bool = false
#if !FLEET
    private var voiceController: VoiceController? = nil
    private var triggerVoiceTimer: Timer? = nil
    private lazy var microphoneStatusView = MicrophoneStatusView.createFromNib()!
#endif
    private var hideShowBarsLogic: HNCameraDetailHideShowBarsLogic? = nil
    private var isFirstAppearance: Bool = true
    private var streamIndex = Int32(0)
    deinit {
        NotificationCenter.default.removeObserver(self)
        //        playerPanel.timeLineHorizontalView = nil
    }
    private var consideredAs4GOnline: Bool {
        guard let camera = camera else { return false }
#if FLEET
        return (UserSetting.shared.debugEnabled && camera.remote != nil && camera.supports4g) && UserSetting.shared.server == .dev
#else
        return (UserSetting.shared.debugEnabled && camera.remote != nil && camera.supports4g) && UserSetting.shared.server == .shanghai
#endif
    }
    
    private var currentTime: Date? {
        get {
            return currentPos?.date
        }
        set {
            currentPos?.date = newValue
            updateTime(newValue)
        }
    }
    private var currentPos: CameraTimelinePosition? {
        didSet {
            updateTime(currentTime)
        }
    }
    weak var timeline: CameraTimeline? {
        didSet {
            updateTimelineSource()
        }
    }
    var isVisible: Bool = false
    @objc var camera: UnifiedCamera? {
        didSet {
            if !isViewLoaded { return }
            if camera != oldValue {
                playerPanel.shutdown()
                reset()
            }
            updateCamera()
        }
    }
    var isLocalSource: Bool = true {
        didSet {
            if sources.count == 0 {
                timeline?.dataSource = nil
            } else {
                timeline?.dataSource = dataModel
            }
        }
    }
    private var typeFilter: HNVideoOptions = [] {
        didSet {
            if typeFilter == [] {
                localModel.filter = nil
                cloudModel.filter = nil
            } else {
                localModel.filter = typeFilter
                cloudModel.filter = typeFilter
            }
            var icon: UIImage?
            switch typeFilter {
            case .motion:
                icon = #imageLiteral(resourceName: "event_motion_selected_shadow")
            case .hit:
                icon = #imageLiteral(resourceName: "event_bump_selected_shadow")
            case .heavy:
                icon = #imageLiteral(resourceName: "event_impact_selected_shadow")
            case .manual:
                icon = #imageLiteral(resourceName: "event_highlight_selected_shadow")
            case .behavior:
                icon = #imageLiteral(resourceName: "behavior selected shadow")
            case .dms:
                icon = #imageLiteral(resourceName: "dms-event-filter-selected")
            case .adas:
                icon = #imageLiteral(resourceName: "adas-event-filter-selected")
            case .buffered:
                icon = #imageLiteral(resourceName: "buffered_selected")
            case []:
                icon = #imageLiteral(resourceName: "funnel_button")
            default:
                icon = #imageLiteral(resourceName: "funnel_button_selected")
            }
            filterButton?.setImage(icon, for: .normal)
        }
    }
    var guideVC: GuideCameraDetailViewController?
    lazy var playSourceView: SourceMenu = { [weak self] in
        let menu = SourceMenu()
        menu.isUserInteractionEnabled = false
        menu.addTarget(self, action: #selector(onSourceChanged(_:)), for: .valueChanged)
        return menu
    }()
    static func createViewController(camera: UnifiedCamera?, dateScrollTo: Date? = nil, isCameraPickerEnabled: Bool = false, isCheckLoginCamera: Bool = false) -> HNCameraDetailViewController {
        let vc = UIStoryboard(name: "CameraDetail", bundle: nil).instantiateViewController(withIdentifier: "HNCameraDetailViewController") as! HNCameraDetailViewController
        if let camera = camera {
            vc.isLocalSource = (camera.viaWiFi == true)
        }
        else {
            vc.isLocalSource = true
        }
        vc.camera = camera
        vc.isCameraPickerEnabled = isCameraPickerEnabled
        vc.isCheckLoginCamera = isCheckLoginCamera
        
        if let dateScrollTo = dateScrollTo {
            vc.currentPos = CameraTimelinePosition(isLive: false, date: dateScrollTo)
        }
        return vc
    }
    @IBAction func loginFaceMKButton(_ sender: Any) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
            // print("clicked button")
            
            if let image =  self.playerPanel.videoPlayer?.getRawImageView().image {
                
                let controller =  LoginFaceMKViewController(nibName: "LoginFaceMKViewController", bundle: nil)
                controller.image = image
                controller.camera = self.camera
                self.add(viewController: self, asChildViewController: controller, direction: .allowAnimatedContent)
                //
            }
        })
    }
    
    func setViewTimeline() {
        if self.isTapDataMemorySDView {
            self.timelineViewContainer.isHidden = false
            self.viewContainerConfigCameraMK.isHidden = true
            playerPanel.hideDMSFaceButton(hide: true)
        } else {
            self.stopPlayback()
            timeline?.scrollToLive(animated: true)
            playerPanel.hideDMSFaceButton(hide: false)
            self.timelineViewContainer.isHidden = true
            self.viewContainerConfigCameraMK.isHidden = false
            if isCheckLoginCamera {
                self.viewContainerConfigCameraMK.isHidden = true
                self.filterButton.isHidden = true
            }
        }
    }
    
    func configBtnLoginFaceMKButton() {
        
        self.loginFaceMKButton.layer.cornerRadius = 8
        self.loginFaceMKButton.layer.masksToBounds = true
        loginFaceMKButton.addShadow(offset: CGSize(width: 3, height: 4))
        loginFaceMKButton.semanticContentAttribute = .forceLeftToRight
        let smsImage  = UIImage(named: "icon_face")!
        self.loginFaceMKButton.addLeftIcon(image: smsImage)
        self.loginFaceMKButton.backgroundColor = UIColor.color(fromHex: ConstantMK.blueButton)
    }
    func configGrayButtonMK() {
        configBtnLoginFaceMKButton()
        
        self.checkLoginCamera.setBorderView()
        self.dataMemorySDView.setBorderView()
        self.informationBasicView.setBorderView()
        self.configurationView.setBorderView()
        self.checkSimCardView.setBorderView()
        self.reportView.setBorderView()
        
        self.setFontButtonView([checkLoginCamera,dataMemorySDView,informationBasicView,configurationView
                               ,checkSimCardView,reportView])
        
        self.dataMemorySDView.setTitle(str: "Xem lại video", imageStr: "icon_video")
        self.dataMemorySDView.setTitleColorAndImageColor(color: UIColor.color(fromHex: "#4D5966"))
        self.informationBasicView.setTitle(str: "Thông tin cơ bản", imageStr: "icon_info_camera")
        self.informationBasicView.setTitleColorAndImageColor(color: UIColor.color(fromHex: "#4D5966"))
        self.checkSimCardView.setTitle(str: "Kiểm tra thẻ sim", imageStr: "icon_sim")
        self.checkSimCardView.setTitleColorAndImageColor(color: UIColor.color(fromHex: "#4D5966"))
        self.configurationView.setTitle(str: "Cấu hình", imageStr: "icon_qrcode")
        self.configurationView.setTitleColorAndImageColor(color: UIColor.color(fromHex: "#4D5966"))
        self.reportView.setTitle(str: "Xem báo cáo", imageStr: "icon_view_report")
        self.reportView.setTitleColorAndImageColor(color: UIColor.color(fromHex: "#4D5966"))
        
        self.checkLoginCamera.setTitle(str: "Cài đặt đăng nhập", imageStr: "icon_setting")
        self.checkLoginCamera.setTitleColorAndImageColor(color: UIColor.color(fromHex: "#4D5966"))
        
        self.dataMemorySDView.addTapGesture {
            self.isTapDataMemorySDView.toggle()
            self.setViewTimeline()
        }
        self.configurationView.addTapGesture {
//            let vc = HNCameraSettingViewController.createViewController()
//            vc.camera = UnifiedCameraManager.shared.local
            let vc = UIStoryboard(name: "CameraSettings", bundle: nil).instantiateViewController(withIdentifier: "MKCameraSettingVC") as! MKCameraSettingVC
            vc.camera = UnifiedCameraManager.shared.local
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.reportView.addTapGesture {
            let vc = GetLogViewController(nibName: "GetLogViewController", bundle: nil)
            vc.camera = UnifiedCameraManager.shared.local
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.informationBasicView.addTapGesture {
            let vc = InfoBasicCameraViewController()
            vc.camera = UnifiedCameraManager.shared.local
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.checkSimCardView.addTapGesture {
            let vc = SimDataViewController(nibName: "SimDataViewController", bundle: nil)
            vc.camera = UnifiedCameraManager.shared.local
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.checkLoginCamera.addTapGesture {
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
                let controller =  AlertCustomMKViewController(nibName: "AlertCustomMKViewController", bundle: nil)
                controller.camera = self.camera
                self.add(viewController: self, asChildViewController: controller, direction: .allowAnimatedContent)
            })
        }
    }
    
    func setFontButtonView(_ views : [ButtonCustomMK]){
        views.forEach { view in
            view.setFontTitle(UIFont(name: "BeVietnamPro-Regular", size: 14.0)!)
        }
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if isFirstAppearance {
            return .portrait
        }
        else {
#if FLEET
            if highlightController.doneSavingAnimator?.isAnimating == true {
                return .portrait
            }
#else
            if highlightController.doneSavingAnimator?.isAnimating == true {
                return .portrait
            }
            if let voiceController = voiceController, !voiceController.status.isIdle {
                return .portrait
            }
#endif
            
            if (presentedViewController as? UINavigationController)?.viewControllers.first is CameraPickerViewController {
                return .portrait
            }
            return .allButUpsideDown
        }
    }
    override var prefersStatusBarHidden: Bool {
        hideShowBarsLogic?.prefersStatusBarHidden ?? false
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        hideShowBarsLogic?.preferredStatusBarUpdateAnimation ?? .slide
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        get {
            return playerPanel.fullScreen
        }
    }
    private func showMsgWithCode(code : Int,  msg : String) -> String {
        if (code == 1000) {
            return "Lỗi định dạng json"
        } else if (code == 1001) {
            return "Lỗi,json rỗng"
        }else if(code == 1002){
            return "Lỗi, không thể xóa faceId trong dữ liệu xe"
        } else if (code == 1010) {
            return "Lỗi, không tìm thấy tài xế"
        } else if (code == 1100) {
            return "Lỗi, không tìm thấy cameraSn trong dữ liệu xe"
        } else if (code == 1101) {
            return "Lỗi, không thể xóa tài xế cũ trong dữ liệu xe"
        } else if (code == 1011) {
            return "Lỗi, tài xế và camera không khớp"
        }else if (code == 1110) {
            return "Lỗi, không thể thêm faceId vào dữ liệu xe"
        }else if (code == 1111) {
            return "Lỗi, không thể thêm faceId vào dữ liệu tài xế"
        } else if (code == 3333) {
            return "Lỗi, không nhận được thông tin từ FMS"
        }else if (!msg.isEmpty) {
            return msg;
        } else {
            return "Lỗi không xác định"
        }
    }
    @objc func showResultFaceData(_ notification: NSNotification) {
        self.hideProgress()
        if let code =  notification.userInfo?["code"] as? Int {
            if code == 2000 {
                if let data = notification.userInfo?["data"] as? [String: Any] {
                    if let driverName = data["driver_name"] as?  String {
                        let userInfo = ["driverName" : driverName]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addFaceDataCam"), object: nil, userInfo: userInfo)
                    }
                    return
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:  "removeFaceDataCam"), object: nil, userInfo: nil)
                    self.alert(title: "Thông báo", message: "Xóa face thành công")
                    return
                }
            } else {
                self.dismiss(animated: true, completion: {
                    if let msg = notification.userInfo?["msg"] as?  String  {
                        
                        let alert = UIAlertController(title: "Thông báo", message:  NSLocalizedString(self.showMsgWithCode(code : code,  msg : msg), comment: msg), preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (_) in
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                })
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timelineViewContainer.isHidden = true
        configGrayButtonMK()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showResultFaceData(_:)), name: NSNotification.Name(rawValue: "msgDataFW"), object: nil)
        localModel.delegate = self
        cloudModel.delegate = self
        view.setNeedsLayout()
        view.layoutIfNeeded()
        playerPanel.addToParentViewController(self, superView: playerContainer)
        playerPanel.delegate = self
        playerPanel.controlView.recordingSwitches.addTarget(self, action: #selector(recordingSwitchValueChanged(_:)), for: .valueChanged)
        timeLineVerticalView = CameraTimelineVerticalViewController.createViewController()
        timeLineVerticalView?.addToParentViewController(self, superView: timelineViewContainer)
        timeLineVerticalView?.delegate = self
        timeline = timeLineVerticalView
        timelineViewContainer.bringSubviewToFront(filterButton)
        playerPanel.hideDMSFaceButton(hide: false)
#if FLEET
        clipInfoBar = ClipInfoBar.createFromNib()
        clipInfoBar?.showInfoHandler = { [weak self] in
            if self?.presentedViewController is ActionSheetController {
                self?.presentedViewController?.dismissMyself(animated: true)
            }
            self?.cancelSelection()
            self?.showEventLegend()
        }
        clipInfoBar?.heightAnchor.constraint(equalToConstant: 16.0).isActive = true
#else
        actionBar = HNActionBar()
        timelineViewContainer.addSubview(actionBar!)
        actionBar!.frame = CGRect(x: 0, y: timelineViewContainer.bounds.height - 125, width: timelineViewContainer.bounds.width, height: 125)
        actionBar!.autoresizingMask = [.flexibleTopMargin]
        actionBar!.delegate = self
#endif
        if isCameraPickerEnabled {
            initCameraPickerButton()
        }
        cloudModel.specifiedDateForFetchingData = currentPos?.date
        reset(needsResetPosition: false)
        updateCamera()
        updateRecentThumbnail()
        if self.isCheckLoginCamera {
            self.filterButton.isHidden = true
            self.isTapDataMemorySDView.toggle()
            self.setViewTimeline()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isVisible = true
        camera?.local?.vdbClient.delegate = self
        timelineSource = .default
        self.hideNavigationBar(animated: animated)
        refreshUI()
        self.showNavigationBar(animated: animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showResult(_:)), name: NSNotification.Name(rawValue: "msg_MOC_method"), object: nil)
        func commonFunc() {
            if isFirstAppearance {
                let asLandscape = UIWindow.isLandscape
                if UIDevice.current.orientation.isLandscape != asLandscape {
                    onFullScreen(asLandscape)
                } else {
                    layout(asLandscape: asLandscape)
                }
            }
        }
#if FLEET
        if
            !AccountControlManager.shared.isLogin
        {
            let asLandscape = UIWindow.isLandscape
            if UIDevice.current.orientation.isLandscape != asLandscape {
                onFullScreen(asLandscape)
            } else {
                layout(asLandscape: asLandscape)
            }
        }
        else {
            commonFunc()
        }
#else
        commonFunc()
#endif
        timeline?.reloadData()
        initHideShowBarsLogic()
        hideShowBarsLogic?.viewWillAppear()
        showSettingButtonIfNeeded()
        
        applyTheme()
    }
    @objc func showResult(_ notification: NSNotification) {
        if let result = notification.userInfo?["MOC"] as? String {
            // do something with your image
            if result == "mobile" {
                loginFaceMKButton.isHidden = false
            } else {
                loginFaceMKButton.isHidden = true
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onLiveMark), name: Notification.Name.Local.liveMark, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onRecordStateChanged), name: Notification.Name.Local.recordState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleAppDidEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
#if !FLEET
        if GuideHelper.shouldContinueCameraDetailUIGuide {
            showGuide()
        }
        if !(guideVC?.isPresented ?? false) {
            checkServer()
        }
#endif
        isFirstAppearance = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationController?.topViewController != self {
            hideShowBarsLogic?.viewWillDisappear()
        }
        if playerPanel.playState == .playing || playerPanel.playState == .buffering {
            userPausedOnCurrentTime = true
        }
        stopLive()
        stopPlayback()
        guideVC?.dismiss(animated: false)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.Local.liveMark, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.Local.recordState, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isVisible = false
        shutdown()
        if isMovingFromParent {
            reset()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hideShowBarsLogic?.viewDidLayoutSubviews()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        hideShowBarsLogic?.viewWillTransition(to: size, with: coordinator)
        super.viewWillTransition(to: size, with: coordinator)
        cancelSelection()
        let isLandscape = UIWindow.isLandscape
        if (isLandscape == false) && (size.width > size.height) { return }
        layout(asLandscape: isLandscape)
        if (isLandscape) {
            if guideVC?.isPresented ?? false {
                guideVC?.dismiss(animated: false)
            }
        } else {
            perform(#selector(showGuide), with: nil, afterDelay: 0.5)
        }
    }
    override func viewSafeAreaInsetsDidChange() {
        var safeSpace:CGFloat = 20
        if #available(iOS 11, *) {
            safeSpace = max(safeSpace - view.safeAreaInsets.bottom, 0)
        }
        filterBottomSpace.constant = safeSpace
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        if (timeLineHorizontalView != nil) && !(timeLineHorizontalView!.isDisplaying) {
            playerPanel.timeLineHorizontalView = nil
            timeLineHorizontalView = nil
        }
    }
    override func applyTheme() {
        super.applyTheme()
        view.backgroundColor = .white//UIColor.semanticColor(.background(.septenary))
        hideShowBarsLogic?.applyTheme()
    }
    func showTimeLineHorizontalView() {
        hideTimeLineVerticalView()
        if timeLineHorizontalView == nil {
            timeLineHorizontalView = CameraTimeLineHorizontalView(frame: CGRect.zero)
            timeLineHorizontalView?.translatesAutoresizingMaskIntoConstraints = false
            timeLineHorizontalView?.backgroundColor = UIColor.clear
            timeLineHorizontalView?.delegate = self
            playerPanel.timeLineHorizontalView = timeLineHorizontalView
        }
        timeLineHorizontalView?.isHidden = false
        timeline = timeLineHorizontalView
        timeline?.dataSource = dataModel
    }
    func hideTimeLineHorizontalView() {
        timeLineHorizontalView?.isHidden = true
    }
    func showTimeLineVerticalView() {
        if timeLineVerticalView?.view.isHidden ?? false {
            MixpanelHelper.track(event: "show timeLineVerticalView")
        }
        hideTimeLineHorizontalView()
        self.timeLineVerticalView?.view.isHidden = false
        if (self.timelineViewContainer.isHidden == false){
            self.viewContainerConfigCameraMK?.isHidden = true
            
        }else{
            self.viewContainerConfigCameraMK?.isHidden = false
            if isCheckLoginCamera {
                self.viewContainerConfigCameraMK?.isHidden = true
                self.filterButton.isHidden = true
            }
        }
        timeline = timeLineVerticalView
        timeline?.dataSource = dataModel
    }
    func hideTimeLineVerticalView() {
        self.timeLineVerticalView?.view.isHidden = true
        self.viewContainerConfigCameraMK?.isHidden = true
    }
    @objc func showGuide() {
        if guideVC == nil {
            guideVC = GuideCameraDetailViewController.createViewController()
        }
        guideVC?.presentIn(self, animated: true)
    }
#if !FLEET
    private func checkServer() {
        guard camera?.supports4g == true else {
            return
        }
        var isServersMismatched = false
        if let address = camera?.local?.serverAddress {
            if AppConfig.CameraServer(rawValue: address)?.isPaired(with: UserSetting.shared.server) == false {
                isServersMismatched = true
            }
        }
        if isServersMismatched {
            let server = UserSetting.shared.server.pairedCameraServer
            let alert = UIAlertController(
                title: NSLocalizedString("Mismatched Camera Server", comment: "Mismatched Camera Server"),
                message: String(format: NSLocalizedString("switch camera server to %@ and reboot?", comment: "switch camera server to %@ and reboot?"), server.displayName),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .default, handler: { [weak self] (_) in
                self?.camera?.local?.setCameraServer(address: server.rawValue)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                    self?.camera?.local?.reboot()
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
#endif
    private func reset(needsResetPosition: Bool = true) {
        dmsFaceList?.tabView?.removeFromSuperview()
        dmsFaceList = nil
        playerPanel.reset()
        cancelSelection()
        if needsResetPosition {
            currentPos = nil
        }
        timelineSource = .default
        sources.removeAll()
        localModel.camera = nil
        cloudModel.camera = nil
    }
    private func updateTimelineSource() {
        if timeline?.scrollMode.isActive ?? false {
            timelineSource = .timeline
        } else if playerPanel.playState == .playing {
            timelineSource = .player
        } else {
            timelineSource = .default
        }
    }
    private func updateCamera() {
        guard let camera = camera else { return }
        Log.info("Camera updated, to sn:\(camera.sn), hasLocal:\(camera.local != nil), \(camera)")
        Log.info("Camera updated, to sn:\(camera.sn), hasLocal:\(camera.local != nil), \(camera)")
        localModel.camera = camera
        cloudModel.camera = camera
        if camera.model?.hasPrefix("SAXHORN_") ?? false || camera.model?.hasPrefix("SH_") ?? false {
            timeLineVerticalView?.layout.bufferedRatio = 3.0
        }
        if camera.model?.hasPrefix("LONGHORN_") ?? false || camera.model?.hasPrefix("LH_") ?? false {
            timeLineVerticalView?.layout.bufferedRatio = 3.0
        }
        let wasLocalSource = isLocalSource
        let previousLiveSource = playSourceView.items.first
        sources.removeAll()
        if camera.viaWiFi {
            sources.append(.sdcard)
        }
#if !FLEET
        if camera.supports4g {
            sources.append(.cloud)
        }
#endif
        if sources.count == 0 {
            sources.append(.sdcard)
        }
        var items: [SourceMenuItemType] = []
        if camera.viaWiFi {
            items.append(.localLive)
        } else if camera.via4G || consideredAs4GOnline {
            items.append(.remoteLive(camera.cellSignalStatus))
        } else {
            items.append(.offline)
        }
        sources.forEach { (videoSource) in
            switch videoSource {
            case .sdcard:
                items.append(.localPlayback)
            case .cloud:
                items.append(.remotePlayback)
            }
        }
        playSourceView.items = items
        isLocalSource = sources.contains(.sdcard)
        refreshUI()
        let currentLiveSource = items.first
        if currentPos?.isLive ?? false && currentLiveSource != previousLiveSource {
            stopLive()
            timelineSource = .default
        }
        if isLocalSource != wasLocalSource {
            onSourceChanged(nil)
        }
        if camera.viaWiFi {
            storageStateObservation = camera.local?.observe(\.storageState) { [weak self] (this, change) in
                Log.info("SD Card State is \(this.storageState.rawValue)")
                self?.timeline?.reloadData()
            }
        } else {
            storageStateObservation = nil
        }
        camera.local?.vdbClient.delegate = self
        playerPanel.supportViewMode = camera.needDewarp
    }
    private func refreshUI() {
        if isCameraPickerEnabled {
            cameraPickerButton?.title = camera?.name ?? NSLocalizedString("Camera", comment: "Camera")
        } else {
            //   navigationItem.title = camera?.name ?? NSLocalizedString("Camera", comment: "Camera")
            navigationItem.title = camera?.sn ?? NSLocalizedString("Camera", comment: "Camera")
        }
        timeline?.refreshUI()
        if isLocalSource {
            updateUIForRecordingState()
        }
        if camera == nil {
            filterButton.isHidden = true
            playSourceView.isHidden = true
        }
        else {
            filterButton.isHidden = false
            playSourceView.isHidden = false
            if isCheckLoginCamera {
                filterButton.isHidden = true
            }
        }
    }
    private func initCurrentPosition() {
        currentPos = CameraTimelinePosition(isLive: true, date: nil)
    }
    func timelineSetPosition(_ pos: CameraTimelinePosition) {
        if pos.isLive {
            timeline?.scrollToLive(animated: false)
        } else if let date = pos.date {
            timeline?.scrollTo(time: date)
        }
    }
    func playerEndSeeking() {
        guard timelineSource != .player, !playerPanel.isPlayingOrPreparing() else {
            return
        }
        playerOnSeeking()
        if let clip = nextClipToPlay {
            playClip(clip)
        } else if !userPausedOnCurrentTime {
            playCurrentLine()
        }
    }
    func playerOnSeeking() {
        guard let timeline = timeline, currentPos != nil else { return }
        let (index, time, segment) = timeline.currentIndexInfo()
        // update current position
        if index == nil {
            Log.debug("index is nil")
        }
        currentPos!.isLive = index == nil
        if let date = segment?.clip?.startDate, time >= 0 {
            currentTime = Date(timeInterval: time, since: date)
        }
        playerPanel.showResolutionButton(segment?.clip?.rawClip?.streamNum ?? Int32(1) > Int32(1),
                                         streams: segment?.clip?.rawClip?.resolutions)
        // player control & UI update between live / playback
        if timeline.isCrossingLiveButton() {
            playLive()
        } else {
            if playerPanel.playSource.isLive && playerPanel.isPlayingOrPreparing() {
                stopLive()
            }
            if index != nil {
                let playSource: HNPlaySource = isLocalSource ? .localPlayback : .remotePlayback
                if playerPanel.playSource != playSource {
                    playerPanel.playSource = playSource
                }
            }
        }
        // UI update for thumbnail
        // update preview blurrness
        if time < 0 {
            let offset = timeline.lineOffset
            if let seg = segment {
                var level: CGFloat!
                if index == nil && !(camera?.viaWiFi ?? false) {
                    level = min(min(10, seg.maxOffset - offset) / 10, 1)
                } else {
                    level = min(min(offset - seg.minOffset, seg.maxOffset - offset) / 10, 1)
                }
                playerPanel.setBlurred(level)
            }
        } else if time == 0 && index == nil {
            if (playerPanel.playSource == .localLive ||
                (playerPanel.playSource == .remoteLive &&
                 (playerPanel.playState == .playing || playerPanel.playState == .buffering))) {
                playerPanel.setBlurred(0)
            } else {
                playerPanel.setBlurred(1)
            }
        } else {
            if playerPanel.playState != .buffering {
                playerPanel.setBlurred(0)
            }
        }
        
        if time >= 0, let clip = segment?.clip {
            if timelineSource == .timeline {
                playerPanel.showTimePointInfo(HNTimePointInfo(date: currentTime!, clip: clip)) // TODO: move time point overlay to timeline
                // update thumbnail
                tryUpdateThumbnail(clip: clip, time: time)
            }
        }
    }
    @objc func openSetting() {
        let vc = HNCameraSettingViewController.createViewController()
        vc.camera = camera
        self.navigationController?.pushViewController(vc, animated: true)
    }
    private func playClip(_ clip:HNClip?, playTime:Double=0) {
        guard let clip = clip else {
            print("clip not found")
            return
        }
        let playSource: HNPlaySource = isLocalSource ? .localPlayback : .remotePlayback
        if playerPanel.playSource != playSource {
            playerPanel.playSource = playSource
        }
        startPlayTime = playTime
        playerPanel.duration = clip.duration
        playerPanel.startDate = clip.startDate
        if let rawClip = clip.rawClip {
            playerPanel.playState = .buffering
            currentRawClipStartTime = rawClip.startTime
            if rawClip.isMP4(forStream: streamIndex) {
                camera?.local?.clipsAgent.vdb?.getMP4(forClip: rawClip.clipID,
                                                      in: WLVDBDomain(rawValue: UInt32(rawClip.clipType)),
                                                      from: rawClip.startTime + playTime,
                                                      length: 30*60.0,
                                                      stream: streamIndex,
                                                      withTag: 1000,
                                                      andID: rawClip.vdbID)
            } else {
                camera?.local?.clipsAgent.vdb?.getHLSForClip(rawClip.clipID,
                                                             in: WLVDBDomain(rawValue: UInt32(rawClip.clipType)),
                                                             from: rawClip.startTime + playTime,
                                                             length: 30*60.0,
                                                             stream: streamIndex,
                                                             withTag: 1000,
                                                             andID: rawClip.vdbID)
            }
            playerPanel.setFacedown(rawClip.isRotated)
            // TODO: manage url response in a closure
        } else {
            playerPanel.setFacedown(clip.facedown)
            playerPanel.playVideo(clip.url, playbackTime: startPlayTime, startOffset: 0)
        }
    }
    private func playLive(manual:Bool=false) {
        guard let camera = camera else {
            return
        }
        if camera.viaWiFi {
            if playerPanel.isPlayingOrPreparing(.localLive) {
                let isRecording = (camera.local?.recState == .recording)
                if playerPanel.isLocalRecording == isRecording {
                    return
                }
            }
            // Update playerPanel's viewMode to the right mode, especially in this scene, from playing 360 degrees fish-eye video clip to normal video live.
            playerPanel.supportViewMode = camera.needDewarp
            
            playerPanel.setFacedown(camera.facedown)
            playerPanel.playLocalLive(camera.local?.getLivePreviewAddress(),
                                      isRecording: camera.local?.recState == .recording)
            camera.local?.liveDataMonitor?.start(gps: true, dms: true)
            camera.local?.liveDataMonitor?.delegate = self
        } else if camera.via4G || consideredAs4GOnline {
            if manual {
                if playerPanel.isPlayingOrPreparing(.remoteLive) {
                    return
                }
                playerPanel.playSource = .remoteLive
                playerPanel.playState = .buffering
                camera.remote?.startLive(completion: { [weak self] (result) in
                    if result.isSuccess {
                        camera.remote?.getLiveStatus(progress: { (status) in
                            self?.playerPanel.updateStatusOverlay(withLiveStatus: status)
                            if let this = self, status == .streaming, let playUrl = camera.remote?.liveUrl  {
                                this.playerPanel.setFacedown(camera.facedown)
                                this.playerPanel.playRemoteLive(playUrl)
                                if this.playerPanel.refreshSpeedTimer == nil {
                                    this.playerPanel.refreshSpeedTimer = WLTimer(reference: this, interval: 1.0, repeat: true, block: { [weak this] in
                                        let kbps = (camera.remote?.uploadingSpeedBitps ?? 0) / 8000
                                        this?.playerPanel.refreshSpeed(kbps: kbps)
                                        // refresh sigal status
                                        this?.playSourceView.selectedItem = .remoteLive(camera.cellSignalStatus)
                                    })
                                }
                            } else if let this = self, status.shouldStop {
                                this.playerPanel.stop()
                                camera.remote?.stopLive()
                            }
                        })
                    } else {
                        HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Live stream failed", comment: "Live stream failed"))
                        self?.playerPanel.stop()
                        self?.playerPanel.playState = .error
                    }
                })
            } else { // need confirm to play
                if playerPanel.playSource != .remoteLive {
                    playerPanel.playSource = .remoteLive
                    playerPanel.playState = .unloaded
                }
            }
        } else {
            playerPanel.playSource = .offline
        }
    }
    func shutdown() {
        playerPanel.shutdown()
    }
    func stopLive() {
        if playerPanel.playSource == .localLive {
            playerPanel.stopLocalLive()
            camera?.local?.liveDataMonitor?.stop()
            camera?.local?.liveDataMonitor?.delegate = nil
        } else if playerPanel.playSource == .remoteLive {
            playerPanel.refreshSpeed(kbps: 0)
            playerPanel.refreshSpeedTimer?.stop()
            playerPanel.stop()
            camera?.remote?.stopLive()
            playerPanel.updateStatusOverlay()
        }
#if !FLEET
        triggerVoiceTimer?.invalidate()
        triggerVoiceTimer = nil
        
        if let camera = camera, let voiceController = voiceController, !voiceController.status.isIdle {
            voiceController.endStreaming(with: camera)
        }
#endif
    }
    func stopPlayback() {
        if playerPanel.playSource.isPlayback {
            playerPanel.stop()
        }
    }
    func play(index:IndexPath?, time: TimeInterval, manual:Bool=false) {
        if let currentIndex = index {
            guard let clip = dataModel.clipWithIndex(currentIndex) else { return }
            playerPanel.supportViewMode = clip.needDewarp
            if time < 0 {
                nextClipToPlay = clip
                timeline?.scrollToItem(at: currentIndex, animated: true)
            } else {
                playClip(clip, playTime: time)
            }
        } else {
            if timeline?.isInLivePositon ?? false {
                playLive(manual: manual)
            } else {
                timeline?.scrollToLive(animated: true)
            }
        }
    }
    func playCurrentLine(manual:Bool = false) {
        let (index, time, _) = timeline!.currentIndexInfo()
        if userSelectedIndex != nil && userSelectedIndex != index {
            cancelSelection()
        }
        play(index: index, time: time, manual: manual)
    }
    func playNext(bCloudVideo: Bool = false) {
        guard let timeline = timeline else { return }
        let isPlayingCloudVideo = playerPanel.playSource == .remotePlayback
        var delta = 0.1
        if isPlayingCloudVideo {
            delta = 1.0
        }
        let (index, time, clipSegment) = timeline.currentIndexInfo() // get clip segment from current line, maybe current one, maybe next one
        if let index = index, let clipSegment = clipSegment {
            if time <= 0 {
                play(index: index, time: 0)
            } else if time < clipSegment.duration - delta {
                play(index: index, time: time)
            } else if let endOffset = timeline.endOffsetForItem(at: index) { // time >= segment.duration -1, mean current clip plays to ends, will play next
                if (endOffset > 0) && !isPlayingCloudVideo  {
                    // if endoffset > 0, that means the current clip is not ended yet, go on playing.
                    play(index: index, time: time)
                } else {
                    // cloud videos will come here
                    // local videos should not come here in fact, it will go to case time<=0.
                    // even if come here, should not use endOffsetForItem, it should be timeline.lineOffset - 0.5.
                    // endoffset is the offset in this cell, not in the whole scrollview. It should be:
                    // let nextOffset = timeline.lineOffset - 0.5
                    // let (nextIndex, nextTime, _) = timeline.indexInfo(at: nextOffset)
                    // the current code is:
                    let (nextIndex, nextTime, _) = timeline.indexInfo(at: endOffset)
                    // Because it will not come here, do not change now.
                    play(index: nextIndex, time: nextTime)
                }
            }
        } else {
            play(index: index, time: time)
        }
    }
    func startScrollTimer() {
        if scrollTimer == nil {
            scrollTimer = Timer.scheduledTimer(timeInterval: scrollTimerInterval, target: self, selector: #selector(scrollTimelineToCurrentPlayTime), userInfo: nil, repeats: true)
        }
    }
    @objc func killScrollTimer() {
        guard scrollTimer != nil else { return }
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
    @objc func scrollTimelineToCurrentPlayTime() {
        guard timelineSource == .player else {
            return
        }
        if currentPos!.isLive {
            if playerPanel.playState == .playing {
                currentTime = Date()
            }
        } else if let startDate = playerPanel.startDate {
            currentTime = Date(timeInterval: playerPanel.currentPlayTime, since: startDate)
        }
        timelineSetPosition(currentPos!)
        
        handleUpdateRawData(self.timeline ?? nil, startError: startError)
    }
    func updateTime(_ time:Date? = nil, timeString:String? = nil) {
        timeline?.updateTime(time, timeString: timeString)
        if let time = time {
            playerPanel.showTime(time)
        }
    }
    func requestThumbnail(clip:HNClip, time:TimeInterval = 0, canBeIgnored:Bool = false) {
        guard let camera = camera else { return }
        if let clip = clip.rawClip {
            _ = camera.local?.vdbManager?.getThumbnail(forClip: clip, atTime: clip.startTime+time, ignorable: canBeIgnored, cache: true, completion: { [weak self](result) in
                if result.isSuccess, let thumbnail = result.value as? WLVDBThumbnail, let image = UIImage(data: thumbnail.imageData) {
                    self?.playerPanel.setFacedown(clip.isRotated)
                    self?.playerPanel.rawThumbnail = image
                    let delta = thumbnail.pts - (clip.startTime + time)
                    if (abs(delta) < 2.0) && (abs(delta) >= 0.1) {
                        self?.startError = delta
                    }
                }
            })
        } else if let t = clip.thumbnailUrl, let url = URL(string: t) {
            CacheManager.shared.imageFetcher.get(url).onSuccess { [weak self] (image) in
                self?.playerPanel.setFacedown(clip.facedown)
                self?.playerPanel.rawThumbnail = image
            }
        }
    }
    private func deleteSelectedClip() {
        guard let index = userSelectedIndex, let clip = dataModel.clipWithIndex(index) else { return }
        dataModel.removeClip(clip)
    }
    private func exportSelectedClip() {
        guard let index = userSelectedIndex, let clip = dataModel.clipWithIndex(index), let timeline = timeline else { return }
        if isLocalSource {
            clipInfoBar?.update(with: clip)
            presentExportClipSheet(with: clipInfoBar) { [unowned self] (exportDestination) in
                if let exportDestination = exportDestination {
                    let (currentIndex, time, _) = timeline.currentIndexInfo() // Need time to fetch from camera!
                    var startTime: TimeInterval = 0
                    
                    if currentIndex == index {
                        startTime = max(0, time - self.highlightController.defaultHighlightDuration / 2)
                    } else {
                        if let _index = currentIndex, let _clip = self.dataModel.clipWithIndex(_index) {
                            let midTime = _clip.startDate.timeIntervalSince(clip.startDate) + time
                            startTime = max(0, midTime - self.highlightController.defaultHighlightDuration / 2)
                        }
                    }
                    self.playerPanel.pause()
                    self.exportClip(clip, startTime: startTime, duration: self.highlightController.defaultHighlightDuration, exportDestination: exportDestination)
                    self.cancelSelection()
                } else {
                    self.cancelSelection()
                }
            }
        } else {
            let clip = self.dataModel.clipWithIndex(index)!
            
            presentExportClipSheet(EditableClip(clip, offset: 0, duration: clip.duration), camera: self.camera, streamIndex: self.streamIndex) { [unowned self] in
                self.cancelSelection()
            }
        }
    }
    func updateRecentThumbnail() {
        if camera?.remote?.thumbnailUrl != nil {
            camera?.remote?.getThumbnail(completion: { [weak self] (image) in
                if let image = image, let this = self {
                    DispatchQueue.main.async {
                        this.playerPanel.setFacedown(this.camera?.facedown ?? false)
                        this.playerPanel.rawThumbnail = image
                    }
                }
            })
        }
    }
    func updateUIForRecordingState() {
        if let recState = camera?.local?.recState {
            if recState == .recording {
                if let index = playSourceView.items.firstIndex(of: .localLive) {
                    playSourceView.items.insert(.localLiveRecording, at: index)
                    playSourceView.items.remove(at: index + 1)
                }
                playerPanel.isLocalRecording = true
                playerPanel.controlView.recordingSwitches.setOn(true)
            } else {
                if let index = playSourceView.items.firstIndex(of: .localLiveRecording) {
                    playSourceView.items.insert(.localLive, at: index)
                    playSourceView.items.remove(at: index + 1)
                }
                playerPanel.isLocalRecording = false
                playerPanel.controlView.recordingSwitches.setOn(false)
            }
        }
        playerPanel.controlView.recordingSwitches.setEnabled(true)
    }
    // MARK:- Actions
    @objc func onSourceChanged(_ sender: Any?) {
        stopPlayback()
        cancelSelection()
        if let filter = sender as? VideoFilterViewController {
            isLocalSource = filter.selectedSource == .sdcard
        }
        dataModel.reload()
    }
    @IBAction func onOpenFilter(_ sender: UIButton) {
        let vc = VideoFilterViewController.createViewController()
        vc.sources = sources
        vc.selectedType = typeFilter
        vc.selectedSource = isLocalSource ? .sdcard : .cloud
        vc.videoCount = dataModel.totalCount
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.delegate = self
        filterVC = vc
        present(vc, animated: true, completion: nil)
        UIView.animate(withDuration: 0.3) {
            self.filterButton.alpha = 0
        }
    }
    @objc func recordingSwitchValueChanged(_ sender: UISwitch) {
        //        let wasOn = camera?.monitoring ?? false
        camera?.monitoring = sender.isOn
        sender.isEnabled = false
        //sender.setOn(wasOn, animated: true)
    }
    @objc func cameraPickerButtonTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "CameraPicker", bundle: nil).instantiateInitialViewController() as! CameraPickerViewController
        vc.selectHandler = { [weak self] selectedCamera in
            UnifiedCameraManager.shared.current = selectedCamera
            self?.camera = selectedCamera
            vc.dismissMyself(animated: true)
        }
        popout(vc.embedInNavigationController(), preferredContentSize: CGSize(width: view.frame.width * 0.8, height: min(max(view.frame.height * 0.8, 480.0), 500.0)), tapBackgroundToDismiss: true, from: sender)
    }
#if !FLEET
    @objc func triggerVoiceTimerFired() {
        triggerVoiceTimer?.invalidate()
        if voiceController == nil {
            voiceController = VoiceController(licenseKey: AppConfig.AccessKeys.wowzaLicenseKey)
            voiceController?.delegate = self
        }
        if voiceController?.status.isIdle == true {
            showMicrophoneStatusView()
            microphoneStatusView.titleLabel.text = NSLocalizedString("Connecting...", comment: "Connecting...")
            voiceController?.startStreaming(with: camera!).onSuccess({ _ in
                // success
            }).onFailure({ [weak self] (error) in
                Log.error("Tackback Error: \(error.localizedDescription)")
                self?.alert(message: NSLocalizedString("Failed to start talkback, please try again.", comment: "Failed to start talkback, please try again."))
            })
        }
    }
#endif
    // MARK:- data model delegate
    func listUpdated(_ source: CameraTimeLineDataSource) {
#if FLEET
        timeline?.reloadData()
#else
        if (source is CTLLocalDataSource) == isLocalSource {
            timeline?.reloadData()
        }
#endif
    }
    func staticsUpdated(_ source: CameraTimeLineDataSource) {
        if source === dataModel, let vc = filterVC, (vc.selectedSource == .sdcard) == isLocalSource, vc.selectedType == (source.filter ?? .all) {
            vc.videoCount = source.totalCount
        }
    }
    func clipUpdated(_ source: CameraTimeLineDataSource, clip: HNClip) {
        guard let timeline = timeline else { return }
        if (source is CTLLocalDataSource) == isLocalSource && isVisible && !(timeline.scrollMode.isActive) {
            for case var cell as ClipRelated in timeline.collectionView.visibleCells {
                if cell.clip == clip {
                    cell.clip = clip
                    timeline.reloadData() // TODO: Optimize: avoid to reload all data
#if FLEET
                    if let userSelectedIndex = userSelectedIndex, let selectedClip = dataModel.clipWithIndex(userSelectedIndex), selectedClip.clipID == clip.clipID {
                        clipInfoBar?.update(with: clip)
                    }
#else
                    if actionBar?.status == .action, actionBar?.clip == clip {
                        actionBar?.clip = clip
                    }
#endif
                    break
                }
            }
        }
    }
    func clipCreated(_ source: CameraTimeLineDataSource, clip: HNClip) {
        listUpdated(source)
        if (source is CTLLocalDataSource) == isLocalSource {
            if highlightController.highlightState == .confirmed || highlightController.highlightState == .userInited {
                highlightController.highlightState = .clipCreated
            }
        }
    }
    // MARK: - vdb dynamic request
    func onGetPlayURL(_ url: String?, time: Double, tag: Int32) {
        if url == nil {
            Log.info("get nil play url")
            return
        }
        Log.info("onGetPlayURL: " + url!)
        if playerPanel.playState == .buffering {
            playerPanel.playVideo(url, playbackTime: startPlayTime, startOffset: startPlayTime)
            if abs(time - (currentRawClipStartTime + startPlayTime)) < 2.0 {
                self.startError = time - (currentRawClipStartTime + startPlayTime)
            }
        }
    }
    func onClipMark(_ done: Bool) {
        if done {
            if highlightController.highlightState == .userInited {
                highlightController.highlightState = .confirmed
            }
        } else {
            if highlightController.highlightState == .userInited {
                highlightController.highlightState = .failed
            }
        }
    }
    func onDMSData(_ data: UnsafeMutablePointer<readsense_dms_data_v2_t>?, time: Double, clip: Int32, in domain: WLVDBDomain, withRecordConfig config: String) {
        playerPanel.updateDmsInfo(dms: data?.pointee, with: config)
    }
    func onDMSESData(_ dmsData: WLDmsData?, time: Double, clip: Int32, in domain: WLVDBDomain, withRecordConfig config: String) {
        playerPanel.updateDmsESInfo(dmsData, with: config)
    }
    // MARK: - HNPlayerPanelDelegate
    func onFullScreen(_ full: Bool) {
        layout(asLandscape: full)
        if full {
            //            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            self.lockOrientation(.landscapeRight, andRotateTo: .landscapeRight)
        } else {
            self.lockOrientation(.portrait, andRotateTo: .portrait)
            //            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
    func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    @objc func toggleFullscreen() {
        let isFullscreen = UIDevice.current.orientation.isLandscape
        onFullScreen(!isFullscreen)
    }
    func onResolution(_ resolution: HNVideoResolution, index: Int) {
        streamIndex = Int32(index)
        if playerPanel.isPlayingOrPreparing(.localPlayback) {
            let (idx, time, _) = timeline!.currentIndexInfo()
            if let idx = idx, time>=0 {
                let clip = dataModel.clipWithIndex(idx)
                if clip != nil {
                    playerPanel.supportViewMode = clip!.needDewarp
                    if clip?.needDewarp == false {
                        highlightController.streamIndex = streamIndex
                    }
                }
            }
        } else if camera?.needDewarp ?? true == false {
            highlightController.streamIndex = streamIndex
        }
        
        if playerPanel.isPlayingOrPreparing(.localPlayback) {
            let (index, time, _) = timeline!.currentIndexInfo()
            stopPlayback()
            if let index = index, time>=0 {
                play(index: index, time: time)
            }
        }
    }
    func onDMSFace() {
        if dmsFaceList == nil && camera != nil && camera!.local != nil {
            dmsFaceList = DMSFaceIDList.init(superview: self.viewContainerConfigCameraMK, vc: self, camera: camera!.local!, cameraUnified: camera!)
            self.stackInfoCameraView.isHidden = true
            dmsFaceList?.update()
        } else {
            self.stackInfoCameraView.isHidden = false
            dmsFaceList?.tabView?.removeFromSuperview()
            dmsFaceList = nil
        }
    }
    func onPlay(_ play: Bool) {
        if play {
            userPausedOnCurrentTime = false
            playCurrentLine(manual: true)
        } else {
            userPausedOnCurrentTime = true
            if playerPanel.playSource == .remoteLive {
                stopLive()
            } else {
                playerPanel.pause()
            }
        }
    }
    func playerDidChange(_ state: HNPlayState) {
        if state == .playing &&
            (playerPanel.playSource != .localLive) {
            startScrollTimer()
        } else {
            if playerPanel.playSource == .remoteLive {
                if state == .paused  {
                    // remote live stopped by user
                    stopLive()
                } else if state == .error {
                    // remote live stopped unexpectedlly
                    stopLive()
                }
            }
            killScrollTimer()
        }
        updateTimelineSource()
        if state == .completed {
            if playerPanel.currentPlayTime < playerPanel.duration - 0.1 { // completed (30mins) segment, whole clip is not completed
                playCurrentLine()
            } else {
                playNext(bCloudVideo:playerPanel.playSource == .remotePlayback)
            }
        }
#if !FLEET
        switch state {
        case .unloaded, .error, .stopped, .completed:
            if let camera = camera, let voiceController = voiceController, !voiceController.status.isIdle {
                microphoneStatusView.removeFromSuperview()
                voiceController.endStreaming(with: camera)
            }
        default:
            break
        }
#endif
    }
    private func cancelSelection() {
        if actionBar?.status != .hidden && !(actionBar?.isHideable == true) {
            actionBar?.showProgress()
        } else {
            actionBar?.hide()
        }
        timeline?.cancelSelection()
        userSelectedIndex = nil
        if presentedViewController is ActionSheetController { // expect VideoFilterViewController
            presentedViewController?.dismissMyself(animated: true)
        }
    }
    func onHighlight() {
        highlightController.handleHighlightButtonTapped()
    }
    func onHighlightCard() {
        highlightController.handleHighlightCardTapped()
    }
    func exportClip(_ clip: HNClip, startTime: TimeInterval = 0, duration: TimeInterval = 30, exportDestination: ExportDestination) {
        guard let _ = clip.rawClip, let camera = camera else { return }
        let vc = SelectRangeViewController.createViewController(clip: clip, camera: camera, exportDestination: exportDestination)
        vc.selectedStart = startTime
        vc.selectedDuration = duration
        vc.streamIndex = clip.needDewarp ? 0 : streamIndex
        navigationController?.pushViewController(vc, animated: true)
        if UIDevice.current.orientation.isLandscape {
            onFullScreen(false)
        }
    }
#if !FLEET
    func onMicButtonTouchStateChange(_ micButton: UIButton) {
        if micButton.isTracking {
            if let voiceController = voiceController, !voiceController.status.isIdle {
                return
            }
            triggerVoiceTimer?.invalidate()
            triggerVoiceTimer = nil
            triggerVoiceTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(triggerVoiceTimerFired), userInfo: nil, repeats: false)
        } else {
            guard let voiceController = voiceController else { return }
            if triggerVoiceTimer?.isValid == true && voiceController.status.isIdle && !micButton.isHidden {
                HNMessage.showInfo(message: NSLocalizedString("Please hold to talk", comment: "Please hold to talk"))
            }
            triggerVoiceTimer?.invalidate()
            triggerVoiceTimer = nil
            if !voiceController.status.isIdle {
                voiceController.endStreaming(with: camera!)
            }
        }
    }
#endif
    func showControls(show: Bool, duration: TimeInterval) {
        guard playerPanel.fullScreen else {
            return
        }
        var animations: (() -> ())!
        if show {
            animations = {[weak self] in
                self?.playSourceView.alpha = 1.0
            }
        } else {
            animations = {[weak self] in
                self?.playSourceView.alpha = 0.0
            }
        }
        UIView.animate(withDuration: Constants.Animation.defaultDuration, animations: animations)
    }
    func onViewMode(_ viewMode: HNViewMode) {
        if guideVC?.isPresented ?? false {
            guideVC?.refreshUI()
        }
    }
    func playerDidChange(source: HNPlaySource) {
        switch source {
        case .none:
            break
        case .localLive:
            if camera?.local?.recState == .recording {
                playSourceView.selectedItem = .localLiveRecording
            } else {
                playSourceView.selectedItem = .localLive
            }
        case .remoteLive:
            if let camera = camera {
                playSourceView.selectedItem = .remoteLive(camera.cellSignalStatus)
            } else {
                Log.error("Unexpected error : camera is nil")
            }
        case .localPlayback:
            playSourceView.selectedItem = .localPlayback
        case .remotePlayback:
            playSourceView.selectedItem = .remotePlayback
        case .offline:
            playSourceView.selectedItem = .offline
        }
    }
    private func tryUpdateThumbnail(clip: HNClip, time:TimeInterval) {
        let now = Date()
        if lastThumbnailRequestTime == nil || now.timeIntervalSince(lastThumbnailRequestTime!) > requestThumbnailInterval {
            requestThumbnail(clip: clip, time: time, canBeIgnored: true)
            lastThumbnailRequestTime = now
        }
    }
    // MARK: - Notifications
    @objc func onLiveMark(_ notification: Notification) {
        let done = notification.userInfo?[Notification.Name.Local.liveMark] as? Bool ?? false
        print("live mark \(done)")
        if done {
            HNMessage.showIcon(#imageLiteral(resourceName: "icon_collection_n"), message: NSLocalizedString("Highlight Successfully", comment: "Highlight Successfully"))
        }
    }
    @objc func onRecordStateChanged(_ notification: Notification) {
        if let local = notification.object as? WLCameraDevice, local == camera?.local {
            if playerPanel.isPlayingOrPreparing(.localLive) {
                playerPanel.playLocalLive(camera?.local?.getLivePreviewAddress(),
                                          isRecording: camera?.local?.recState == .recording)
                camera?.local?.liveDataMonitor?.start(gps: true, dms: true)
                camera?.local?.liveDataMonitor?.delegate = self
            }
            if camera?.local?.recState == .stopped {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("Recording Stopped", comment: "Recording Stopped"))
                SVProgressHUD.dismiss(withDelay: 1.0)
            }
            updateUIForRecordingState()
        }
    }
    @objc func handleAppDidEnterBackgroundNotification() {
        stopLive()
        stopPlayback()
        shutdown()
    }
    private var lastDMSTime = 0.0
    private func handleUpdateRawData(_ timeline: CameraTimeline?, startError : TimeInterval) {
        guard timeline != nil else { return }
        let (_, time, segment) = timeline!.currentIndexInfo()
        let clip = segment?.clip
        if clip?.rawClip?.dmsIndex ?? -1 >= Int32(0) {
            lastDMSTime = clip!.rawClip!.startTime+time
            let camera = self.camera
            _ = camera?.local?.vdbClient.getExtraRawData(forClip: clip!.rawClip!.clipID,
                                                         in: WLVDBDomain(rawValue: UInt32(clip!.rawClip!.clipType)),
                                                         atTime: clip!.rawClip!.startTime+time + startError + 0.2,
                                                         withIndexes: clip!.rawClip!.dmsIndex,
                                                         with: clip!.rawClip!.vdbID)
        }
    }
}
extension UINavigationController {
    override open var shouldAutorotate: Bool{
        get{
            if let visibleVC = visibleViewController{
                return visibleVC.shouldAutorotate
            }
            return super.shouldAutorotate
        }
    }
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        get{
            if let visibleVC = visibleViewController {
                return visibleVC.preferredInterfaceOrientationForPresentation
            }
            return super.preferredInterfaceOrientationForPresentation
        }
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            if let visibleVC = visibleViewController {
                return visibleVC.supportedInterfaceOrientations
            }
            return super.supportedInterfaceOrientations
        }
    }
}

//MARK: - Private

private extension HNCameraDetailViewController {
    func initCameraPickerButton() {
        cameraPickerButton = DropDownArrowButton()
        cameraPickerButton?.title = NSLocalizedString("No Camera", comment: "No Camera")
        cameraPickerButton?.addTarget(self, action: #selector(cameraPickerButtonTapped(_:)), for: .touchUpInside)
        navigationItem.titleView = cameraPickerButton
    }
    func initHideShowBarsLogic() {
        let shouldAffectTabBar = navigationController?.viewControllers.first == self
        if hideShowBarsLogic == nil {
            hideShowBarsLogic = HNCameraDetailHideShowBarsLogic(
                scrollView: timeLineVerticalView?.collectionView,
                tabBarController: shouldAffectTabBar ? tabBarController : nil,
                //                tabBarController: tabBarController,
                navigationController: navigationController,
                playerContainer: playerContainer,
                playerContainerTopConstraint: playerContainerTopConstraint
            )
        }
    }
    @objc func showSettingButtonIfNeeded() {
        self.navigationItem.hidesBackButton = true
        let backButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbar_back_n"), style: .plain, target: self, action: #selector(back))
        backButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = backButton
    }
    @objc func back() {
        if isCheckLoginCamera {
            self.navigationController?.popViewController(animated: true)
        } else {
            if isTapDataMemorySDView {
                self.isTapDataMemorySDView = false
                self.setViewTimeline()
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    func showEventLegend() {
        let vc = EventLegendViewController.createViewController()
        onPlay(false)
        present(vc, animated: true, completion: nil)
        if guideVC?.isPresented ?? false {
            actionBar?.hide()
            guideVC?.refreshUI()
            vc.dismissBlock = { [weak self] in
                self?.showGuide()
            }
        }
    }
    func layout(asLandscape: Bool) {
        hideShowBarsLogic?.layout(asLandscape: asLandscape)
        playerPanel.fullScreen = asLandscape
        if asLandscape {
            playSourceView.show(in: self.view)
            showTimeLineHorizontalView()
        } else {
            playSourceView.show(in: portraitPlaySourceViewContainer)
            playSourceView.alpha = 1.0
            showTimeLineVerticalView()
        }
        navigationController?.setNavigationBarHidden(asLandscape, animated: true)
    }
#if !FLEET
    func showMicrophoneStatusView() {
        if !microphoneStatusView.isDescendant(of: view) {
            view.addSubview(microphoneStatusView)
            microphoneStatusView.topAnchor.constraint(equalTo: playerContainer.bottomAnchor).isActive = true
            microphoneStatusView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            microphoneStatusView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            microphoneStatusView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        microphoneStatusView.isHidden = false
        view.bringSubviewToFront(microphoneStatusView)
    }
#endif
}
extension HNCameraDetailViewController: CameraTimelineDelegate {
    func timelineDidTapFooterButton(_ timeline: CameraTimeline) {
        if AccountControlManager.shared.isAuthed {
            camera?.bind(password: camera?.local?.password ?? "", completion: { [weak self] (result) in
                if result.isSuccess {
                    self?.camera?.reportICCID(completion: nil)
                    self?.timeline?.reloadData()
                    HNMessage.showSuccess(message: NSLocalizedString("Camera added", comment: "Camera added"))
                } else {
                    HNMessage.showError(message: result.error?.localizedDescription ?? NSLocalizedString("Failed to add camera", comment: "Failed to add camera"))
                }
            })
        } else {
            AppViewControllerManager.gotoLogin()
        }
    }
    
    func timelineIsCloseToEnd(_ timeline: CameraTimeline) {
        if !isLocalSource && cloudModel.shouldFetch {
            cloudModel.fetchMoreData()
        }
    }
    func timelineDidScroll(_ timeline: CameraTimeline) {
        guard  timeline === self.timeline else { return }
        highlightController.handleTimelineScroll(timeline)
        if timelineSource == .timeline {
            playerOnSeeking()
            handleUpdateRawData(timeline, startError: startError)
        } else if timelineSource == .default {
            playerEndSeeking()
        }
        if timeline === timeLineVerticalView {
            hideShowBarsLogic?.scrollViewDidScroll()
        }
    }
    func timeline(_ timeline: CameraTimeline, didChangeScrollModeFrom oldMode: CameraTimelineScrollMode, to newMode: CameraTimelineScrollMode) {
        updateTimelineSource()
        switch newMode {
        case .idle:
            playerEndSeeking()
        default:
            stopPlayback()
        }
        if newMode != .animating {
            nextClipToPlay = nil
        }
        if newMode != .idle {
            userPausedOnCurrentTime = false
        }
    }
    func timelineWillGoLive(_ timeline: CameraTimeline) {
        stopPlayback()
    }
    func timelineDidPrepareLayout(_ timeline: CameraTimeline) {
        guard timeline === self.timeline else {
            return
        }
        if currentPos == nil {
            initCurrentPosition()
        }
        if timelineSource == .timeline {
            playerOnSeeking()
        } else {
            timelineSetPosition(currentPos!)
        }
        if highlightController.highlightState == .clipCreated {
            highlightController.highlightState = .clipDisplayed
            if isVisible {
                highlightController.showHighlightCard()
            }
        }
        handleUpdateRawData(self.timeline ?? nil, startError: startError)
    }
    func timeline(_ timeline: CameraTimeline, didSelectItemAt indexPath: IndexPath) {
        cancelSelection() // cancel previous selection
        guard let clip = dataModel.clipWithIndex(indexPath) else { return }
        userSelectedIndex = indexPath
        let (currentIndex, _, _) = timeline.currentIndexInfo()
        if currentIndex != indexPath { // not viewing selected video, scroll to it
            nextClipToPlay = clip
            timeline.scrollToItem(at: indexPath, animated: true)
        }
#if FLEET
        exportSelectedClip()
        guideVC?.refreshUI()
#else
        if isLocalSource {
            actionBar?.deleteButton.isHidden = clip.rawClip?.isLive ?? false
        }
        actionBar?.clip = clip
        actionBar?.showActions()
        guideVC?.refreshUI()
#endif
        hideShowBarsLogic?.timelineDidSelectItem()
    }
    func timeline(_ timeline: CameraTimeline, didUnselectItemAt indexPath: IndexPath) {
        cancelSelection()
    }
}

// MARK: - HNActionBar Delegate
extension HNCameraDetailViewController: HNActionBarDelegate {
    func actionBarDidCancel(_ actionBar: HNActionBar) {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("Quit downloading?", comment: "Quit downloading?"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Keep downloading", comment: "Keep downloading"), style: .cancel, handler: { (_) in
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Quit", comment: "Quit"), style: .destructive, handler: { (_) in
            MixpanelHelper.track(event: "Cancel download video")
            VideoDownloadManager.shared.cancel()
        }))
        present(alert, animated: true, completion: nil)
    }
    func actionBarDidDelete(_ actionBar: HNActionBar) {
        playerPanel.pause()
        actionBar.hide()
        presentDeleteClipSheet(
            title: String(format: NSLocalizedString("The video will be deleted from the %@", comment: "The video will be deleted from the %@"), isLocalSource ? NSLocalizedString("camera's SD card", comment: "camera's SD card") : NSLocalizedString("cloud", comment: "cloud")),
            deleteHandler: { [weak self] in
                MixpanelHelper.track(event: "Delete video")
                self?.deleteSelectedClip()
                self?.cancelSelection()
            }, cancelHandler: { [weak self] in
                self?.cancelSelection()
            })
    }
    func actionBarDidDownload(_ actionBar: HNActionBar) {
        MixpanelHelper.track(event: "Download video")
        playerPanel.pause()
        actionBar.hide()
        exportSelectedClip()
    }
    func actionBarDidRequestInfo(_ actionBar: HNActionBar) {
        showEventLegend()
    }
}
// MARK: - VideoFilterDelegate Delegate
extension HNCameraDetailViewController: VideoFilterDelegate {
    func onFilterChanged(sender: VideoFilterViewController) {
        if isLocalSource != (sender.selectedSource == .sdcard) {
            // source changed
            onSourceChanged(sender)
        }
        if typeFilter != sender.selectedType {
            // type changed
            stopPlayback()
            typeFilter = sender.selectedType
            dataModel.reload()
        }
        sender.videoCount = dataModel.totalCount
    }
    func onFilterDismissed(sender: VideoFilterViewController) {
        UIView.animate(withDuration: 0.3) {
            self.filterButton.alpha = 1.0
        }
    }
}
// MARK: - HNLiveDataMonitorDelegate
extension HNCameraDetailViewController: HNLiveDataMonitorDelegate {
    func onLive(obd: obd_raw_data_v2_t?) { }
    func onLive(acc: iio_raw_data_t?) { }
    func onLive(gps: CLLocation?) { }
    func onLive(dms :readsense_dms_data_v2_t?) {
        if playerPanel.playSource == .localLive {
            playerPanel.updateDmsInfo(
                dms: dms,
                with: camera?.local?.recordConfig?.recordConfig ?? ""
            )
        }
    }
    func onLiveES(dmsData: WLDmsData?) {
        if playerPanel.playSource == .localLive {
            playerPanel.updateDmsESInfo(dmsData, with: camera?.local?.recordConfig?.recordConfig ?? "")
        }
    }
}
extension UIWindow {
    static var isLandscape: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation
                .isLandscape ?? false
        } else {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
}
#if !FLEET
//MARK: - VoiceControllerDelegate
extension HNCameraDetailViewController: VoiceControllerDelegate {
#if arch(x86_64) || arch(i386)
#else
    func voiceController(_ voiceController: VoiceController, statusDidChange newStatus: VoiceControllerStatus, error: Error?) {
        HNMessage.dismiss()
        showMicrophoneStatusView()
        switch newStatus.state {
        case .running:
            microphoneStatusView.titleLabel.text = NSLocalizedString("Speaking, please.", comment: "Speaking, please.")
        case .stopping:
            microphoneStatusView.titleLabel.text = NSLocalizedString("Stopping...", comment: "Stopping...")
        case .buffering:
            microphoneStatusView.titleLabel.text = NSLocalizedString("Buffering...", comment: "Buffering...")
        case .idle:
            microphoneStatusView.isHidden = true
        default:
            break
        }
        if let error = error {
            Log.error("Tackback Error: \(error.localizedDescription)")
            alert(message: NSLocalizedString("Failed to start talkback, please try again.", comment: "Failed to start talkback, please try again."))
        }
    }
#endif //arch
}

#endif
