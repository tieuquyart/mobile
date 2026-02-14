//
//  AddNewPlateNumberRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import Former

class AddNewPlateNumberRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: AddNewPlateNumberIxResponder?

    var plateNumber: String? {
        return plateNumberFieldRow.text
    }

    private lazy var former = Former(tableView: tableView)

    private lazy var plateNumberFieldRow = TextFieldRowFormer<FormTextFieldCell>() {
        $0.titleLabel.text = NSLocalizedString("Plate Number", comment: "Plate Number")
        $0.titleLabel.font = .systemFont(ofSize: 14)
        $0.textField.font = .systemFont(ofSize: 14)
        $0.textField.keyboardType = .asciiCapable
        $0.textField.returnKeyType = .next
        $0.textField.textAlignment = .right
        }.configure {
            $0.rowHeight = 70
            $0.placeholder = NSLocalizedString("e.g. NY 999NNN", comment: "e.g. NY 999NNN")
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

private extension AddNewPlateNumberRootView {

    func setup() {
        tableView.isScrollEnabled = false

        let header = LabelViewFormer<FormLabelHeaderView>().configure { (viewFormer) in
            viewFormer.viewHeight = 0.001
        }

        let section = SectionFormer(rowFormers: [plateNumberFieldRow])
            .set(headerViewFormer: header)
        former.append(sectionFormer: section)
    }

}

extension AddNewPlateNumberRootView: AddNewPlateNumberUserInterface {

    func render(newState: AddNewPlateNumberViewControllerState) {
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

