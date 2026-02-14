//
//  HNSegmentedSlider.swift
//  Acht
//
//  Created by Chester Shen on 9/13/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit


// MARK: - HNSegmentedSlider
@IBDesignable open class HNSegmentedSlider: UIControl {
    // MARK: IndicatorView
    fileprivate class IndicatorView: UIView {
        // MARK: Properties
        fileprivate let titleMaskView = UIView()
        fileprivate var cornerRadius: CGFloat = 0 {
            didSet {
                layer.cornerRadius = cornerRadius
                titleMaskView.layer.cornerRadius = cornerRadius
            }
        }
       
        override open var frame: CGRect {
            didSet {
                titleMaskView.frame = frame
            }
        }
        
        // MARK: Lifecycle
        init() {
            super.init(frame: CGRect.zero)
            finishInit()
        }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            finishInit()
        }
        fileprivate func finishInit() {
            layer.masksToBounds = true
            titleMaskView.backgroundColor = UIColor.black
        }
    }
    
    // MARK: Constants
    fileprivate struct Animation {
        fileprivate static let withBounceDuration: TimeInterval = 0.7
        fileprivate static let springDamping: CGFloat = 0.75
        fileprivate static let withoutBounceDuration: TimeInterval = 0.5
    }
    fileprivate struct Color {
        fileprivate static let background: UIColor = UIColor.lightGray
        fileprivate static let title: UIColor = UIColor.black
        fileprivate static let indicatorViewBackground: UIColor = UIColor.white
        fileprivate static let selectedTitle: UIColor = UIColor.orange
    }
    
    // MARK: Error handling
    public enum IndexError: Error {
        case indexBeyondBounds(UInt)
    }
    
    // MARK: Properties
    /// The selected index
    public fileprivate(set) var index: UInt
    /// The titles / options available for selection
    
    private func generateLabel(text:String, textColor: UIColor, font: UIFont) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.textColor = textColor
        titleLabel.text = text
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .center
        titleLabel.font = font
        titleLabel.numberOfLines = titleNumberOfLines
        return titleLabel
    }
    
    public var titles: [String] {
        get {
            let titleLabels = titleLabelsView.subviews as! [UILabel]
            return titleLabels.map { $0.text! }
        }
        set {
            if Int(index) >= newValue.count {
                index = UInt(max(0, newValue.count - 1))
            }
            let labels = newValue.map {
                (string) -> (UILabel, UILabel, UILabel) in
                
                let titleLabel = generateLabel(text: string, textColor: titleColor, font: titleFont)
                let selectedTitleLabel = generateLabel(text: string, textColor: selectedTitleColor, font: titleFont)
                let coveredTitleLabel = generateLabel(text: string, textColor: coveredTitleColor, font: titleFont)
                return (titleLabel, selectedTitleLabel, coveredTitleLabel)
            }
            
            titleLabelsView.subviews.forEach({ $0.removeFromSuperview() })
            selectedTitleLabelsView.subviews.forEach({ $0.removeFromSuperview() })
            coveredTitleLabelsView.subviews.forEach({ $0.removeFromSuperview() })
            
            for (inactiveLabel, activeLabel, coveredLabel) in labels {
                titleLabelsView.addSubview(inactiveLabel)
                selectedTitleLabelsView.addSubview(activeLabel)
                coveredTitleLabelsView.addSubview(coveredLabel)
            }
            
            setNeedsLayout()
        }
    }
    
    public var tintColors: [UIColor]? {
        didSet {
            moveIndicatorView()
        }
    }
    
    private func currentTintColor(forIndex index:UInt) -> UIColor {
        if let tintColors = tintColors, tintColors.count > Int(index) {
            return tintColors[Int(index)]
        } else {
            return selectedTitleColor
        }
    }
    
    private func currentCoverColor(forIndex index:UInt) -> UIColor {
        if let tintColors = tintColors, tintColors.count > Int(index) {
            return tintColors[Int(index)]
        } else {
            return coverColor ?? selectedTitleColor
        }
    }
    /// Whether the indicator should bounce when selecting a new index. Defaults to true
    public var bouncesOnChange = true
    /// Whether the the control should always send the .ValueChanged event, regardless of the index remaining unchanged after interaction. Defaults to false
    public var alwaysAnnouncesValue = false
    /// Whether to send the .ValueChanged event immediately or wait for animations to complete. Defaults to true
    public var announcesValueImmediately = true
    /// Whether the the control should ignore pan gestures. Defaults to false
    public var panningDisabled = false
    
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            indicatorView.cornerRadius = newValue - indicatorInset
            coverView.cornerRadius = newValue
            titleLabels.forEach { $0.layer.cornerRadius = indicatorView.cornerRadius }
        }
    }
    /// The indicator view's background color
    @IBInspectable public var indicatorColor: UIColor? {
        get {
            return indicatorView.backgroundColor
        }
        set {
            indicatorView.backgroundColor = newValue
        }
    }
    
    /// The cover view's background color
    @objc public var coverColor: UIColor? {
        get {
            return coverView.backgroundColor
        }
        set {
            coverView.backgroundColor = newValue
        }
    }
    
    /// The indicator inset
    @IBInspectable public var indicatorInset: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    /// The text color of the non-selected titles / options
    @IBInspectable public var titleColor: UIColor  {
        didSet {
            titleLabels.forEach { $0.textColor = titleColor }
        }
    }
    /// The text color of the selected title / option
    @IBInspectable public var selectedTitleColor: UIColor {
        didSet {
            selectedTitleLabels.forEach { $0.textColor = selectedTitleColor }
        }
    }
    
    /// The text color of the selected title / option
    public var coveredTitleColor: UIColor {
        didSet {
            coveredTitleLabels.forEach { $0.textColor = coveredTitleColor }
        }
    }
    
    /// The titles' font
    public var titleFont: UIFont = UILabel().font {
        didSet {
            titleLabels.forEach { $0.font = titleFont }
            selectedTitleLabels.forEach { $0.font = titleFont }
            coveredTitleLabels.forEach { $0.font = titleFont }
        }
    }
    
    /// The titles' number of lines
    public var titleNumberOfLines: Int = 1 {
        didSet {
            titleLabels.forEach { $0.numberOfLines = titleNumberOfLines }
            selectedTitleLabels.forEach { $0.numberOfLines = titleNumberOfLines }
            coveredTitleLabels.forEach { $0.numberOfLines = titleNumberOfLines }
        }
    }
    
    // MARK: - Private properties
    fileprivate let titleLabelsView = UIView()
    fileprivate let selectedTitleLabelsView = UIView()
    fileprivate let coveredTitleLabelsView = UIView()
    fileprivate let indicatorView = IndicatorView()
    fileprivate var initialIndicatorViewFrame: CGRect?
    
    fileprivate var coverView = IndicatorView()
    
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer!
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer!
    
    fileprivate var width: CGFloat { return bounds.width }
    fileprivate var height: CGFloat { return bounds.height }
    fileprivate var titleLabelsCount: Int { return titleLabelsView.subviews.count }
    fileprivate var titleLabels: [UILabel] { return titleLabelsView.subviews as! [UILabel] }
    fileprivate var selectedTitleLabels: [UILabel] { return selectedTitleLabelsView.subviews as! [UILabel] }
    fileprivate var coveredTitleLabels: [UILabel] { return coveredTitleLabelsView.subviews as! [UILabel] }
    fileprivate lazy var defaultTitles: [String] = { return ["First", "Second"] }()
    private var isPanning: Bool = false
    private var sentValue: UInt?
    // MARK: Lifecycle
    required public init?(coder aDecoder: NSCoder) {
        index = 0
        titleColor = Color.title
        selectedTitleColor = Color.selectedTitle
        self.coveredTitleColor = Color.indicatorViewBackground
        super.init(coder: aDecoder)
        titles = defaultTitles
        finishInit()
    }
    public init(frame: CGRect,
                titles: [String],
                index: UInt,
                backgroundColor: UIColor,
                titleColor: UIColor,
                indicatorColor: UIColor,
                selectedTitleColor: UIColor) {
        self.index = index
        self.titleColor = titleColor
        self.selectedTitleColor = selectedTitleColor
        self.coveredTitleColor = indicatorColor
        super.init(frame: frame)
        self.titles = titles
        self.backgroundColor = backgroundColor
        self.indicatorColor = indicatorColor
        self.coverColor = selectedTitleColor
        finishInit()
    }
    @available(*, deprecated, message: "Use init(frame:titles:index:backgroundColor:titleColor:indicatorColor:selectedTitleColor:) instead.")
    convenience override public init(frame: CGRect) {
        self.init(frame: frame,
                  titles: ["First", "Second"],
                  index: 0,
                  backgroundColor: Color.background,
                  titleColor: Color.title,
                  indicatorColor: Color.indicatorViewBackground,
                  selectedTitleColor: Color.selectedTitle)
    }
    
    @available(*, unavailable, message: "Use init(frame:titles:index:backgroundColor:titleColor:indicatorColor:selectedTitleColor:) instead.")
    convenience init() {
        self.init(frame: CGRect.zero,
                  titles: ["First", "Second"],
                  index: 0,
                  backgroundColor: Color.background,
                  titleColor: Color.title,
                  indicatorColor: Color.indicatorViewBackground,
                  selectedTitleColor: Color.selectedTitle)
    }
    fileprivate func finishInit() {
        layer.masksToBounds = true
        
        addSubview(titleLabelsView)
        addSubview(coverView)
        addSubview(coveredTitleLabelsView)
        addSubview(indicatorView)
        addSubview(selectedTitleLabelsView)
        coveredTitleLabelsView.layer.mask = coverView.titleMaskView.layer
        selectedTitleLabelsView.layer.mask = indicatorView.titleMaskView.layer
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HNSegmentedSlider.tapped(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(HNSegmentedSlider.panned(_:)))
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        titleLabelsView.frame = bounds
        coveredTitleLabelsView.frame = bounds
        selectedTitleLabelsView.frame = bounds
        if !isPanning {
            indicatorView.frame = elementFrame(forIndex: index)
            coverView.frame = coverFrame(toIndex: index)
        }
        for index in 0...titleLabelsCount-1 {
            let frame = elementFrame(forIndex: UInt(index))
            titleLabelsView.subviews[index].frame = frame
            selectedTitleLabelsView.subviews[index].frame = frame
            coveredTitleLabelsView.subviews[index].frame = frame
        }
    }
    
    // MARK: Index Setting
    /**
     Sets the control's index.
     
     - parameter index:    The new index
     - parameter animated: (Optional) Whether the change should be animated or not. Defaults to true.
     
     - throws: An error of type IndexBeyondBounds(UInt) is thrown if an index beyond the available indices is passed.
     */
    public func setIndex(_ index: UInt, animated: Bool = true) throws {
        guard titleLabels.indices.contains(Int(index)) else {
            throw IndexError.indexBeyondBounds(index)
        }
        if !isPanning {
            _setIndex(index, animated: animated, triggered: false)
        }
    }
    
    private func _setIndex(_ index: UInt, animated: Bool = true, triggered:Bool=true) {
        self.index = index
        moveIndicatorViewToIndex(animated, shouldSendEvent: (triggered && (self.index != sentValue || alwaysAnnouncesValue || !isPanning)))
    }
    
    // MARK: Animations
    fileprivate func moveIndicatorViewToIndex(_ animated: Bool, shouldSendEvent: Bool) {
        if animated {
            if shouldSendEvent && announcesValueImmediately {
                sentValue = self.index
                sendActions(for: isPanning ? .valueChanged : .primaryActionTriggered)
            }
            UIView.animate(withDuration: bouncesOnChange ? Animation.withBounceDuration : Animation.withoutBounceDuration,
                           delay: 0.0,
                           usingSpringWithDamping: bouncesOnChange ? Animation.springDamping : 1.0,
                           initialSpringVelocity: 0.0,
                           options: [.beginFromCurrentState, .curveEaseOut],
                           animations: {
                            () -> Void in
                            self.moveIndicatorView()
            }, completion: { (finished) -> Void in
                if finished && shouldSendEvent && !self.announcesValueImmediately {
                    self.sentValue = self.index
                    self.sendActions(for: self.isPanning ? .valueChanged : .primaryActionTriggered)
                }
            })
        } else {
            moveIndicatorView()
            if shouldSendEvent {
                sentValue = self.index
                sendActions(for: isPanning ? .valueChanged : .primaryActionTriggered)
            }
        }
    }
    
    // MARK: Helpers
    fileprivate func elementFrame(forIndex index: UInt) -> CGRect {
        let elementWidth = width / CGFloat(titleLabelsCount)
        return CGRect(x: CGFloat(index) * elementWidth + indicatorInset,
                      y: indicatorInset,
                      width: elementWidth - 2 * indicatorInset,
                      height: height - 2 * indicatorInset)
    }
    
    fileprivate func coverFrame(toIndex index: UInt) -> CGRect {
        let coverWidth = width / CGFloat(titleLabelsCount) * CGFloat(index + 1)
        return CGRect(x: 0, y: 0, width: coverWidth, height: height)
    }
    
    fileprivate func nearestIndex(toPoint point: CGPoint) -> UInt {
        let distances = titleLabels.map { abs(point.x - $0.center.x) }
        return UInt(distances.firstIndex(of: distances.min()!)!)
    }
    fileprivate func moveIndicatorView() {
        if !isPanning {
            indicatorView.frame = titleLabels[Int(self.index)].frame
            coverView.frame = coverFrame(toIndex: self.index)
        }
        if tintColors != nil {
            coverColor = currentTintColor(forIndex: index)
            selectedTitleColor = currentTintColor(forIndex: index)
        }
        layoutIfNeeded()
    }
    
    // MARK: Action handlers
    @objc fileprivate func tapped(_ gestureRecognizer: UITapGestureRecognizer!) {
        let location = gestureRecognizer.location(in: self)
        _setIndex(nearestIndex(toPoint: location))
    }
    @objc fileprivate func panned(_ gestureRecognizer: UIPanGestureRecognizer!) {
        guard !panningDisabled else {
            return
        }
        
        switch gestureRecognizer.state {
        case .began:
            isPanning = true
            initialIndicatorViewFrame = indicatorView.frame
        case .changed:
            var frame = initialIndicatorViewFrame!
            frame.origin.x += gestureRecognizer.translation(in: self).x
            frame.origin.x = max(min(frame.origin.x, bounds.width - indicatorInset - frame.width), indicatorInset)
            coverView.frame = CGRect(x: 0, y: 0, width: frame.maxX + indicatorInset, height: height)
            indicatorView.frame = frame
            _setIndex(nearestIndex(toPoint: indicatorView.center))
        case .ended, .failed, .cancelled:
            isPanning = false
            _setIndex(nearestIndex(toPoint: indicatorView.center))
        default: break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension HNSegmentedSlider: UIGestureRecognizerDelegate {
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            return indicatorView.frame.contains(gestureRecognizer.location(in: self))
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
