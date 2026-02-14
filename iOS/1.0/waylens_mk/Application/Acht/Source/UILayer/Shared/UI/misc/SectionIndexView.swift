//
//  SectionIndexView.swift
//  Acht
//
//  Created by forkon on 2019/7/11.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

protocol SectionIndexViewDelegate: class {
    func sectionIndexView(_ sectionIndexView: SectionIndexView, sectionIndexTitlesForCollectionView collectionView: UICollectionView) -> [String]

    /* Optional */

    func sectionIndexView(_ sectionIndexView: SectionIndexView, canSelectIndexItemAt index: Int) -> Bool
    func sectionIndexView(_ sectionIndexView: SectionIndexView, currentIndexDidChange currentIndex: Int?)
    func sectionIndexViewBeginIndexing(_ sectionIndexView: SectionIndexView)
    func sectionIndexViewEndIndexing(_ sectionIndexView: SectionIndexView)

    //    func sectionIndexView(_ sectionIndexView: SectionIndexView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
}

extension SectionIndexViewDelegate {

    func sectionIndexView(_ sectionIndexView: SectionIndexView, canSelectIndexItemAt index: Int) -> Bool {
        return true
    }

    func sectionIndexView(_ sectionIndexView: SectionIndexView, currentIndexDidChange currentIndex: Int?) {

    }

    func sectionIndexViewBeginIndexing(_ sectionIndexView: SectionIndexView) {

    }

    func sectionIndexViewEndIndexing(_ sectionIndexView: SectionIndexView) {

    }
}

class SectionIndexView: UIView {
    var currentIndex: Int? = nil
    private var currentIndicator: SectionIndexViewIndicator = {
        let currentIndicator = SectionIndexViewIndicator(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 7.0, height: 9.0)))
        currentIndicator.isHidden = true
        return currentIndicator
    }()
    private var indexItems: [SectionIndexViewItem] = []
    private var indexItemsContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    private var edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 2.0, bottom: 24.0, right: 6.0)

    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var tapGestureRecognizer: UITapGestureRecognizer!

    private weak var collectionView: UICollectionView?
    private weak var delegate: SectionIndexViewDelegate?

    private var isTouching = false

    private(set) var width: CGFloat = 33.0
    private(set) var indexTitles: [String] = []

    init(collectionView: UICollectionView, delegate: SectionIndexViewDelegate) {
        super.init(frame: CGRect.zero)

        self.collectionView = collectionView
        self.delegate = delegate

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if let superview = superview {
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            widthAnchor.constraint(equalToConstant: width).isActive = true

            reloadView()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        currentIndicator.frame.origin = CGPoint.zero
        layoutIndexItemsContainerView()
        layoutIndexItems()
    }

    func reloadView() {
        guard !isTouching else {
            return
        }

        guard let collectionView = collectionView, let indexTitles = delegate?.sectionIndexView(self, sectionIndexTitlesForCollectionView: collectionView) else {
            return
        }

        if !indexTitles.isAllElementsSame(to: self.indexTitles) {
            totallyReloadView()
        }
    }

    func scroll(to targetSectionIndex: Int) {
        currentIndicator.isHidden = true
        for (i, indexItem) in indexItems.enumerated() {
            if i == targetSectionIndex {
                currentIndicator.indicate(indexItem.convert(indexItem.bounds, to: self))
                indexItem.isSelected = true
                currentIndex = i
            } else {
                indexItem.isSelected = false
            }
        }

        if isTouching {
            showContactIndexShape(for: targetSectionIndex)
        } else {
            hideContactIndexShape()
        }
    }

}

private extension SectionIndexView {

    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear

        addSubview(indexItemsContainerView)
        addSubview(currentIndicator)

        collectionView?.showsVerticalScrollIndicator = false

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        indexItemsContainerView.addGestureRecognizer(panGestureRecognizer)

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        indexItemsContainerView.addGestureRecognizer(tapGestureRecognizer)
    }

    func totallyReloadView() {
        guard let collectionView = collectionView else {
            return
        }

        indexTitles = delegate?.sectionIndexView(self, sectionIndexTitlesForCollectionView: collectionView) ?? []

        indexItems.removeAll()

        if !indexTitles.isEmpty {
            indexItemsContainerView.subviews.forEach { (subview) in
                subview.removeFromSuperview()
            }

            indexTitles.forEach { (title) in
                let item = SectionIndexViewItem()
                item.title = title
                indexItems.append(item)
                indexItemsContainerView.addSubview(item)
            }

            setNeedsLayout()
        }

    }

    func showContactIndexShape(for index: Int) {

    }

    func hideContactIndexShape() {

    }

    func layoutIndexItemsContainerView() {
        indexItemsContainerView.frame = bounds.inset(by: edgeInsets)
    }

    func layoutIndexItems() {
        let itemWidth: CGFloat = indexItemsContainerView.frame.width
        let maxItemHeight: CGFloat = 24.0
        var itemHeight: CGFloat = indexItemsContainerView.frame.height / CGFloat(indexItems.count)

        if itemHeight > maxItemHeight {
            itemHeight = maxItemHeight
        }

        for (i, indexItem) in indexItems.enumerated() {
            let itemY: CGFloat = (indexItemsContainerView.frame.height - itemHeight * CGFloat(indexItems.count)) / 2 + itemHeight * CGFloat(i)

            indexItem.frame = CGRect(x: 0.0, y: itemY, width: itemWidth, height: itemHeight)

            if indexItem.isSelected {
                currentIndicator.indicate(indexItem.convert(indexItem.bounds, to: self))
            }
        }
    }

    func selectIndexItem(at location: CGPoint) {
        for (i, indexItem) in indexItems.enumerated() {
            if delegate?.sectionIndexView(self, canSelectIndexItemAt: i) == true
                && indexItem.frame.contains(location)
                && currentIndex != i {
                scroll(to: i)
                delegate?.sectionIndexView(self, currentIndexDidChange: currentIndex)
                break
            }
        }
    }

    @objc func handleGesture(_ gesture: UIGestureRecognizer) {
        if gesture is UITapGestureRecognizer { // as cannot get its .began state
            isTouching = true
            delegate?.sectionIndexViewBeginIndexing(self)

            let location: CGPoint = gesture.location(in: indexItemsContainerView)
            selectIndexItem(at: location)

            isTouching = false
            delegate?.sectionIndexViewEndIndexing(self)
        } else {
            switch gesture.state {
            case .began:
                isTouching = true
                delegate?.sectionIndexViewBeginIndexing(self)
            case .ended,
                 .cancelled,
                 .failed:
                isTouching = false
                delegate?.sectionIndexViewEndIndexing(self)
            default:
                break
            }

            let location: CGPoint = gesture.location(in: indexItemsContainerView)
            selectIndexItem(at: location)
        }
    }

}

private class SectionIndexViewItem: UIView {
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                titleLabel.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.bold)
                titleLabel.textColor = UIColor.semanticColor(.tint(.primary))
            } else {
                titleLabel.font = UIFont.systemFont(ofSize: 10.0, weight: UIFont.Weight.regular)
                titleLabel.textColor = UIColor.semanticColor(.label(.secondary))
            }
        }
    }

    init() {
        super.init(frame: CGRect.zero)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.frame = bounds
    }

    private func setup() {
        isUserInteractionEnabled = false
        isSelected = false

        addSubview(titleLabel)
    }
}

private class SectionIndexViewIndicator: UIView {
    private var shape: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.fillColor = UIColor.semanticColor(.tint(.primary)).cgColor
        return shape
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
        setNeedsLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        shape.frame = bounds
        shape.path = trianglePath(with: bounds)
    }

    func indicate(_ targetRect: CGRect) {
        frame.origin.x = targetRect.maxX
        center.y = targetRect.midY
        isHidden = false
    }

    private func setup() {
        backgroundColor = UIColor.clear
        layer.addSublayer(shape)
    }

    private func trianglePath(with rect: CGRect) -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: rect.height / 2))
        path.addLine(to: CGPoint(x: rect.width, y: 0.0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.close()
        return path.cgPath
    }
}

private extension Array where Element == String {

    func isAllElementsSame(to antherArray: [String]) -> Bool {
        if count == antherArray.count {
            if !antherArray.isEmpty {
                for (i, value) in self.enumerated() {
                    if antherArray[i] != value {
                        return false
                    }
                }
                return true
            }
        }
        return false
    }

}
