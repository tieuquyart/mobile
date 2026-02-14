//
//  AdasConfigRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class AdasConfigRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: AdasConfigIxResponder?

    private var dataSource: AdasConfigDataSource? = nil

    fileprivate enum RowType {
        case title(String)
        case input(key: PartialKeyPath<WLAdasConfig>, name: String, value: String, unit: String)
        case separator
        case comment(String)
    }
    
    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Private

private extension AdasConfigRootView {

    func setup() {
        /*
        let saveButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Save", comment: "Save"), color: UIColor.semanticColor(.tint(.primary)))
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        addBottomItemView(saveButton)
         */
        
        tableView.separatorStyle = .none
    }

    @objc
    func saveButtonTapped() {
        
    }
}

extension AdasConfigRootView: AdasConfigUserInterface {

    func render(newState: AdasConfigViewControllerState) {
        var items = [
            RowType.title(NSLocalizedString("Please input the height of the camera to the ground", comment: "Please input the height of the camera to the ground")),
            RowType.input(
                key: \WLAdasConfig.cameraHeight,
                name: "",
                value: "\(newState.adasConfig?.cameraHeight ?? 0)",
                unit: NSLocalizedString("Meters", comment: "Meters")
            ),
            RowType.separator,
            RowType.title(NSLocalizedString("Please input the width of the vehicle from wheel to wheel", comment: "Please input the width of the vehicle from wheel to wheel")),
            RowType.input(
                key: \WLAdasConfig.vehicleWidth, name: "",
                value: "\(newState.adasConfig?.vehicleWidth ?? 0)",
                unit: NSLocalizedString("Meters", comment: "Meters")
            ),
            RowType.separator,
        ]
        
        if let rightOffsetToCenter = newState.adasConfig?.rightOffsetToCenter?.doubleValue {
            items.append(contentsOf: [
                RowType.title(NSLocalizedString("Please input the windshield offset from center\n(Negative number for left, positive number for right)", comment: "Please input the windshield offset from center\n(Negative number for left, positive number for right)")),
                RowType.input(
                    key: \WLAdasConfig.rightOffsetToCenter, name: "",
                    value: "\(rightOffsetToCenter)",
                    unit: NSLocalizedString("Meters", comment: "Meters")
                ),
                RowType.separator,
            ])
        }
        
        let itemsInDebugMode = [
            RowType.separator,
            RowType.input(
                key: \WLAdasConfig.forwardCollisionTTC,
                name: "Forward Collision TTC",
                value: "\(newState.adasConfig?.forwardCollisionTTC ?? 0)",
                unit: "s"
            ),
            RowType.separator,
            RowType.input(
                key: \WLAdasConfig.forwardCollisionTR,
                name: "Forward Collision TR",
                value: "\(newState.adasConfig?.forwardCollisionTR ?? 0)",
                unit: "%"
            ),
            RowType.separator,
            RowType.input(
                key: \WLAdasConfig.headwayMonitorTTC,
                name: "Headway Monitoring TTC",
                value: "\(newState.adasConfig?.headwayMonitorTTC ?? 0)",
                unit: "s"
            ),
            RowType.separator,
            RowType.input(key: \WLAdasConfig.headwayMonitorTR, name: "Headway Monitoring TR", value: "\(newState.adasConfig?.headwayMonitorTR ?? 0)", unit: "%"),
            RowType.separator,
            RowType.comment("TTC：Time to Collision"),
            RowType.comment("TR：Time Ratio"),
        ]
        
        if UserSetting.shared.debugEnabled {
            items.append(contentsOf: itemsInDebugMode)
        }
        
        dataSource = AdasConfigDataSource(items: items, textFieldDidReturnClosure: { [weak self] key, value in
            guard let value = value else {
                return
            }
            
            self?.ixResponder?.configAdas(value: value, for: key)
        })

        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.reloadData()
        
        let activityIndicatingState = newState.viewState.activityIndicatingState
        if activityIndicatingState == .none {
            HNMessage.dismiss()
        } else {
            if activityIndicatingState.isSuccess {
                HNMessage.showSuccess(message: activityIndicatingState.message)
                HNMessage.dismiss(withDelay: 1.0)
            } else {
                HNMessage.show(message: activityIndicatingState.message)
            }
        }
    }

}

private class AdasConfigDataSource: TableArrayDataSource<AdasConfigRootView.RowType>, UITextFieldDelegate {
    typealias TextFieldDidReturnClosure = (PartialKeyPath<WLAdasConfig>, String?) -> ()
    private var textFieldDidReturnClosure: TextFieldDidReturnClosure? = nil
    
    public convenience init(items: [AdasConfigRootView.RowType], textFieldDidReturnClosure: @escaping TextFieldDidReturnClosure) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({ indexPath in
                    switch items[indexPath.row] {
                    case .separator:
                        return 20
                    case .comment:
                        return 25
                    default:
                        return UITableView.automaticDimension
                    }
                }),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .subtitle)
        }
        ) { (cell, item, indexPath) in
            TableViewCellFactory.configSubtitleStyleCell(cell)

            cell.backgroundColor = UIColor.clear
            cell.textLabel?.numberOfLines = 0
            cell.accessoryType = .none
            cell.selectionStyle = .none
                       
            AdasConfigDataSource.textField(in: cell)?.removeFromSuperview()

            switch item {
            case .title(let title), .comment(let title):
                cell.textLabel?.text = title
            case .separator:
                cell.textLabel?.text = nil
            case .input(_/*let key*/, let name, let value, let unit):
                cell.textLabel?.text = "\n\n"
                
                let textField = UITextField(frame: cell.contentView.bounds)
                textField.keyboardType = .numbersAndPunctuation
                textField.returnKeyType = .done
                textField.borderStyle = .roundedRect
                textField.backgroundColor = UIColor.semanticColor(.textInputAreaBackground)
                textField.tag = indexPath.row
                textField.shouldResignOnTouchOutsideMode = .enabled

                let unitLabel = UILabel()
                unitLabel.font = textField.font
                textField.rightView = unitLabel
                textField.rightViewMode = .always
                
                let nameLabel = UILabel()
                nameLabel.font = textField.font
                textField.leftView = nameLabel
                textField.leftViewMode = .always
                
                cell.contentView.addSubview(textField)
                
                let leftLabel = (textField.leftView as! UILabel)
                let rightLabel = (textField.rightView as! UILabel)

                if name != "" {
                    leftLabel.text = " \(name) "
                    textField.textAlignment = .right
                }
                else {
                    leftLabel.text = name
                    textField.textAlignment = .left
                }
                
                rightLabel.text = " \(unit) "
                textField.text = value
                
                leftLabel.sizeToFit()
                rightLabel.sizeToFit()
                
                textField.translatesAutoresizingMaskIntoConstraints = false
                textField.leadingAnchor.constraint(equalTo: cell.textLabel!.leadingAnchor).isActive = true
                textField.trailingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor).isActive = true
                textField.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
                textField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
                                
                textField.setNeedsLayout()
            }
        }
        
        self.textFieldDidReturnClosure = textFieldDidReturnClosure

        appendCellConfigurator{ [weak self] (cell, item, indexPath) in
            guard let self = self else {
                return
            }

            AdasConfigDataSource.textField(in: cell)?.delegate = self
        }
    }
    
    class func textField(in cell: UITableViewCell) -> UITextField? {
        var textFieldFound: UITextField? = nil
        
        cell.contentView.subviews.forEach { sv in
            if let textField = sv as? UITextField {
                textFieldFound = textField
                return
            }
        }
        
        return textFieldFound
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let item = item(at: IndexPath(row: textField.tag, section: 0)),
           case let AdasConfigRootView.RowType.input(key, _/*name*/, _/*value*/, _/*unit*/) = item
        {
            textFieldDidReturnClosure?(key, textField.text)
        }
    }
}
