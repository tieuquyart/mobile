//
//  SetupVehicleRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class SetupVehicleRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: SetupVehicleIxResponder?
    private var dataSource: SetupVehicleDataSource? = nil

    private lazy var nextButton: UIButton = { [unowned self] in
        let nextButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Next", comment: "Next"), color: UIColor.semanticColor(.tint(.primary)))
        nextButton.addTarget(self, action: #selector(nextButtonTapped(_:)), for: .touchUpInside)
        nextButton.setBackgroundImage(with: UIColor.semanticColor(.background(.quaternary)), for: .disabled)

        return nextButton
    }()

    private lazy var addNewCameraFooter: UITableViewCell = { [unowned self] in
        let addNewCameraFooter = UITableViewCell(style: .default, reuseIdentifier: nil)
        TableViewCellFactory.configSubtitleStyleCell(addNewCameraFooter)
        addNewCameraFooter.translatesAutoresizingMaskIntoConstraints = false
        addNewCameraFooter.accessoryType = .none
        addNewCameraFooter.imageView?.image = #imageLiteral(resourceName: "icon_settings_add")
        addNewCameraFooter.imageView?.tintColor = UIColor.semanticColor(.tint(.primary))
        addNewCameraFooter.textLabel?.text = NSLocalizedString("Add New Camera", comment: "Add New Camera")
        addNewCameraFooter.isHidden = true

        let shadowImageHeight: CGFloat = 10.0
        let shadowImage = UIImage(named: "line_shadow")
        let shadowView = UIImageView(image: shadowImage)
        shadowView.alpha = 0.3
        shadowView.autoresizingMask = [.flexibleWidth]
        shadowView.frame = CGRect(
            x: 0.0,
            y: -shadowImageHeight,
            width: addNewCameraFooter.frame.width,
            height: shadowImageHeight
        )
        addNewCameraFooter.addSubview(shadowView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addNewCameraFooterTapped(_:)))
        addNewCameraFooter.addGestureRecognizer(tapGesture)

        return addNewCameraFooter
    }()
    private var contentOffsetObservation: NSKeyValueObservation? = nil

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let addNewCameraFooterHeight: CGFloat = 60.0
        addNewCameraFooter.frame = CGRect(
            x: 0.0,
            y: tableView.frame.height - tableView.contentInset.bottom - addNewCameraFooterHeight,
            width: frame.width,
            height: addNewCameraFooterHeight
        )
    }

    override func applyTheme() {
        super.applyTheme()

        addNewCameraFooter.backgroundColor = UIColor.semanticColor(.tableViewCellBackground(.grouped))

        if #available(iOS 13.0, *) {
            addNewCameraFooter.textLabel?.textColor = UIColor.label
        }
    }
}

//MARK: - Private

private extension SetupVehicleRootView {

    func setup() {
        addBottomItemView(nextButton)
        addSubview(addNewCameraFooter)

        applyTheme()
    }

    @objc func nextButtonTapped(_ sender: Any) {
        ixResponder?.updateVehicle()
    }

    @objc func addNewCameraFooterTapped(_ sender: Any) {
        ixResponder?.gotoAddNewCamera()
    }

}

extension SetupVehicleRootView: SetupVehicleUserInterface {

    func render(newState: SetupVehicleViewControllerState) {
        var items: [StandardTableViewCellViewModel] = [
            StandardTableViewCellViewModel(image: nil, text: NSLocalizedString("Plate Number", comment: "Plate Number"), detail: newState.vehicleProfile.plateNo),
            StandardTableViewCellViewModel(image: nil, text: NSLocalizedString("Vehicle Model", comment: "Vehicle Model"), detail: newState.vehicleProfile.type),
            StandardTableViewCellViewModel(image: nil, text: NSLocalizedString("Driver", comment: "Driver"), detail: newState.selectedDriver?.name),
            StandardTableViewCellViewModel(image: nil, text: NSLocalizedString("Bind Camera", comment: "Bind Camera"), detail: NSLocalizedString("Please choose a camera Serial Number (S/N)", comment: "Please choose a camera Serial Number (S/N)"))
        ]

        newState.cameras.forEach { (camera) in
            var image = #imageLiteral(resourceName: "radio_empty")

            if camera == newState.selectedCamera {
                image = #imageLiteral(resourceName: "radio_selected")
            }

            items.append(StandardTableViewCellViewModel(image: image, text: camera.cameraSn, detail: nil))
        }

        items.append(StandardTableViewCellViewModel(image: #imageLiteral(resourceName: "icon_settings_add"), text: NSLocalizedString("Add New Camera", comment: "Add New Camera"), detail: nil))

        dataSource = SetupVehicleDataSource(items: items)
        dataSource?.tableItemSelectionHandler = { [weak self] indexPath in
            switch indexPath.row {
            case SetupVehicleDataSource.Rows.plateNumber.rawValue:
                self?.ixResponder?.gotoPlateNumberComposing()
            case SetupVehicleDataSource.Rows.vehicleModel.rawValue:
                self?.ixResponder?.gotoVehicleModelComposing()
            case SetupVehicleDataSource.Rows.driver.rawValue:
                self?.ixResponder?.gotoDriverSelector()
            case SetupVehicleDataSource.Rows.bindCamera.rawValue:
                break
            case items.count - 1:
                self?.ixResponder?.gotoAddNewCamera()
            default: // camera item
                if !newState.cameras.isEmpty {
                    let cameraIndexPath = IndexPath(row: indexPath.row - 4, section: 0)
                    self?.ixResponder?.selectCamera(at: cameraIndexPath)
                }
            }
        }

        contentOffsetObservation = tableView.observe(\.contentOffset) { [weak self] (tableView, change) in
            if tableView.contentSize.height - (tableView.frame.height - tableView.contentInset.bottom) - tableView.contentOffset.y > 2.1 {
                self?.addNewCameraFooter.isHidden = false
            } else {
                self?.addNewCameraFooter.isHidden = true
            }
        }
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.reloadData()

        if newState.vehicleProfile.vehicleID != nil && newState.selectedCamera != nil {
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
        }
    }

}

