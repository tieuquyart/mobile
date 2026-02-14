import UIKit
import LBTATools


public typealias DateRangeChangeHandler = ((DateRange) -> Void)


public class DateRangeHeaderView: UIView {
   
    let calendarView = CalendarView(frame: CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0))
    private var selectButton: UIButton!
    private var dateRangeChangeHandler: DateRangeChangeHandler

    public var dateRange: DateRange {
        didSet {
            updateUI()
        }
    }

    required public init(frame: CGRect, dateRange: DateRange, dateRangeChangeHandler: @escaping DateRangeChangeHandler) {
        self.dateRange = dateRange
        self.dateRangeChangeHandler = dateRangeChangeHandler
        super.init(frame: frame)

        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        selectButton.layer.cornerRadius = selectButton.frame.height / 2
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                 applyTheme()
            }
        }
    }
}

extension DateRangeHeaderView {

    public func applyTheme() {
        selectButton.backgroundColor = UIColor.white
    }

}

//MARK: - Private
private extension DateRangeHeaderView {
    
    func setup() {
        backgroundColor = UIColor.clear

        selectButton = UIButton(type: .custom)
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        selectButton.titleLabel?.font = UIFont(name: "BeVietnamPro-Regular", size: 12)
        selectButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        selectButton.clipsToBounds = true
        selectButton.layer.borderWidth = 1

        selectButton.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)

        addSubview(selectButton)

        applyTheme()

        selectButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        selectButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        updateUI()
    }

    func updateUI() {
    
        let data1 = dateRange.from.toString(format: DateFormatType.isoDate, timeZone: .custom(TimeZone(identifier: "Asia/Ho_Chi_Minh")!))
        let data2 = dateRange.to.toString(format: DateFormatType.isoDate, timeZone: .custom(TimeZone(identifier: "Asia/Ho_Chi_Minh")!))
        let rangeString =  "\(data1) to \(data2)"
    
        selectButton!.set(
            title: rangeString,
            titleFont: UIFont(name: "BeVietnamPro-Regular", size: 12.0)!,
            titleColor: UIColor.black,
            imageOnTitleLeft: nil,
            imageOnTitleRight: FleetResource.Image.dropDownArrow,
            margins: UIEdgeInsets(top: 4.0, left: 10.0, bottom: 4.0, right: 10.0),
            borderColor: UIColor.lightGray,
            cornerRadius: UIButton.CornerRadius.halfHeight
        )

        setNeedsLayout()
    }
    
    
    
    @objc func selectButtonTapped(_ sender: UIButton) {
      
        calendarView.delegate = self
        calendarView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let vc = UIViewController()

        vc.view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.8))
        vc.view.backgroundColor = UIColor.white
//        vc.view.usingDynamicBackgroundColor = true
        
        
//
            
       vc.view.addSubview(calendarView)
       // vc.view.addSubview(buttonOk)
       calendarView.frame = vc.view.bounds.insetBy(dx: 10.0, dy: 0.0)

        parentViewController?.popout(vc, preferredContentSize:  calendarView.bounds.size, tapBackgroundToDismiss: true, from: sender, didDismiss: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if let first = strongSelf.calendarView.selectedDates.first, let last = strongSelf.calendarView.selectedDates.last {
                let newRange = DateRange(from: first, to: last)

                if newRange != strongSelf.dateRange {
                    strongSelf.dateRange = newRange
                    strongSelf.dateRangeChangeHandler(strongSelf.dateRange)
                }
            }
            
        })
    }
}

extension DateRangeHeaderView : CalendarViewDelegate {
    func cancelButton() {
       print("ok delegate")
        self.parentViewController?.dismiss(animated: true)
        
    }
    
    func okButton() {
        print("cancel delegate")
        if let first = calendarView.selectedDates.first, let last = calendarView.selectedDates.last {
            let newRange = DateRange(from: first, to: last)

            if newRange != self.dateRange {
                self.dateRange = newRange
                self.dateRangeChangeHandler(self.dateRange)
                
            }
          
        }
        self.parentViewController?.dismiss(animated: true)
    }
    
}
