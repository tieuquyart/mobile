//
//  CameraTimelineVerticalViewController.swift
//  Acht
//
//  Created by Chester Shen on 3/7/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensFoundation
import WaylensCameraSDK

extension UICollectionView {
    func bottomToEndIsCloserThan(distance: CGFloat) -> Bool {
        return self.collectionViewLayout.collectionViewContentSize.height - self.contentOffset.y - self.frame.height <= distance
    }
}

enum CameraTimelineScrollMode {
    case idle
    case dragging
    case decelerating
    case animating
    
    var isActive: Bool {
        switch self {
        case .dragging, .decelerating, .animating:
            return true
        default:
            return false
        }
    }
    
    var isSeeking: Bool {
        switch self {
        case .dragging, .decelerating:
            return true
        default:
            return false
        }
    }
}

class CameraTimelineVerticalViewController: UIViewController, CameraTimeline {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var liveLine: UIView!
    @IBOutlet weak var liveLineTrailingContraint: NSLayoutConstraint!
    @IBOutlet weak var timeLineBarHeight: NSLayoutConstraint!
    @IBOutlet weak var liveButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var liveButtonBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var liveButton: UIButton!

    #if FLEET
    private var indexView: SectionIndexView?
    #endif

    private var maskTimeLabelWidth: CGFloat = 0
    private var maskCrossingLiveButton: Bool = false
    private var offsetResidual: CGFloat = 0

    var scrollMode: CameraTimelineScrollMode = .idle {
        didSet {
            if scrollMode != oldValue {
                delegate?.timeline(self, didChangeScrollModeFrom:oldValue, to:scrollMode)
            }
        }
    }
    weak var delegate: CameraTimelineDelegate?

    var dataSource: CameraTimeLineDataSource! {
        didSet {
            layout.dataSource = dataSource
            reloadData()
        }
    }
    var layout: CameraTimeLineLayout {
        return collectionView.collectionViewLayout as! CameraTimeLineLayout
    }
    var lineOffset: CGFloat {
        return collectionView.contentOffset.y + lineInset + offsetResidual
    }
    var liveOffset: CGFloat {
        return layout.frameForLive().midY
    }
    var lineInset: CGFloat {
        return CameraTimeLineLayout.sectionHeaderHeight
    }
    var isInLivePositon: Bool {
        return abs(collectionView.contentOffset.y) < 1
    }
    var userSelectedIndex: IndexPath?
    
    static func createViewController() -> CameraTimelineVerticalViewController {
        let vc = CameraTimelineVerticalViewController(nibName: "CameraTimelineVerticalViewController", bundle: nil)
        return vc
    }
    
    func addToParentViewController(_ parent: UIViewController, superView: UIView) {
        self.view.removeFromSuperview()
        self.removeFromParent()
        superView.addSubview(self.view)
        parent.addChild(self)
        self.didMove(toParent: parent)
        self.view.frame = superView.bounds
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.translatesAutoresizingMaskIntoConstraints = true
        view.setNeedsUpdateConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        liveLine.backgroundColor = UIColor.semanticColor(.tint(.primary))
        liveLine.backgroundColor = UIColor.color(fromHex: "#36A410")
        
        timeLineBarHeight.constant = 2 * CameraTimeLineLayout.sectionHeaderHeight

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: CameraTimeLineLayout.itemCellID, bundle: nil), forCellWithReuseIdentifier: CameraTimeLineLayout.itemCellID)
        collectionView.register(UINib(nibName:CameraTimeLineLayout.supplementaryHeader, bundle:nil), forSupplementaryViewOfKind: CameraTimeLineLayout.supplementaryHeader, withReuseIdentifier: CameraTimeLineLayout.supplementaryHeader)
        collectionView.register(UINib(nibName:CameraTimeLineLayout.supplementaryLiveButton, bundle:nil), forSupplementaryViewOfKind: CameraTimeLineLayout.supplementaryLiveButton, withReuseIdentifier: CameraTimeLineLayout.supplementaryLiveButton)
        collectionView.register(UINib(nibName:CameraTimeLineLayout.supplementaryThumbnail, bundle:nil), forSupplementaryViewOfKind: CameraTimeLineLayout.supplementaryThumbnail, withReuseIdentifier: CameraTimeLineLayout.supplementaryThumbnail)
        collectionView.register(UINib(nibName:CameraTimeLineLayout.supplementaryFooter, bundle:nil), forSupplementaryViewOfKind: CameraTimeLineLayout.supplementaryFooter, withReuseIdentifier: CameraTimeLineLayout.supplementaryFooter)

        liveButtonBottomSpace.constant = -liveButtonHeight.constant
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.size != layout.collectionViewBoundsSize {
            layout.collectionViewBoundsSize = view.bounds.size
            layout.invalidateLayout()
        }

        refreshLiveLine()
    }
    
    func refreshUI() {
        // UI update for live line
        refreshLiveLine()
        // UI update for bottom live button
        displayLiveButton()
        // check selection
        if let selectedIndex = userSelectedIndex, scrollMode != .animating {
            let (index, _, _) = currentIndexInfo()
            if index != userSelectedIndex {
                cancelSelection()
                delegate?.timeline(self, didUnselectItemAt: selectedIndex)
            }
        }
    }
    
    func reloadData() {
        #if FLEET
        toggleIndexViewEnabledStateIfNeeded()
        collectionView.reloadData()
        indexView?.reloadView()

        if isInLivePositon, let indexView = indexView {
            indexView.scroll(to: IndexTitlesHelper.convert(0, toIndexItemIndexIn: indexView))
        }
        #else
        collectionView.reloadData()
        #endif
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func updateTime(_ time:Date? = nil, timeString:String? = nil) {
        currentTimeLabel.text = timeString ?? time?.toString(format: .timeSec12)
        currentTimeLabel.superview?.layoutIfNeeded()
        refreshLiveLine()

        #if FLEET
        if let indexView = indexView, let time = time {
            for (i, date) in dataSource.dateList.enumerated() {
                if Calendar.current.isDate(time, inSameDayAs: date) {
                    indexView.scroll(to: IndexTitlesHelper.convert(i, toIndexItemIndexIn: indexView))
                    break
                }
            }
        }
        #endif
    }

    #if FLEET
    private func toggleIndexViewEnabledStateIfNeeded() {
        var isEnableIndexView: Bool = false

        if let dataSource = dataSource, dataSource.isLocal && !dataSource.dateList.isEmpty {
            isEnableIndexView = true
        }

        if isEnableIndexView {
            if indexView == nil {
                indexView = SectionIndexView(collectionView: self.collectionView, delegate: self)
                view.addSubview(indexView!)
                liveLineTrailingContraint.constant = indexView!.width
            }
        } else {
            liveLineTrailingContraint.constant = 0.0
            indexView?.removeFromSuperview()
            indexView = nil
        }

        layout.thumbnailRightSpace = indexView?.width ?? CameraTimeLineLayout.defaultThumbnailRightSpace
    }
    #endif
    
    private func refreshLiveLine() {
        currentTimeLabel.isHidden = (isCrossingLiveButton() ? true : false) || collectionView.contentOffset.y < 0.0
        
        let labelFrame = currentTimeLabel.frame
        if labelFrame.width == maskTimeLabelWidth && isCrossingLiveButton() == maskCrossingLiveButton && !maskCrossingLiveButton {
            return
        }
        let path = UIBezierPath(rect: liveLine.bounds)
        maskTimeLabelWidth = labelFrame.width
        if maskTimeLabelWidth > 0 && !currentTimeLabel.isHidden {
            let frame = CGRect(x: labelFrame.minX - 4, y: -1, width: labelFrame.width + 8, height: liveLine.frame.height+2)
            let labelPath = UIBezierPath(rect: frame)
            path.append(labelPath)
        }
        maskCrossingLiveButton = isCrossingLiveButton()
        if maskCrossingLiveButton {
            var frame = layout.frameForLive()
            frame = frame.offsetBy(dx: 0, dy: -collectionView.contentOffset.y - CameraTimeLineLayout.sectionHeaderHeight)
            let buttonPath = UIBezierPath(roundedRect: frame, cornerRadius: frame.height * 0.5)
            path.append(buttonPath)
        }
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        liveLine.layer.mask = maskLayer
    }
    
    func displayLiveButton() {
        var offset = collectionView.contentOffset.y
        let minY =  CameraTimeLineLayout.sectionHeaderHeight - 0.5 * CameraTimeLineLayout.liveButtonHeight
        let maxY = minY + CameraTimeLineLayout.liveButtonHeight + 20
        offset = max(minY, min(maxY, offset))
        let ratio = (offset - minY)/(maxY - minY)
        var safeSpace:CGFloat = 20
        if #available(iOS 11, *) {
            safeSpace = max(safeSpace - view.safeAreaInsets.bottom, 0)
        }
        liveButtonBottomSpace.constant =  ratio * (liveButtonHeight.constant + safeSpace ) - liveButtonHeight.constant
        liveButton.alpha = ratio
        liveButton.setNeedsLayout()
    }
    
    func isCrossingLiveButton() -> Bool {
        return (collectionView.collectionViewLayout as? CameraTimeLineLayout)?.isCrossingLiveButton(lineOffset) ?? false
    }
    
    func endOffsetForItem(at indexPath: IndexPath) -> CGFloat? {
        return collectionView.safeLayoutAttributesForItem(at: indexPath)?.frame.minY
    }
    
    func indexInfo(at line: CGFloat) -> (IndexPath?, TimeInterval, HNClipSegment?) {
        return (collectionView.collectionViewLayout as! CameraTimeLineLayout).indexAndTimeAndSegmentAt(line)
    }
    
    func currentIndexInfo() -> (IndexPath?, TimeInterval, HNClipSegment?) {
        return indexInfo(at:lineOffset)
    }
    
    func setLineOffset(_ offset:CGFloat, animated:Bool=false) {
        let scale = UIScreen.main.scale
        let adjusted = floor((offset - lineInset) * scale) / scale
        offsetResidual = offset - lineInset - adjusted
//        Log.verbose("set content offset: \(offset) adjusted: \(adjusted)")
        if animated {
            stopScrolling() // must stop first
            scrollMode = .animating
        }
        collectionView.setContentOffset(CGPoint(x:0, y:adjusted), animated: animated)
    }
    
    func scrollTo(time:Date) {
        let layout = collectionView.collectionViewLayout as! CameraTimeLineLayout
        let offset = layout.contentOffsetFor(time) ?? liveOffset
        setLineOffset(offset, animated: false)
    }
    
    func scrollToItem(at indexPath: IndexPath, animated:Bool) {
        guard let attributes = collectionView.safeLayoutAttributesForItem(at: indexPath) else { return }
        scrollTo(offset: attributes.frame.maxY, animated:animated)
    }
    
    func scrollToLive(animated: Bool) {
        scrollTo(offset: liveOffset, animated:animated)
    }
    
    private func stopScrolling() {
        guard scrollMode.isActive else { return }
        collectionView.setContentOffset(collectionView.contentOffset, animated: false)
    }
    
    func cancelSelection() {
        if let index = userSelectedIndex, let cell = collectionView.cellForItem(at: index) as? CameraTimeLineCell {
            cell.isUserSelected = false
            userSelectedIndex = nil
        }
    }
    
    func selectItem(at indexPath: IndexPath) {
        if userSelectedIndex != nil {
            cancelSelection()
        }
        let cell = collectionView.cellForItem(at: indexPath) as? CameraTimeLineCell

        #if FLEET
        cell?.thumbnailAreaTrailingConstraint.constant = indexView?.width ?? CameraTimeLineLayout.defaultThumbnailRightSpace
        #endif

        cell?.isUserSelected = true
        userSelectedIndex = indexPath
    }
    
    // MARK: - Actions

    @IBAction func goLiveButtonTapped(_ sender: Any) {
        scrollToLive(animated: true)
        delegate?.timelineWillGoLive(self)
    }

}

// MARK: - ScrollView Delegate
extension CameraTimelineVerticalViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Log.verbose("did scroll at content offset \(scrollView.contentOffset.y), scrollmode: \(scrollMode)")
        if collectionView.bottomToEndIsCloserThan(distance: collectionView.frame.height*1.3) {
            delegate?.timelineIsCloseToEnd(self)
        }
        delegate?.timelineDidScroll(self)
        refreshUI()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        Log.verbose("will begin dragging at \(scrollView.contentOffset.y)")
        offsetResidual = 0
        if scrollMode == .animating {
            scrollMode = .dragging
            stopScrolling()
        } else {
            scrollMode = .dragging
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        Log.verbose("did end dragging decelerate:\(decelerate) at \(scrollView.contentOffset.y)")
        if decelerate {
            scrollMode = .decelerating
        } else {
            scrollMode = .idle
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        Log.verbose("did end decelerating at \(scrollView.contentOffset.y)")
        scrollMode = .idle
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        Log.verbose("did end animation at \(scrollView.contentOffset.y)")
        if scrollMode == .animating {
            scrollMode = .idle
        }
    }
}

private extension CameraTimelineVerticalViewController {

}

// MARK: - colloection view delegate
extension CameraTimelineVerticalViewController: TimeLineCollectionViewDelegate {
    func layoutDidPrepare() {
        delegate?.timelineDidPrepareLayout(self)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if userSelectedIndex == indexPath { // already selected, to cancel
            cancelSelection()
            delegate?.timeline(self, didUnselectItemAt: indexPath)
        } else { // no selected
            delegate?.timeline(self, didSelectItemAt: indexPath)
            selectItem(at: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == CameraTimeLineLayout.supplementaryThumbnail,
            let thumbnail = layout.thumbnail(atIndex: indexPath) {
            thumbnail.image?.cancel()
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath == userSelectedIndex {
            (cell as? CameraTimeLineCell)?.isUserSelected = true
        }
    }
}

// MARK: - colloection view datasource
extension CameraTimelineVerticalViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       //return 0
        if let  dataSource = dataSource {
            return max(dataSource.clipList.count, 1)
        }
         else {
            return 0
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if dataSource.clipList.count <= section {
            return 0
        }
        return dataSource.clipList[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraTimeLineLayout.itemCellID, for: indexPath) as! CameraTimeLineCell

        #if FLEET
        cell.thumbnailAreaTrailingConstraint.constant = indexView?.width ?? CameraTimeLineLayout.defaultThumbnailRightSpace
        #endif

        if let clip = dataSource?.clipWithIndex(indexPath) {
            cell.clip = clip
            if clip.location == nil, let localSource = dataSource as? CTLLocalDataSource {
                localSource.getLocation(forClip: clip) { [weak cell] in
                    cell?.refreshUI()
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case CameraTimeLineLayout.supplementaryHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! CameraTimeLineHeaderView
            let count = dataSource.countOf(section: indexPath.section)
            let format: String = NSLocalizedString("video count", comment: "video count")
            let title = dataSource.dateList[indexPath.section].toHumanizedDateString() + "\n" + String.localizedStringWithFormat(format, count)
            header.setTitle(title)
            return header
        case CameraTimeLineLayout.supplementaryThumbnail:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! CameraTimeLineThumbnail
            guard let data = layout.thumbnail(atIndex: indexPath),
                let clip = data.clip
                else { return view }
            view.data = data
            if dataSource.isLocal {
                if let camera = dataSource.camera, let rawClip = clip.rawClip, let time = data.pts {
                    let request = VDBThumbnailRequest(cameraID: camera.sn, clip: rawClip, pts: time, cache: true, ignorable: false)
                    view.imageView.vdb_setThumbnail(request, animated:true)
                    data.image = view.imageView.image_future
                }
            } else {
                #if FLEET
                view.imageView.image = UIImage(named: "video placeholder")
                #else
                if let thumbnailUrl = clip.thumbnailUrl, let url = URL(string: thumbnailUrl) {
                    view.imageView.hn_setImage(url: url, facedown: clip.facedown,
                                               dewarp: dataSource?.needDewarp ?? true, placeholderImage: nil)
                }
                #endif
            }
            return view
        case CameraTimeLineLayout.supplementaryFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: IndexPath(item: 0, section: 0)) as! CameraTimeLineFooter
            footer.delegate = self
            if !dataSource.isLocal && !AccountControlManager.shared.isAuthed {
                footer.show(image: #imageLiteral(resourceName: "icon_video_cloud"), title: NSLocalizedString("Not Logged In", comment: "Not Logged In"), detail: "", buttonTitle: NSLocalizedString("Log In", comment: "Log In"))
            } else if !dataSource.isLocal &&  dataSource.camera?.ownerUserId != AccountControlManager.shared.keyChainMgr.userID {
                footer.show(
                    image: #imageLiteral(resourceName: "icon_video_cloud"),
                    title: NSLocalizedString("Camera Not Added", comment: "Camera Not Added"),
                    detail: "",
                    buttonTitle: NSLocalizedString("Add to My Account", comment: "Add to My Account")
                )
            } else if dataSource.isFetching {
                footer.startLoading()
            } else if dataSource.totalCount == 0 || dataSource.clipList.count == 0 {
                if dataSource.isLocal {
                    let isOffline = !(dataSource.camera?.viaWiFi ?? false)
                    if isOffline {
                        footer.show(
                            level: .warning,
                            title: NSLocalizedString("Camera Offline", comment: "Camera Offline"),
                            detail: NSLocalizedString("Connect your camera's Wi-Fi to access videos.", comment: "Connect your camera's Wi-Fi to access videos.")
                        )
                        return footer
                    }
                    if let state = dataSource.camera?.local?.storageState {
                        switch state {
                        case .error:
                            footer.show(
                                level: .error,
                                title: NSLocalizedString("SD Card Error", comment: "SD Card Error"),
                                detail: NSLocalizedString("Formatting may fix it.", comment: "Formatting may fix it.")
                            )
                            return footer
                        case .noStorage:
                            footer.show(
                                level: .error,
                                title: NSLocalizedString("No SD Card Detected", comment: "No SD Card Detected"),
                                detail: NSLocalizedString("Insert a SD card to enable monitoring.", comment: "Insert a SD card to enable monitoring.")
                            )
                            return footer
                        default:
                            break
                        }
                    }
                    footer.show(
                        image: #imageLiteral(resourceName: "icon_video_sdcard"),
                        title: NSLocalizedString("No Videos", comment: "No Videos"),
                        detail: NSLocalizedString("Take a drive and come back later.", comment: "Take a drive and come back later."),
                        buttonTitle: nil
                    )
                } else {
                    footer.show(
                        image: #imageLiteral(resourceName: "icon_video_cloud"),
                        title: NSLocalizedString("No Videos", comment: "No Videos"),
                        detail: NSLocalizedString("No videos uploaded in last 7 days.", comment: "No videos uploaded in last 7 days."),
                        buttonTitle: nil
                    )
                }
            } else {
                if dataSource.isLocal {
                    footer.show(
                        image: #imageLiteral(resourceName: "icon_video_sdcard"),
                        title: NSLocalizedString("No More Videos", comment: "No More Videos"),
                        detail: NSLocalizedString("Videos are loop recorded on the SD card.", comment: "Videos are loop recorded on the SD card."),
                        buttonTitle: nil
                    )
                } else {
                    footer.show(
                        image: #imageLiteral(resourceName: "icon_video_cloud"),
                        title: NSLocalizedString("No More Videos", comment: "No More Videos"),
                        detail: NSLocalizedString("Last 7 days of videos are stored on the cloud.", comment: "Last 7 days of videos are stored on the cloud."),
                        buttonTitle: nil
                    )
                }
            }
            return footer
        case CameraTimeLineLayout.supplementaryLiveButton:
            fallthrough
        default:
            let button = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: IndexPath(item: 0, section: 0)) as! CameraTimeLineLiveButton
            button.style = .vertical
            return button
        }
    }
}

extension CameraTimelineVerticalViewController: CameraTimeLineFooterDelegate {
    func onTapFooterButton() {
        delegate?.timelineDidTapFooterButton(self)
    }
}

extension CameraTimelineVerticalViewController: SectionIndexViewDelegate {

    func sectionIndexView(_ sectionIndexView: SectionIndexView, canSelectIndexItemAt index: Int) -> Bool {
        if IndexTitlesHelper.isDateIndex(index) {
            return false
        }
        return true
    }

    func sectionIndexView(_ sectionIndexView: SectionIndexView, sectionIndexTitlesForCollectionView collectionView: UICollectionView) -> [String] {
        if dataSource != nil {
            return IndexTitlesHelper.indexTitles(from: dataSource.dateList)
        }
        return []
    }

    func sectionIndexView(_ sectionIndexView: SectionIndexView, currentIndexDidChange currentIndex: Int?) {
        guard let currentIndex = currentIndex, !IndexTitlesHelper.isDateIndex(currentIndex) else {
            return
        }

        scrollTo(time: dataSource.dateList[currentIndex - 1])
    }

    func sectionIndexViewBeginIndexing(_ sectionIndexView: SectionIndexView) {
        scrollMode = .dragging
    }

    func sectionIndexViewEndIndexing(_ sectionIndexView: SectionIndexView) {
        scrollMode = .idle
    }

}

private class IndexTitlesHelper {
    private static let numberOfDaysToDisplay = 14
    private static let dateIndexTitle = NSLocalizedString("Date", comment: "")
    private static let earlierDateIndexTitle = NSLocalizedString("Ago", comment: "")

    class func indexTitles(from dates: [Date]) -> [String] {
        if dates.count > numberOfDaysToDisplay {
            let days = dates[0..<numberOfDaysToDisplay].map{"\(String(describing: $0.component(.day)!))"}
            return [dateIndexTitle] + days + [earlierDateIndexTitle]
        } else {
            let days = dates.map{"\(String(describing: $0.component(.day)!))"}
            return [dateIndexTitle] + days
        }
    }

    class func isDateIndex(_ index: Int) -> Bool {
        return index == 0
    }

    class func convert(_ section: Int, toIndexItemIndexIn indexView: SectionIndexView) -> Int {
        let lastIndexItemIndex = indexView.indexTitles.count - 1
        if section < lastIndexItemIndex {
            return section + 1
        } else {
            return lastIndexItemIndex
        }
    }

}
