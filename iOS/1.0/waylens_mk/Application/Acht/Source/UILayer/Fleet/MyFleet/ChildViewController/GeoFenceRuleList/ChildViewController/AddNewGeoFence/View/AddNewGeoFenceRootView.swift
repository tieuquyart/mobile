//
//  AddNewGeoFenceRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class AddNewGeoFenceRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: AddNewGeoFenceIxResponder?
    private var dataSource: AddNewGeoFenceDataSource? = nil

    private lazy var nextButton: UIButton = { [weak self] in
        let nextButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Next", comment: "Next"), color: UIColor.semanticColor(.tint(.primary)))
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return nextButton
    }()

    private var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14.0)
        textView.backgroundColor = UIColor.clear
        textView.textContainerInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        textView.isEditable = false
        return textView
    }()

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func applyTheme() {
        super.applyTheme()

        textView.textColor = UIColor.semanticColor(.label(.primary))
    }
}

//MARK: - Private

private extension AddNewGeoFenceRootView {

    func setup() {
        tableView.separatorStyle = .none

        textView.frame.size.height = 200.0
        tableView.tableFooterView = textView

        addBottomItemView(nextButton)

        applyTheme()
    }

    @objc func nextButtonTapped() {
        ixResponder?.nextStep()
    }

}

extension AddNewGeoFenceRootView: AddNewGeoFenceUserInterface {

    func render(newState: AddNewGeoFenceViewControllerState) {
        let selectedItem = newState.viewState.selectedElement

        let canSelect = newState.fence == nil

        if canSelect {
            textView.text = selectedItem?.detail
        }
        else {
            textView.text = nil
        }

        if let name = newState.rule.name, !name.isEmpty, newState.viewState.selectedElement != nil {
            nextButton.isEnabled = true
        }
        else {
            nextButton.isEnabled = false
        }

        dataSource = AddNewGeoFenceDataSource(items: newState.viewState.elements, selectedItems: selectedItem != nil ? [selectedItem!] : [], name: newState.rule.name, canSelect: canSelect)
        dataSource?.tableItemSelectionHandler = { [weak self] indexPath in
            guard let self = self else {
                return
            }

            self.ixResponder?.select(indexPath: indexPath)
        }

        dataSource?.endEditingNameHandler = { [weak self] name in
            guard let self = self else {
                return
            }

            let nameReducer: GeoFenceRuleReducer = { rule in
                rule.name = name
            }

            self.ixResponder?.changeRule(using: nameReducer)
        }

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
                HNMessage.show()
            }
        }
    }

    func beginEditingName() {
        (tableView.dataSource as? AddNewGeoFenceDataSource)?.nameField.becomeFirstResponder()
    }

}

class AddNewGeoFenceDataSource: TableArrayDataSource<AddNewGeoFenceViewState.Element> {

    var selectedItems: [AddNewGeoFenceViewState.Element] = []

    var endEditingNameHandler: ((String?) -> ())? = nil

    private(set) lazy var nameField: UITextField = { [weak self] in
        let field = UITextField()
        field.textAlignment = .right
        field.placeholder = NSLocalizedString("1-20 characters", comment: "1-20 characters")
        field.returnKeyType = .done
        field.delegate = self
        field.restrictor = TextFieldRestrictorFactory.makeNumberOfCharactersLimitRestrictor(limit: 20)

        return field
    }()

    private var canSelect: Bool = true

    public convenience init(items: [AddNewGeoFenceViewState.Element], selectedItems: [AddNewGeoFenceViewState.Element] = [], name: String? = nil, canSelect: Bool) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({ indexPath in
                    let item = items[indexPath.row]
                    switch item {
                    case .name:
                        return 60.0
                    case .type:
                        return 40.0
                    case .typeCircular, .typePolygonal, .typeReused:
                        return 44.0
                    case .seperator:
                        return 10.0
                    }
                }),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .subtitle)
        }
        ) { (cell, item, indexPath) in
            TableViewCellFactory.configSubtitleStyleCell(cell)

            cell.selectionStyle = .none
            cell.accessoryType = .none
            cell.imageView?.image = nil
            cell.imageView?.tintColor = UIColor.semanticColor(.tint(.primary))

            switch item {
            case .name:
                cell.textLabel?.text = item.title
            case .seperator:
                cell.textLabel?.text = item.title
            case .type:
                cell.textLabel?.text = item.title
            case .typeCircular:
                cell.textLabel?.attributedText = NSAttributedString.attributedString(
                    title: item.title ?? "",
                    titleFont: UIFont.systemFont(ofSize: 14.0),
                    titleColor: UIColor.semanticColor(.label(.secondary)),
                    imageOnTitleLeft: nil,
                    imageOnTitleRight: #imageLiteral(resourceName: "Circular")
                )
            case .typePolygonal:
                cell.textLabel?.attributedText = NSAttributedString.attributedString(
                    title: item.title ?? "",
                    titleFont: UIFont.systemFont(ofSize: 14.0),
                    titleColor: UIColor.semanticColor(.label(.secondary)),
                    imageOnTitleLeft: nil,
                    imageOnTitleRight: #imageLiteral(resourceName: "Polygonal")
                )
            case .typeReused:
                cell.textLabel?.attributedText = NSAttributedString.attributedString(
                    title: item.title ?? "",
                    titleFont: UIFont.systemFont(ofSize: 14.0),
                    titleColor: UIColor.semanticColor(.label(.secondary)),
                    imageOnTitleLeft: nil,
                    imageOnTitleRight: #imageLiteral(resourceName: "Reused")
                )
            }

            let seperatorTag = 888
            if item == .seperator {
                if let seperator = cell.contentView.viewWithTag(seperatorTag) {
                    seperator.backgroundColor = UIColor.semanticColor(.separator(.opaque))
                }
                else {
                    let seperator = UIView()
                    seperator.translatesAutoresizingMaskIntoConstraints = false
                    seperator.tag = seperatorTag
                    seperator.backgroundColor = UIColor.semanticColor(.separator(.opaque))
                    cell.contentView.addSubview(seperator)

                    seperator.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
                    seperator.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
                    seperator.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: cell.separatorInset.left).isActive = true
                    seperator.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -cell.separatorInset.left).isActive = true
                }
            }
            else {
                cell.contentView.viewWithTag(seperatorTag)?.removeFromSuperview()
            }
        }

        self.selectedItems = selectedItems
        self.nameField.text = name
        self.canSelect = canSelect

        appendCellConfigurator{ [weak self] (cell, item, indexPath) in
            guard let self = self else {
                return
            }

            switch item {
            case .name:
                let fieldFrame = cell.bounds.divided(atDistance: cell.bounds.width * 0.7, from: CGRectEdge.maxXEdge).slice
                self.nameField.frame = fieldFrame

                cell.accessoryView = self.nameField
                cell.contentView.alpha = 1.0
                cell.isUserInteractionEnabled = true

                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            case .typeCircular, .typePolygonal, .typeReused:
                if self.selectedItems.contains(item) {
                    cell.imageView?.image = #imageLiteral(resourceName: "radio_selected")
                }
                else {
                    cell.imageView?.image = #imageLiteral(resourceName: "radio_empty")
                }

                if canSelect {
                    cell.contentView.alpha = 1.0
                    cell.isUserInteractionEnabled = true
                }
                else {
                    cell.contentView.alpha = 0.5
                    cell.isUserInteractionEnabled = false
                }
            default:
                break
            }
        }
    }

}

extension AddNewGeoFenceDataSource: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        endEditingNameHandler?(textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
    }

}
