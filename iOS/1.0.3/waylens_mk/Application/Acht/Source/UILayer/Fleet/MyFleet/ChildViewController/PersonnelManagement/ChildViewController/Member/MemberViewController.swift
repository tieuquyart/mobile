//
//  MemberViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class MemberViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: MemberUserInterfaceView
    private let loadMemberProfileUseCaseFactory: LoadMemberProfileUseCaseFactory
    private let memberViewControllerFactory: ProfileViewControllerFactory
    private let beginEditingMemberProfileUseCaseFactory: BeginEditingMemberProfileUseCaseFactory
    private let doneEditingMemberProfileUseCaseFactory: DoneEditingMemberProfileUseCaseFactory
    private let saveNewMemberUseCaseFactory: SaveNewMemberUseCaseFactory
    private let removeMemberUseCaseFactory: RemoveMemberUseCaseFactory
    private let updateMemberProfileUseCaseFactory: UpdateMemberProfileUseCaseFactory
    private let changeFleetOwnerUseCaseFactory: ChangeFleetOwnerUseCaseFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory

    init(
        observer: Observer,
        userInterface: MemberUserInterfaceView,
        loadMemberProfileUseCaseFactory: LoadMemberProfileUseCaseFactory,
        memberViewControllerFactory: ProfileViewControllerFactory,
        beginEditingMemberProfileUseCaseFactory: BeginEditingMemberProfileUseCaseFactory,
        doneEditingMemberProfileUseCaseFactory: DoneEditingMemberProfileUseCaseFactory,
        saveNewMemberUseCaseFactory: SaveNewMemberUseCaseFactory,
        removeMemberUseCaseFactory: RemoveMemberUseCaseFactory,
        updateMemberProfileUseCaseFactory: UpdateMemberProfileUseCaseFactory,
        changeFleetOwnerUseCaseFactory: ChangeFleetOwnerUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.loadMemberProfileUseCaseFactory = loadMemberProfileUseCaseFactory
        self.memberViewControllerFactory = memberViewControllerFactory
        self.beginEditingMemberProfileUseCaseFactory = beginEditingMemberProfileUseCaseFactory
        self.doneEditingMemberProfileUseCaseFactory = doneEditingMemberProfileUseCaseFactory
        self.saveNewMemberUseCaseFactory = saveNewMemberUseCaseFactory
        self.removeMemberUseCaseFactory = removeMemberUseCaseFactory
        self.updateMemberProfileUseCaseFactory = updateMemberProfileUseCaseFactory
        self.changeFleetOwnerUseCaseFactory = changeFleetOwnerUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = userInterface
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        observer.startObserving()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadMemberProfileUseCaseFactory.makeLoadMemberProfileUseCase().start()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension MemberViewController {

    @objc func cancelButtonTapped(_ sender: Any) {
        dismissMyself(animated: true)
    }

    @objc func doneButtonTapped(_ sender: Any) {
        updateMemberProfileUseCaseFactory.makeUpdateMemberProfileUseCase().start()
        doneEditingMemberProfileUseCaseFactory.makeDoneEditingMemberProfileUseCase().start()
    }

    @objc func editButtonTapped(_ sender: Any) {
        beginEditingMemberProfileUseCaseFactory.makeBeginEditingMemberProfileUseCase().start()
    }

}

extension MemberViewController: MemberIxResponder {

    func beginComposeProfileInfo(_ infoType: ProfileInfoType) {
        navigationController?.pushViewController(memberViewControllerFactory.makeProfileInfoComposingViewController(with: infoType), animated: true)
    }

    func saveMember() {
        saveNewMemberUseCaseFactory.makeSaveNewMemberUseCase().start()
    }

    func removeMember() {
        self.alert(message: NSLocalizedString("Are you sure to remove this member?", comment: "Are you sure to remove this member?"), action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: .destructive, handler: { [weak self] (action) in
                self?.removeMemberUseCaseFactory.makeRemoveMemberUseCase().start()
            })
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Yes"), style: .cancel, handler: { (action) in
            })
        }
    }

    func setAsFleetOwner() {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("Each fleet can only have one fleet owner. Are you sure to set this member as fleet owner and set the current fleet owner as general manager role?", comment: "Each fleet can only have one fleet owner. Are you sure to set this member as fleet owner and set the current fleet owner as general manager role?"),
            preferredStyle: .alert
        )

        alert.addTextField { (textField) in
            textField.clearButtonMode = .always
            textField.isSecureTextEntry = true
            textField.placeholder = NSLocalizedString("Enter password to set...", comment: "Enter password to set...")
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Set", comment: "Set"), style: .default, handler: { [weak self] (action) in
            if let password = alert.textFields?.first?.text, !password.isEmpty {
                self?.changeFleetOwnerUseCaseFactory.makeChangeFleetOwnerUseCase(password: password).start()
            }
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}

extension MemberViewController: ObserverForMemberEventResponder {

    func received(newState: MemberViewControllerState) {
        userInterface.render(newState: newState)

        switch newState.scene {
        case .viewing(_):
            title = newState.memberProfile.name

            isEditing = newState.viewState.isEditing
            if isEditing {
                navigationItem.rightBarButtonItem = UIBarButtonItem(
                    title: NSLocalizedString("Done", comment: "Done"),
                    style: UIBarButtonItem.Style.done,
                    target: self,
                    action: #selector(doneButtonTapped(_:))
                )
            } else {
                navigationItem.rightBarButtonItem = UIBarButtonItem(
                    title: NSLocalizedString("Edit", comment: "Edit"),
                    style: UIBarButtonItem.Style.plain,
                    target: self,
                    action: #selector(editButtonTapped(_:))
                )
            }

            switch newState.viewState.activityIndicatingState {
            case .doneRemoving:
                navigationController?.popViewController(animated: true)
            default:
                break
            }
        case .addingNew:
            navigationItem.rightBarButtonItem = nil
            title = NSLocalizedString("Add New Member", comment: "Add New Member")

            switch newState.viewState.activityIndicatingState {
            case .doneSaving:
                dismissMyself(animated: true)
            default:
                break
            }
        }

        if navigationController?.presentingViewController != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: NSLocalizedString("Cancel", comment: "Cancel"),
                style: .plain,
                target: self,
                action: #selector(cancelButtonTapped(_:))
            )
        }

    }

    func received(newMemberProfile: MemberProfile) {
        userInterface.render(memberProfile: newMemberProfile)
    }

    func received(newErrorMessage: ErrorMessage) {
        alert(title: newErrorMessage.title, message: newErrorMessage.message, action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { [weak self] (action) in
                self?.makeFinishedPresentingErrorUseCase(newErrorMessage).start()
            })
        })
    }

}
