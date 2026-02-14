//
//  HNSegmentedControl.swift
//  Acht
//
//  Created by Chester Shen on 8/21/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

// MARK: - HNSegmentedControl
@IBDesignable open class HNSegmentedControl: UIControl {
    // MARK: IndicatorView
    fileprivate class IndicatorView: UIView {
        // MARK: Properties
        var lineHeight: CGFloat = 2
        fileprivate let bottomLine = UIView()
        fileprivate let titleMaskView = UIView()
        fileprivate var cornerRadius: CGFloat = 0 {
            didSet {
                layer.cornerRadius = cornerRadius
                titleMaskView.layer.cornerRadius = cornerRadius
            }
        }
        var indicatorColor: UIColor? {
            get {
                return bottomLine.backgroundColor
            }
            
            set {
                bottomLine.backgroundColor = newValue
            }
        }
        
        override open var frame: CGRect {
            didSet {
                titleMaskView.frame = frame
                bottomLine.frame = CGRect(x: 0, y: frame.height - lineHeight, width: frame.width, height: lineHeight)
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
            addSubview(bottomLine)
        }
    }
    
    // MARK: Constants
    fileprivate struct Animation {
        fileprivate static let withBounceDuration: TimeInterval = 0.6
        fileprivate static let springDamping: CGFloat = 0.75
        fileprivate static let withoutBounceDuration: TimeInterval = 0.4
    }
    fileprivate struct Color {
        fileprivate static let background: UIColor = UIColor.white
        fileprivate static let title: UIColor = UIColor.black
        fileprivate static let indicatorViewBackground: UIColor = UIColor.black
        fileprivate static let selectedTitle: UIColor = UIColor.white
    }
    
    // MARK: Error handling
    public enum IndexError: Error {
        case indexBeyondBounds(UInt)
    }
    
    // MARK: Properties
    /// The selected index
    public fileprivate(set) var index: UInt
    /// The titles / options available for selection
    public var titles: [String] {
        get {
            let titleLabels = titleLabelsView.subviews as! [UILabel]
            return titleLabels.map { $0.text! }
        }
        set {
            let labels: [(UILabel, UILabel)] = newValue.map {
                (string) -> (UILabel, UILabel) in
                
                let titleLabel = UILabel()
                titleLabel.textColor = titleColor
                titleLabel.text = string
                titleLabel.lineBreakMode = .byTruncatingTail
                titleLabel.textAlignment = .center
                titleLabel.font = titleFont
                titleLabel.layer.borderWidth = titleBorderWidth
                titleLabel.layer.borderColor = titleBorderColor
                titleLabel.layer.cornerRadius = indicatorView.cornerRadius
                titleLabel.numberOfLines = titleNumberOfLines
                
                let selectedTitleLabel = UILabel()
                selectedTitleLabel.textColor = selectedTitleColor
                selectedTitleLabel.text = string
                selectedTitleLabel.lineBreakMode = .byTruncatingTail
                selectedTitleLabel.textAlignment = .center
                selectedTitleLabel.font = selectedTitleFont
                selectedTitleLabel.numberOfLines = titleNumberOfLines
                
                return (titleLabel, selectedTitleLabel)
            }
            
            titleLabelsView.subviews.forEach({ $0.removeFromSuperview() })
            selectedTitleLabelsView.subviews.forEach({ $0.removeFromSuperview() })
            
            for (inactiveLabel, activeLabel) in labels {
                titleLabelsView.addSubview(inactiveLabel)
                selectedTitleLabelsView.addSubview(activeLabel)
            }
            
            setNeedsLayout()
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
    /// The control's and indicator's corner radii
    @IBInspectable public var indicatorHeight: CGFloat {
        get {
            return indicatorView.lineHeight
        }
        set {
            indicatorView.lineHeight = newValue
            indicatorView.frame = indicatorView.frame
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            indicatorView.cornerRadius = newValue
            titleLabels.forEach { $0.layer.cornerRadius = indicatorView.cornerRadius }
        }
    }
    /// The indicator view's background color
    @IBInspectable public var indicatorColor: UIColor? {
        get {
            return indicatorView.indicatorColor
        }
        set {
            indicatorView.indicatorColor = newValue
        }
    }
    
    /// The indicator view's border width
    public var indicatorViewBorderWidth: CGFloat {
        get {
            return indicatorView.layer.borderWidth
        }
        set {
            indicatorView.layer.borderWidth = newValue
        }
    }
    /// The indicator view's border width
    public var indicatorViewBorderColor: CGColor? {
        get {
            return indicatorView.layer.borderColor
        }
        set {
            indicatorView.layer.borderColor = newValue
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
    
    override open var backgroundColor: UIColor? {
        didSet {
            indicatorView.backgroundColor = backgroundColor
        }
    }
    /// The titles' font
    public var titleFont: UIFont = UILabel().font {
        didSet {
            titleLabels.forEach { $0.font = titleFont }
        }
    }
    /// The selected title's font
    public var selectedTitleFont: UIFont = UILabel().font {
        didSet {
            selectedTitleLabels.forEach { $0.font = selectedTitleFont }
        }
    }
    /// The titles' border width
    public var titleBorderWidth: CGFloat = 0.0 {
        didSet {
            titleLabels.forEach { $0.layer.borderWidth = titleBorderWidth }
        }
    }
    /// The titles' number of lines
    public var titleNumberOfLines: Int = 1 {
        didSet {
            titleLabels.forEach { $0.numberOfLines = titleNumberOfLines }
            selectedTitleLabels.forEach { $0.numberOfLines = titleNumberOfLines }
        }
    }
    /// The titles' border color
    public var titleBorderColor: CGColor = UIColor.clear.cgColor {
        didSet {
            titleLabels.forEach { $0.layer.borderColor = titleBorderColor }
        }
    }
    
    /// The Shadow's color 
    public var shadowColor: UIColor = UIColor.lightGray {
        didSet {
            shadowView.backgroundColor = shadowColor
        }
    }
    
    // MARK: - Private properties
    fileprivate let titleLabelsView = UIView()
    fileprivate let selectedTitleLabelsView = UIView()
    fileprivate let indicatorView = IndicatorView()
    fileprivate let shadowView = UIView()
    fileprivate var initialIndicatorViewFrame: CGRect?
    
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer!
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer!
    
    fileprivate var width: CGFloat { return bounds.width }
    fileprivate var height: CGFloat { return bounds.height }
    fileprivate var titleLabelsCount: Int { return titleLabelsView.subviews.count }
    var titleLabels: [UILabel] { return titleLabelsView.subviews as! [UILabel] }
    fileprivate var selectedTitleLabels: [UILabel] { return selectedTitleLabelsView.subviews as! [UILabel] }
    fileprivate lazy var defaultTitles: [String] = { return ["First", "Second"] }()
    
    // MARK: Lifecycle
    required public init?(coder aDecoder: NSCoder) {
        index = 0
        titleColor = Color.title
        selectedTitleColor = Color.selectedTitle
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
        super.init(frame: frame)
        self.titles = titles
        self.backgroundColor = backgroundColor
        self.indicatorColor = indicatorColor
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
        addSubview(shadowView)
        addSubview(indicatorView)
        addSubview(selectedTitleLabelsView)
        selectedTitleLabelsView.layer.mask = indicatorView.titleMaskView.layer
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HNSegmentedControl.tapped(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(HNSegmentedControl.panned(_:)))
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
        titleLabelsView.frame = bounds
        selectedTitleLabelsView.frame = bounds
        guard titleLabelsCount > 0 else { return }
        indicatorView.frame = elementFrame(forIndex: index)
        shadowView.frame = CGRect(x: 0, y: bounds.height - indicatorHeight, width: bounds.width, height: indicatorHeight)
        for index in 0...titleLabelsCount-1 {
            let frame = elementFrame(forIndex: UInt(index))
            titleLabelsView.subviews[index].frame = frame
            selectedTitleLabelsView.subviews[index].frame = frame
        }
        indicatorView.bottomLine.isHidden = (titleLabelsCount == 1)
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
        let oldIndex = self.index
        self.index = index
        moveIndicatorViewToIndex(animated, shouldSendEvent: (self.index != oldIndex || alwaysAnnouncesValue))
    }
    
    // MARK: Indicator View Customization
    /**
     Adds the passed view as a subview to the indicator view
     
     - parameter view: The view to be added to the indicator view
     
     - note: The added view must be able to layout & size itself and will not be autoresized.
     */
    public func addSubviewToIndicator(_ view: UIView) {
        indicatorView.addSubview(view)
    }
    
    // MARK: Animations
    fileprivate func moveIndicatorViewToIndex(_ animated: Bool, shouldSendEvent: Bool) {
        if animated {
            if shouldSendEvent && announcesValueImmediately {
                sendActions(for: .valueChanged)
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
                    self.sendActions(for: .valueChanged)
                }
            })
        } else {
            moveIndicatorView()
            sendActions(for: .valueChanged)
        }
    }
    
    // MARK: Helpers
    fileprivate func elementFrame(forIndex index: UInt) -> CGRect {
        let elementWidth = width / CGFloat(max(1, titleLabelsCount))
        return CGRect(x: CGFloat(index) * elementWidth,
                      y: 0,
                      width: elementWidth,
                      height: height)
    }
    
    fileprivate func nearestIndex(toPoint point: CGPoint) -> UInt {
        let distances = titleLabels.map { abs(point.x - $0.center.x) }
        return UInt(distances.firstIndex(of: distances.min()!)!)
    }
    fileprivate func moveIndicatorView() {
        indicatorView.frame = titleLabels[Int(self.index)].frame
        layoutIfNeeded()
    }
    
    // MARK: Action handlers
    @objc fileprivate func tapped(_ gestureRecognizer: UITapGestureRecognizer!) {
        let location = gestureRecognizer.location(in: self)
        try! setIndex(nearestIndex(toPoint: location))
    }
    @objc fileprivate func panned(_ gestureRecognizer: UIPanGestureRecognizer!) {
        guard !panningDisabled else {
            return
        }
        
        switch gestureRecognizer.state {
        case .began:
            initialIndicatorViewFrame = indicatorView.frame
        case .changed:
            var frame = initialIndicatorViewFrame!
            frame.origin.x += gestureRecognizer.translation(in: self).x
            frame.origin.x = max(min(frame.origin.x, bounds.width - frame.width), 0)
            indicatorView.frame = frame
        case .ended, .failed, .cancelled:
            try! setIndex(nearestIndex(toPoint: indicatorView.center))
        default: break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension HNSegmentedControl: UIGestureRecognizerDelegate {
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGestureRecognizer {
            return indicatorView.frame.contains(gestureRecognizer.location(in: self))
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
