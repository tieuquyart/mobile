//
//  AddNewCameraRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import Former
import WaylensCameraSDK

class AddNewCameraRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: AddNewCameraIxResponder?

    var sn: String? {
        // not use snFieldRow.text
        return snFieldRow.cell.formTextField().text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    var password: String? {
        // not use passwordFieldRow.text
        return passwordFieldRow.cell.formTextField().text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    private lazy var former = Former(tableView: tableView)

    private lazy var snFieldRow = TextFieldRowFormer<FormTextFieldCell>() { [weak self] in
        $0.titleLabel.text = NSLocalizedString("Serial Number (S/N)", comment: "Serial Number (S/N)")
        $0.titleLabel.font = .systemFont(ofSize: 14)
        $0.textField.font = .systemFont(ofSize: 14)
        $0.textField.keyboardType = .asciiCapable
        $0.textField.returnKeyType = .next
        $0.textField.textAlignment = .right
        $0.textField.restrictor = TextFieldRestrictorFactory.makeUppercaseAlphanumericRestrictor()
        }.configure {
            $0.rowHeight = 70
            $0.placeholder = NSLocalizedString("8-Character S/N", comment: "8-Character S/N")
    }

    private lazy var passwordFieldRow = TextFieldRowFormer<FormTextFieldCell>() { [weak self] in
        $0.titleLabel.text = NSLocalizedString("Password", comment: "Password")
        $0.titleLabel.font = .systemFont(ofSize: 14)
        $0.textField.font = .systemFont(ofSize: 14)
        $0.textField.keyboardType = .numberPad
        $0.textField.returnKeyType = .done
        $0.textField.textAlignment = .right
        $0.textField.restrictor = TextFieldRestrictorFactory.makeDecimalDigitRestrictor()
        }.configure {
            $0.rowHeight = 70
            $0.placeholder = NSLocalizedString("8-Digit Password", comment: "8-Digit Password")
    }

    private lazy var usingCurrentConnectedCameraRow: BaseRowFormer = {
        $0.cellSetup { (cell) in
            TableViewCellFactory.configSubtitleStyleCell(cell)
            cell.accessoryType = .none

            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = NSLocalizedString("Using Current Connected Camera", comment: "Using Current Connected Camera")
        }
        $0.rowHeight = 60
        return $0
    }(BaseRowFormer())

    private lazy var connectedCameraSection = SectionFormer(rowFormer: usingCurrentConnectedCameraRow)

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func applyTheme() {
        super.applyTheme()

        usingCurrentConnectedCameraRow.cellUpdate { (cell) in
            TableViewCellFactory.configSubtitleStyleCell(cell)
            cell.accessoryType = .none
        }
    }

}

//MARK: - Private

private extension AddNewCameraRootView {

    func setup() {
        tableView.isScrollEnabled = false

        let header = LabelViewFormer<FormLabelHeaderView>().configure { (viewFormer) in
            viewFormer.viewHeight = 0.001
        }

        let section = SectionFormer(rowFormers: [snFieldRow, passwordFieldRow])
            .set(headerViewFormer: header)
        former.append(sectionFormer: section)
    }

}

extension AddNewCameraRootView: AddNewCameraUserInterface {

    func render(newState: AddNewCameraViewControllerState) {
        if let connectedCamera = newState.connectedCamera {
            if former.sectionFormers.first(where: {$0 === connectedCameraSection}) == nil {
                former.append(sectionFormer: connectedCameraSection)
            }

            former.onCellSelected { [weak self] (indexPath) in
                guard let self = self else {
                    return
                }

                self.former.deselect(animated: true)

                if indexPath.section == self.former.sectionFormers.firstIndex(where: {$0 === self.connectedCameraSection}) {
                    self.snFieldRow.text = connectedCamera.sn
                    self.passwordFieldRow.text = connectedCamera.password
                    self.former.reload()
                }
            }
        }
        else {
            former.remove(sectionFormer: connectedCameraSection)
            former.onCellSelected { (_) in

            }
        }

        former.reload()

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
