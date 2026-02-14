//
//  TypeFilterView.swift
//  Fleet
//
//  Created by forkon on 2019/12/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import YNDropDownMenu

class TypeFilterView: YNDropDownView {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var seperatorView: UIView!
    
    private var typeFilters: [TypeFilter] = TypeFilter.allCases

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.allowsMultipleSelection = true
        collectionView.register(TypeFilterCell.self, forCellWithReuseIdentifier: "Cell")

        applyTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

}

extension TypeFilterView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeFilters.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150.0, height: 30.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 18.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15.0, left: 28.0, bottom: 15.0, right: 28.0)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TypeFilterCell
        cell.textLabel.text = typeFilters[indexPath.item].description
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateUI()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateUI()
    }
    
}

private extension TypeFilterView {

    func updateUI() {
        let selectedItemsCount = collectionView.indexPathsForSelectedItems?.count ?? 0
        doneButton.setTitle(NSLocalizedString("Done", comment: "Done") + ((selectedItemsCount != 0) ? "(\(selectedItemsCount))" : ""), for: .normal)
        changeMenu(title: NSLocalizedString("Type", comment: "Type") + ((selectedItemsCount != 0) ? "(\(selectedItemsCount))" : ""), at: 0)
    }

    @IBAction func confirmButtonTapped(_ sender: Any) {
        hideMenu()
    }

    @IBAction func clearButtonTapped(_ sender: Any) {
        collectionView.allowsSelection = false
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        updateUI()
        hideMenu()
    }
}

extension TypeFilterView: Themed {

    func applyTheme() {
        seperatorView.backgroundColor = UIColor.semanticColor(.separator(.opaque))
    }

}

extension TypeFilterView: DataFilterGenerator {

    func dataFilter() -> DataFilter {
        let selectedFilters = collectionView.indexPathsForSelectedItems?.compactMap{typeFilters[$0.item]}
        return EventTypeFilter(typeFilters: selectedFilters ?? [])
    }

}

extension TypeFilterView: NibCreatable {}

enum TypeFilter: CustomStringConvertible, CaseIterable {
    case drivingParking
    case behaviorTypeEvents
    case hitTypeEvents
    case geoFencing

    var description: String {
        switch self {
        case .drivingParking:
            return NSLocalizedString("Driving/Parking", comment: "Driving/Parking")
        case .behaviorTypeEvents:
            return NSLocalizedString("Behavior Type Events", comment: "Behavior Type Events")
        case .hitTypeEvents:
            return NSLocalizedString("Hit Type Events", comment: "Hit Type Events")
        case .geoFencing:
            return NSLocalizedString("Geo-fencing", comment: "Geo-fencing")
        }
    }

}

private class TypeFilterCell: UICollectionViewCell {
    var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textAlignment = .center
        return label
    }()

    override var isSelected: Bool {
        didSet {
            updateUI()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

    private func setup() {
        layer.cornerRadius = 4.0
        layer.borderWidth = 1.0

        textLabel.frame = bounds
        addSubview(textLabel)

        updateUI()
    }

    private func updateUI() {
        applyTheme()
    }
}

extension TypeFilterCell: Themed {

    func applyTheme() {
        if isSelected {
            backgroundColor = UIColor.semanticColor(.background(.primary))
            layer.borderColor = UIColor.semanticColor(.tint(.primary)).cgColor
            textLabel.textColor = UIColor.semanticColor(.tint(.primary))
        } else {
            backgroundColor = UIColor.semanticColor(.background(.octonary))
            layer.borderColor = UIColor.clear.cgColor
            textLabel.textColor = UIColor.semanticColor(.tint(.secondary))
        }
    }

}
