//
//  GeoFenceRuleTypeAndScopeRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class GeoFenceRuleTypeAndScopeRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: GeoFenceRuleTypeAndScopeIxResponder?

    private var dataSource: GeoFenceRuleTypeAndScopeDataSource? = nil

    private lazy var nextButton: UIButton = { [weak self] in
        let nextButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Next", comment: "Next"), color: UIColor.semanticColor(.tint(.primary)))

        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)

        return nextButton
    }()

    private var saveButton: UIButton = {
        let saveButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Save", comment: "Save"), color: UIColor.semanticColor(.tint(.primary)))

        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        return saveButton
    }()

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Private

private extension GeoFenceRuleTypeAndScopeRootView {

    func setup() {
        tableView.separatorStyle = .none
    }

    @objc
    func nextButtonTapped() {
        ixResponder?.nextStep()
    }

    @objc
    func saveButtonTapped() {
        ixResponder?.saveGeoFenceRule()
    }

}

extension GeoFenceRuleTypeAndScopeRootView: GeoFenceRuleTypeAndScopeUserInterface {

    func render(newState: GeoFenceRuleTypeAndScopeViewControllerState) {
        removeAllBottomItemViews()

        let selectedElements = newState.viewState.selectedElements

        if selectedElements.contains(.scopeAll) {
            addBottomItemView(saveButton)
        }
        else if selectedElements.contains(.scopeSpecific) {
            addBottomItemView(nextButton)
        }

        if selectedElements.contains(.typeExit) || selectedElements.contains(.typeEnter) {
            saveButton.isEnabled = true
            nextButton.isEnabled = true
        }
        else {
            saveButton.isEnabled = false
            nextButton.isEnabled = false
        }

        dataSource = GeoFenceRuleTypeAndScopeDataSource(
            items: newState.viewState.elements,
            selectedItems: Array(selectedElements)
        )
        dataSource?.tableItemSelectionHandler = { [weak self] indexPath in
            guard let self = self else {
                return
            }

            self.ixResponder?.select(indexPath: indexPath)
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
                HNMessage.show(message: activityIndicatingState.message)
            }
        }
    }

}

class GeoFenceRuleTypeAndScopeDataSource: TableArrayDataSource<GeoFenceRuleTypeAndScopeViewState.Element> {

    var selectedItems: [GeoFenceRuleTypeAndScopeViewState.Element] = []

    public convenience init(items: [GeoFenceRuleTypeAndScopeViewState.Element], selectedItems: [GeoFenceRuleTypeAndScopeViewState.Element] = []) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({ indexPath in
                    let item = items[indexPath.row]
                    switch item {
                    case .typeTitle, .scopeTitle:
                        return 50.0
                    case .seperator:
                        return 20.0
                    case .typeExit, .typeEnter, .scopeSpecific:
                        return 40.0
                    case .scopeAll:
                        return 80.0
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
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.numberOfLines = 0

            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.detail

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
                    seperator.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
                    seperator.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: cell.separatorInset.left).isActive = true
                    seperator.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -cell.separatorInset.left).isActive = true
                }
            }
            else {
                cell.contentView.viewWithTag(seperatorTag)?.removeFromSuperview()
            }
        }

        self.selectedItems = selectedItems

        appendCellConfigurator{ [weak self] (cell, item, indexPath) in
            guard let self = self else {
                return
            }

            cell.imageView?.tintColor = UIColor.semanticColor(.tint(.primary))

            switch item {
            case .typeEnter, .typeExit:
                if self.selectedItems.contains(item) {
                    cell.imageView?.image = #imageLiteral(resourceName: "checkbox_selected")
                }
                else {
                    cell.imageView?.image = #imageLiteral(resourceName: "checkbox_empty")
                }
            case .scopeSpecific, .scopeAll:
                if self.selectedItems.contains(item) {
                    cell.imageView?.image = #imageLiteral(resourceName: "radio_selected")
                }
                else {
                    cell.imageView?.image = #imageLiteral(resourceName: "radio_empty")
                }
            default:
                break
            }
        }
    }

}
