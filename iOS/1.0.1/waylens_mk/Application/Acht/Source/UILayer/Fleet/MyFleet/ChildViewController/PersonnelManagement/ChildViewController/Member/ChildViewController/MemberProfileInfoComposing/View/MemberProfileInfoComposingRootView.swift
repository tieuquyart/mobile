//
//  MemberProfileInfoComposingRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import Former

class MemberProfileInfoComposingRootView: ViewContainTableViewAndBottomButton {
    
    weak var ixResponder: MemberProfileInfoComposingIxResponder?
    
    private lazy var former = Former(tableView: tableView)
    
    private lazy var textFieldRow = TextFieldRowFormer<FormTextFieldCell>() {
        $0.textField.font = .systemFont(ofSize: 14)
        $0.textField.returnKeyType = .done
    }.configure {
        $0.rowHeight = 57
    }
    
 
    
    private lazy var rolePickerRow = PickerRowFormer<FormPickerCell, UserRoles>().configure {
        $0.pickerItems = [UserRoles.fleetManager, UserRoles.driver].map { PickerItem<UserRoles>(title: $0!.description, value: $0) }
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

private extension MemberProfileInfoComposingRootView {
    
    func setup() {
        tableView.isScrollEnabled = false
    }
    
    func makeTextField(cellSetup: ((FormTextFieldCell) -> Void)? = nil) -> TextFieldRowFormer<FormTextFieldCell> {
        return TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.font = .systemFont(ofSize: 14)
            $0.textField.returnKeyType = .done
            cellSetup?($0)
        }.configure {
            $0.rowHeight = 57
        }
    }
    
}

extension MemberProfileInfoComposingRootView: MemberProfileInfoComposingUserInterface {
    
    func render(memberProfileInfoType: ProfileInfoType) {
        let rowFormer: RowFormer
        
        var instructionText: String? = nil
        
        switch memberProfileInfoType {
        case .user_name(let value):
            textFieldRow.cellSetup { (cell) in
                cell.textField.keyboardType = .default
            }
            textFieldRow.text = value
            
            rowFormer = textFieldRow
        case .name(let value), .model(let value):
            textFieldRow.cellSetup { (cell) in
                cell.textField.keyboardType = .default
            }
            textFieldRow.text = value
            
            rowFormer = textFieldRow
        case .role(let value):
            rolePickerRow.selectedRow = (value == .fleetManager ? 0 : 1)
            
            rowFormer = rolePickerRow
        case .email(let value):
            textFieldRow.cellSetup { (cell) in
                cell.textField.keyboardType = .emailAddress
            }
            textFieldRow.text = value
            
            rowFormer = textFieldRow
            
            instructionText = "ⓘ " + NSLocalizedString(
                """
        Email address can be empty.
        
        If so, the driver will be created in the fleet, but the driver account will not take effect until the email is entered.
        
        Email can be entered at any time to activate the driver account.
        """
                , comment: "")
        case .phoneNumber(let value):
            textFieldRow.cellSetup { (cell) in
                cell.textField.keyboardType = .phonePad
            }
            textFieldRow.text = value
            
            rowFormer = textFieldRow
            
            instructionText = "ⓘ " + NSLocalizedString("Phone number can be empty.", comment: "")
        case .plateNumber(let value):
            textFieldRow.cellSetup { (cell) in
                cell.textField.keyboardType = .asciiCapable
            }
            textFieldRow.text = value
            
            rowFormer = textFieldRow
        case .range(let value):
            textFieldRow = makeTextField(cellSetup: { (cell) in
                cell.titleLabel.font = .systemFont(ofSize: 14)
                cell.titleLabel?.text = NSLocalizedString("Range(miles)", comment: "Range(miles)")
                cell.textField.textAlignment = .right
                cell.textField.keyboardType = .decimalPad
                cell.textField.clearButtonMode = .never
                cell.textField.restrictor = TextFieldRestrictorFactory.makeNumericalRangeRestrictor(max: 500.0)
            })
            
            textFieldRow.text = value
            
            rowFormer = textFieldRow
            
            instructionText = "ⓘ " + NSLocalizedString("The maximal range is 500 miles.", comment: "The maximal range is 500 miles.")
        }
        
        let header = LabelViewFormer<FormLabelHeaderView>().configure { (viewFormer) in
            viewFormer.viewHeight = 0.001
        }
        
        let sectionFooter = LabelViewFormer<FormLabelFooterView>().configure { (viewFormer) in
            viewFormer.viewHeight = 0.001
        }
        
        former.removeAll()
        
        let section = SectionFormer(rowFormer: rowFormer)
            .set(headerViewFormer: header)
            .set(footerViewFormer: sectionFooter)
        
        former.append(sectionFormer: section)
        
        rowFormer.update()
        
        let footer = InstructionFooterView()
        footer.text = instructionText
        footer.resize(withWidth: UIScreen.main.bounds.width)
        
        tableView.tableFooterView = footer
    }
    
    func composedMemberProfileInfo(for type: ProfileInfoType) -> ProfileInfoType {
        switch type {
        case .name:
            return .name(textFieldRow.cell.textField.text ?? "")
        case .role:
            return .role(rolePickerRow.pickerItems[rolePickerRow.selectedRow].value!)
        case .email:
            return .email(textFieldRow.cell.textField.text ?? "")
        case .phoneNumber:
            return .phoneNumber(textFieldRow.cell.textField.text ?? "")
        case .model:
            return .model(textFieldRow.cell.textField.text ?? "")
        case .plateNumber:
            return .plateNumber(textFieldRow.cell.textField.text ?? "")
        case .range:
            return .range(textFieldRow.cell.textField.text ?? "")
        case .user_name(_):
            return .user_name(textFieldRow.cell.textField.text ?? "")
        }
    }
    
    func didAppear() {
        former.becomeEditingPrevious()
    }
}

extension MemberProfileInfoComposingRootView: UITextFieldDelegate {
    
}
