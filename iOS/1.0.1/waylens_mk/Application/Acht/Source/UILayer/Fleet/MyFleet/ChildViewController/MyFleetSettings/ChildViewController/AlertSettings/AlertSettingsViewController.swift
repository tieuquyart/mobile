//
//  AlertSettingsViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class AlertSettingsViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: AlertSettingsUserInterfaceView
    private let loadAlertSettingsUseCaseFactory: LoadAlertSettingsUseCaseFactory
    private let toggleAlertSettingUseCaseFactory: ToggleAlertSettingUseCaseFactory
    private let saveAlertSettingsUseCaseFactory: SaveAlertSettingsUseCaseFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory

    init(
        observer: Observer,
        userInterface: AlertSettingsUserInterfaceView,
        loadAlertSettingsUseCaseFactory: LoadAlertSettingsUseCaseFactory,
        toggleAlertSettingUseCaseFactory: ToggleAlertSettingUseCaseFactory,
        saveAlertSettingsUseCaseFactory: SaveAlertSettingsUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.loadAlertSettingsUseCaseFactory = loadAlertSettingsUseCaseFactory
        self.toggleAlertSettingUseCaseFactory = toggleAlertSettingUseCaseFactory
        self.saveAlertSettingsUseCaseFactory = saveAlertSettingsUseCaseFactory
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
        applyTheme()
        self.navigationItem.setHidesBackButton(true, animated: false)
        let saveButton = UIBarButtonItem(title: NSLocalizedString("Save", comment: "Save"), style: UIBarButtonItem.Style.done, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton

        observer.startObserving()

        loadAlertSettingsUseCaseFactory.makeLoadAlertSettingsUseCase().start()
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavigationBar(animated: animated)
        title = NSLocalizedString("Alert Settings", comment: "Alert Settings")
        self.showNavigationBar(animated: animated)
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

private extension AlertSettingsViewController {

    @objc func saveButtonTapped() {
        saveAlertSettingsUseCaseFactory.makeSaveAlertSettingsUseCase().start()
    }

}

extension AlertSettingsViewController: AlertSettingsIxResponder {

    func toggle(setting: AlertSettingSet, isOn: Bool) {
        toggleAlertSettingUseCaseFactory.makeToggleAlertSettingUseCase(alertSetting: setting, isOn: isOn).start()
    }

}

extension AlertSettingsViewController: ObserverForAlertSettingsEventResponder {

    func received(newState: AlertSettingsViewControllerState) {
        userInterface.render(newState: newState)

        if newState.viewState.activityIndicatingState.isSuccess {
            navigationController?.popViewController(animated: true)
        }
    }

    func received(newErrorMessage: ErrorMessage) {
        alert(title: newErrorMessage.title, message: newErrorMessage.message, action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { [weak self] (action) in
                self?.makeFinishedPresentingErrorUseCase(newErrorMessage).start()
            })
        })
    }

}
