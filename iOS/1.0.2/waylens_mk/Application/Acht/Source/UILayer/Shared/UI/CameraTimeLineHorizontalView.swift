//
//  CameraTimeLineHorizontalView.swift
//  CameraTimeLineHorizontalView
//
//  Created by forkon on 2018/8/22.
//  Copyright © 2018 Waylens. All rights reserved.
//

import UIKit
import WaylensFoundation

class CameraTimeLineHorizontalView: UIView, CameraTimeline {
    var lineOffset: CGFloat {
        return collectionView.contentOffset.x + lineInset + offsetResidual
    }
    private var offsetResidual: CGFloat = 0
    var liveOffset: CGFloat {
        return layout.frameForLive().midX
    }
    var lineInset: CGFloat {
        return bounds.width / 2 - collectionContainer.frame.minX
    }
    var isInLivePositon: Bool {
        return abs(lineOffset - liveOffset) < 1
    }
    
    let layout = CameraTimeLineHorizontalLayout()
    var dataSource: CameraTimeLineDataSource! {
        didSet {
            layout.dataSource = dataSource
            reloadData()
        }
    }
    
    var scrollMode: CameraTimelineScrollMode = .idle {
        didSet {
            if scrollMode != oldValue {
                delegate?.timeline(self, didChangeScrollModeFrom:oldValue, to:scrollMode)
            }
        }
    }
    
    weak var delegate: CameraTimelineDelegate?
    
    fileprivate let cellIdentifier = "SegmentCell"
    fileprivate let notchWidth: CGFloat = 1.0
    
    var collectionView: UICollectionView!
    fileprivate var notch: UIView!
    var liveButton: UIButton!
    var collectionContainer: UIView!
    
    var isDisplaying: Bool {
        return superview != nil && !isHidden
    }
    
    private var lastSize: CGSize = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if lastSize != bounds.size {
            lastSize = bounds.size
            notch.frame = CGRect(x: lineInset + collectionContainer.frame.minX, y: collectionView.frame.minY, width: notchWidth, height: collectionView.frame.height)
            collectionView.contentInset = UIEdgeInsets(top: 0, left: lineInset, bottom: 0, right: collectionView.bounds.width - lineInset)
            layout.invalidateLayout()
            collectionContainer.fadedLeftRightEdges(leftEdgeInset: 26, rightEdgeInset: 26)
        }
    }
    
    func refreshUI() {
        refreshLiveline()
        refreshLiveButton()
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func isCrossingLiveButton() -> Bool {
        return layout.isCrossingLiveButton(lineOffset)
    }
    
    func setLineOffset(_ offset:CGFloat, animated:Bool=false) {
        let scale = UIScreen.main.scale
        let adjusted = ceil((offset - lineInset) * scale) / scale
        offsetResidual = offset - lineInset - adjusted
        if animated {
            stopScrolling()
            scrollMode = .animating
        }
        collectionView.setContentOffset(CGPoint(x:adjusted, y:0), animated: animated)
    }
    
    func scrollTo(time: Date) {
        let offset = layout.contentOffsetFor(time) ?? liveOffset
        setLineOffset(offset)
    }
    
    func scrollToItem(at indexPath: IndexPath, animated:Bool) {
        guard let attributes = collectionView.safeLayoutAttributesForItem(at: indexPath) else { return }
        scrollTo(offset: attributes.frame.minX, animated:animated)
    }
    
    func scrollToLive(animated:Bool) {
        scrollTo(offset: liveOffset, animated:animated)
    }
    
    private func stopScrolling() {
        guard scrollMode.isActive else { return }
        collectionView.setContentOffset(collectionView.contentOffset, animated: false)
    }
    
    func updateTime(_ time: Date?, timeString: String?) {
        
    }
    
    func endOffsetForItem(at indexPath: IndexPath) -> CGFloat? {
        return collectionView.safeLayoutAttributesForItem(at: indexPath)?.frame.maxX
    }
    
    func indexInfo(at offset: CGFloat) -> (IndexPath?, TimeInterval, HNClipSegment?) {
        return layout.indexAndTimeAndSegmentAt(offset)
    }
    
    func currentIndexInfo() -> (IndexPath?, TimeInterval, HNClipSegment?) {
        return indexInfo(at: lineOffset)
    }
    
    fileprivate func setup() {
        clipsToBounds = false
        collectionContainer = UIView(frame: bounds)
        addSubview(collectionContainer)
        collectionContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -100).isActive = true
        collectionContainer.leftAnchor.constraint(equalTo: leftAnchor, constant: 70).isActive = true
        collectionContainer.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionContainer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionContainer.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CameraTimelineEventCell.self, forCellWithReuseIdentifier: cellIdentifier)
    collectionView.register(UINib(nibName:CameraTimeLineLayout.supplementaryLiveButton, bundle:nil), forSupplementaryViewOfKind: CameraTimeLineLayout.supplementaryLiveButton, withReuseIdentifier: CameraTimeLineLayout.supplementaryLiveButton)
    collectionView.register(UINib(nibName:CameraTimeLineLayout.supplementaryThumbnail, bundle:nil), forSupplementaryViewOfKind: CameraTimeLineLayout.supplementaryThumbnail, withReuseIdentifier: CameraTimeLineLayout.supplementaryThumbnail)
        collectionContainer.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.frame = collectionContainer.bounds
        collectionView.translatesAutoresizingMaskIntoConstraints = true
        
        notch = UIView()
        notch.backgroundColor = UIColor.semanticColor(.tint(.primary))
        notch.layer.masksToBounds = true
        addSubview(notch)
        
        liveButton = UIButton(frame: CGRect(x: 0, y: 0, width: 73, height: 30))
        liveButton.setTitleColor(UIColor.semanticColor(.tint(.primary)), for: .normal)
        liveButton?.setTitle("Live", for: .normal)
        liveButton?.addTarget(self, action: #selector(liveButtonTapped(_:)), for: .touchUpInside)
        addSubview(liveButton)
    }
    
    func refreshLiveButton() {
        var frame = collectionView.convert(layout.frameForLive(), to: self)
        let rightAnchor = bounds.width - layout.liveButtonWidth - 27
        let ratio = 1 - (rightAnchor - frame.origin.x) / 30
        frame.origin.x = min(rightAnchor, frame.origin.x)
        liveButton.frame = frame
        setLiveButtonStyle(ratio:ratio)
    }
    
    private func linearValue(a:CGFloat, b:CGFloat, ratio: CGFloat, grid:Bool=false) -> CGFloat {
        var v = a + (b - a) * ratio
        if grid {
            let scale = UIScreen.main.scale
            v = floor(v * scale) / scale
        }
        return v
    }
    
    func setLiveButtonStyle(ratio: CGFloat) {
        let progress = min(1, max(0, ratio))
        var frame = liveButton.frame
        let newSize = CGSize(width: linearValue(a: frame.width, b: 73, ratio: progress, grid:true),
                             height: linearValue(a: frame.height, b: 30, ratio: progress, grid:true))
        frame.size = newSize
        frame.origin = CGPoint(x: frame.origin.x, y: liveButton.frame.midY - newSize.height / 2)
        liveButton.frame = frame
        if progress <= 0 {
            liveButton.setImage(nil, for: .normal)
        } else {
            liveButton.setImage(UIImage(named: "right_arrow_white"), for: .normal)
        }
        
        let inset = linearValue(a: 0, b: 4, ratio: progress, grid: true)
        liveButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: inset)
        liveButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: 0)
        liveButton.backgroundColor = UIColor.white.withAlphaComponent(linearValue(a: 0.2, b: 0, ratio: progress))
        liveButton.layer.borderWidth = linearValue(a: 0, b: 1, ratio: progress)
        liveButton.layer.borderColor = UIColor.semanticColor(.tint(.primary)).cgColor
        liveButton.layer.cornerRadius = linearValue(a: 3, b: frame.height / 2, ratio: progress)
        let _weight = linearValue(a: UIFont.Weight.heavy.rawValue, b: UIFont.Weight.medium.rawValue, ratio: progress)
        let weight = UIFont.Weight(_weight)
        liveButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: weight)
    }
    
    func refreshLiveline() {
        if isCrossingLiveButton() {
            let frame = collectionView.convert(layout.frameForLive(), to: notch)
            let path = UIBezierPath(rect: notch.bounds)
            let buttonPath = UIBezierPath(roundedRect: frame, cornerRadius: 3)
            path.append(buttonPath)
            let maskLayer = CAShapeLayer()
            maskLayer.fillRule = .evenOdd
            maskLayer.path = path.cgPath
            notch.layer.mask = maskLayer
        } else {
            notch.layer.mask = nil
        }
    }
}

extension CameraTimeLineHorizontalView {
    
    @objc func liveButtonTapped(_ sender: UIButton) {
        if !isInLivePositon {
            scrollToLive(animated: true)
            delegate?.timelineWillGoLive(self)
        }
    }
    
}

extension CameraTimeLineHorizontalView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x <= scrollView.frame.width / 3 {
            delegate?.timelineIsCloseToEnd(self)
        }
        delegate?.timelineDidScroll(self)
        refreshUI()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        Log.verbose("will begin dragging at \(scrollView.contentOffset.x)")
        offsetResidual = 0
        if scrollMode == .animating {
            scrollMode = .dragging
            stopScrolling()
        } else {
            scrollMode = .dragging
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        Log.verbose("did end dragging decelerate:\(decelerate) at \(scrollView.contentOffset.x)")
        if decelerate {
            scrollMode = .decelerating
        } else {
            scrollMode = .idle
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        Log.verbose("did end decelerating at \(scrollView.contentOffset.x)")
        scrollMode = .idle
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        Log.verbose("did end animation at \(scrollView.contentOffset.x)")
        if scrollMode == .animating {
            scrollMode = .idle
        }
    }
}

extension CameraTimeLineHorizontalView: TimeLineCollectionViewDelegate {
    func layoutDidPrepare() {
        delegate?.timelineDidPrepareLayout(self)
    }
}

extension CameraTimeLineHorizontalView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return max(dataSource.clipList.count, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if dataSource.clipList.count <= section {
            return 0
        }
        return dataSource.clipList[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CameraTimelineEventCell
        if let clip = dataSource?.clipWithIndex(indexPath) {
            cell.clip = clip
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case CameraTimeLineLayout.supplementaryThumbnail:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! CameraTimeLineThumbnail
            guard let data = layout.thumbnail(atIndex: indexPath),
                let clip = data.clip
                else { return view }
            view.data = data
            if view.imageView.image == nil {
                view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            }
            if dataSource.isLocal {
                if let camera = dataSource.camera, let rawClip = clip.rawClip, let time = data.pts {
                    let request = VDBThumbnailRequest(cameraID: camera.sn, clip: rawClip, pts: time, cache: true, ignorable: false)
                    view.imageView.vdb_setThumbnail(request, animated:true)
                    data.image = view.imageView.image_future
                }
            } else {
                if let thumbnailUrl = clip.thumbnailUrl, let url = URL(string: thumbnailUrl) {
                    view.imageView.hn_setImage(url: url, facedown: clip.facedown,
                                               dewarp: dataSource?.needDewarp ?? true,
                                               placeholderImage: nil)
                }
            }
            return view
        case CameraTimeLineLayout.supplementaryLiveButton:
            fallthrough
        default:
            let button = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: IndexPath(item: 0, section: 0)) as! CameraTimeLineLiveButton
            button.style = .horizontal
            return button
        }
    }
}

extension UICollectionView {
    
    fileprivate func cellFrame(at indexPath: IndexPath) -> CGRect? {
        guard let layoutAttributes = safeLayoutAttributesForItem(at: indexPath) else {
            return nil
        }
        return layoutAttributes.frame
    }
    
    func safeLayoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.section < numberOfSections,
            indexPath.item < numberOfItems(inSection: indexPath.section),
            let attributes = collectionViewLayout.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        return attributes
    }
    
    func convertLiveCellFrame(to targetView: UIView) -> CGRect? {
        var rect: CGRect? = nil
        visibleCells.forEach { (cell) in
            if let cell = cell as? CameraTimeLineHorizontalLiveCell {
                rect = convert(cell.frame, to: targetView)
                rect?.origin.y += cell.imageView.frame.minY
                rect?.size.height -= cell.imageView.frame.minY
                rect = rect?.insetBy(dx: 0.0, dy: 2.0)
                return
            }
        }
        return rect
    }
    
}
