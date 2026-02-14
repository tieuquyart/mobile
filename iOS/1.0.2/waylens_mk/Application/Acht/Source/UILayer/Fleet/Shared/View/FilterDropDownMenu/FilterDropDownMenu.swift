//
//  FilterDropDownMenu.swift
//  Fleet
//
//  Created by forkon on 2019/12/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import YNDropDownMenu
import RxSwift

enum FilterDropDownMenuItem {
    case type
    case time
    case driver

    var title: String {
        switch self {
        case .type:
            return NSLocalizedString("Type", comment: "Type")
        case .time:
            return NSLocalizedString("Time", comment: "Time")
        case .driver:
            return NSLocalizedString("Driver", comment: "Driver")
        }
    }

    var view: YNDropDownView {
        switch self {
        case .type:
            return TypeFilterView.createFromNib()!
        case .time:
            return TimeFilterView.createFromNib()!
        case .driver:
            return DriverFilterView.createFromNib()!
        }
    }

    var normalImage: UIImage {
        return #imageLiteral(resourceName: "down_blue")
    }

    var selectedImage: UIImage {
        return #imageLiteral(resourceName: "up_blue")
    }

    var disabledImage: UIImage? {
        return nil
    }

}

protocol FilterDropDownMenuDelegate: NSObjectProtocol {
    func filterDropDownMenuWillHide(_ filterDropDownMenu: FilterDropDownMenu)
}

class FilterDropDownMenu: YNDropDownMenu {

    private var dropDownViews: [UIView]

    weak var delegate: FilterDropDownMenuDelegate? = nil

    var menuBarBackgroundColor: UIColor = UIColor.semanticColor(.background(.primary)) {
        didSet {
            setBackgroundColor(color: menuBarBackgroundColor)
        }
    }

    override init(frame: CGRect, dropDownViews: [UIView], dropDownViewTitles: [String]) {
        self.dropDownViews = dropDownViews

        super.init(frame: frame, dropDownViews: dropDownViews, dropDownViewTitles: dropDownViewTitles)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hideMenu() {
        delegate?.filterDropDownMenuWillHide(self)
        super.hideMenu()
    }

    func updateDropDownView<T>(_ viewType: T.Type, updateBlock: (T) -> ()) {
        if let dropDownView = dropDownViews.first(where: {$0 is T}) as? T {
            updateBlock(dropDownView)
        }
    }

}

extension FilterDropDownMenu: DataFilter, DataFilterGenerator {

    private var dataFilters: [DataFilter] {
        if let dataFilterGenerator = dropDownViews.filter({$0 is DataFilterGenerator}) as? [DataFilterGenerator] {
            return dataFilterGenerator.map{$0.dataFilter()}
        }
        return []
    }

    func dataFilter() -> DataFilter {
        return self
    }

    func match(_ dataModel: Any) -> Bool {
        var match = true
        dataFilters.forEach { (filter) in
            if !filter.match(dataModel) {
                match = false
                return
            }
        }
        return match
    }

}

extension UIView {

    private struct AssociatedKeys {
        static var disposeBag: UInt8 = 1
    }

    private var disposeBag: DisposeBag {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            var disposeBag = objc_getAssociatedObject(self, &AssociatedKeys.disposeBag) as? DisposeBag
            if disposeBag == nil {
                disposeBag = DisposeBag()
                objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }

            return disposeBag!
        }
    }

    var filterDropDownMenu: FilterDropDownMenu? {
        return subviews.first(where: {$0 is FilterDropDownMenu}) as? FilterDropDownMenu
    }

    @discardableResult func setupFilterDropDownMenu(with items: [FilterDropDownMenuItem], additionalConfig: ((FilterDropDownMenu) -> ())?) -> FilterDropDownMenu {
        let dropDownViews = items.map{$0.view}

        let menu = FilterDropDownMenu(
            frame: CGRect(x: 0, y: 0, width: frame.width, height: 44),
            dropDownViews: dropDownViews,
            dropDownViewTitles: items.map{$0.title}
        )
        menu.autoresizingMask = [.flexibleWidth]

        let normalImages = items.map{$0.normalImage}
        let selectedImages = items.map{$0.selectedImage}
        let disabledImages: [UIImage?] = items.map{$0.disabledImage}

        menu.setStatesImages(
            normalImages: normalImages,
            selectedImages: selectedImages,
            disabledImages: disabledImages
        )

        menu.setLabelColorWhen(normal: UIColor.semanticColor(.tint(.primary)), selected: UIColor.semanticColor(.tint(.primary)), disabled: .gray)

        menu.setLabelFontWhen(normal: .systemFont(ofSize: 14), selected: .boldSystemFont(ofSize: 14), disabled: .systemFont(ofSize: 14))

        menu.backgroundBlurEnabled = true
        menu.bottomLine.isHidden = true

        // Add custom blurEffectView
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        menu.blurEffectView = backgroundView
        menu.blurEffectViewAlpha = 0.7

        func applyTheme() {
            additionalConfig?(menu)

            dropDownViews.forEach { (dropDownView) in
                dropDownView.backgroundColor = menu.menuBarBackgroundColor
            }
        }

        applyTheme()

        menu.rx.methodInvoked(#selector(UIView.traitCollectionDidChange(_:))).subscribe { (event) in
            applyTheme()
        }.disposed(by: disposeBag)

       self.addSubview(menu)
       

        if let firstSubview = subviews.first {
            if let topConstraint = firstSubview.topConstraint {
                topConstraint.constant = -menu.frame.height
            } else {
                firstSubview.frame = firstSubview.frame.divided(atDistance: menu.frame.height, from: CGRectEdge.minYEdge).remainder
            }
        }

        /*
        if #available(iOS 11.0, *) {
            rx.methodInvoked(#selector(UIView.layoutSubviews)).subscribe { [weak self] (event) in
                guard let self = self else {
                    return
                }

                if let firstSubview = self.subviews.first {
                    if let topConstraint = firstSubview.topConstraint {
                        topConstraint.constant = -(menu.frame.height + firstSubview.safeAreaInsets.top)
                    } else {
                        firstSubview.frame = self.bounds.divided(atDistance: menu.frame.height + self.safeAreaInsets.top, from: CGRectEdge.minYEdge).remainder
                        menu.frame = CGRect(x: 0.0, y: self.safeAreaInsets.top, width: self.frame.width, height: menu.frame.height)
                    }
                }
            }.disposed(by: disposeBag)

        }
 */

        return menu
    }

}
