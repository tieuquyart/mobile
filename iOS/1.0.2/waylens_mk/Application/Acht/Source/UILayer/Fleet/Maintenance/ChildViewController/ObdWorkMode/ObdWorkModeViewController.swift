//
//  ObdWorkModeViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class ObdWorkModeViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: ObdWorkModeUserInterfaceView
    private let viewControllerFactory: ObdWorkModeViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let updateObdWorkModeConfigUseCaseFactory: UpdateObdWorkModeConfigUseCaseFactory
    private let generalUseCaseFactory: GeneralUseCaseFactory

    init(
        observer: Observer,
        userInterface: ObdWorkModeUserInterfaceView,
        viewControllerFactory: ObdWorkModeViewControllerFactory,
        updateObdWorkModeConfigUseCaseFactory: UpdateObdWorkModeConfigUseCaseFactory,
        generalUseCaseFactory: GeneralUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        self.updateObdWorkModeConfigUseCaseFactory = updateObdWorkModeConfigUseCaseFactory
        self.generalUseCaseFactory = generalUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        title = NSLocalizedString("OBD Work Mode", comment: "OBD Work Mode")
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

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }

}

//MARK: - Private

private extension ObdWorkModeViewController {

}

extension ObdWorkModeViewController: ObdWorkModeIxResponder {

    func select(mode: WLObdWorkMode) {
        updateObdWorkModeConfigUseCaseFactory.makeUpdateObdWorkModeConfigUseCase(mode: mode).start()
    }

    func select(voltage: (PartialKeyPath<WLObdWorkModeConfig>, Measurement<UnitElectricPotentialDifference>)) {
        var title: String? = nil

        switch voltage.0 {
        case \WLObdWorkModeConfig.voltageOn:
            title = NSLocalizedString("Voltage On", comment: "Voltage On")
        case \WLObdWorkModeConfig.voltageOff:
            title = NSLocalizedString("Voltage Off", comment: "Voltage Off")
        case \WLObdWorkModeConfig.voltageCheck:
            title = NSLocalizedString("Voltage Check", comment: "Voltage Check")
        default:
            break
        }

        let alert = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField { (textField) in
            textField.clearButtonMode = .always
            textField.text = "\(voltage.1.localeValue)"
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: "Save"), style: .default, handler: { [weak self] (_) in
            guard let self = self else {
                return
            }

            if let input = alert.textFields?.first?.text, let newVoltage = Int(input) {
                switch voltage.0 {
                case \WLObdWorkModeConfig.voltageOn:
                    self.updateObdWorkModeConfigUseCaseFactory.makeUpdateObdWorkModeConfigUseCase(voltageOn: newVoltage).start()
                case \WLObdWorkModeConfig.voltageOff:
                    self.updateObdWorkModeConfigUseCaseFactory.makeUpdateObdWorkModeConfigUseCase(voltageOff: newVoltage).start()
                case \WLObdWorkModeConfig.voltageCheck:
                    self.updateObdWorkModeConfigUseCaseFactory.makeUpdateObdWorkModeConfigUseCase(voltageCheck: newVoltage).start()
                default:
                    break
                }
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

extension ObdWorkModeViewController: ObserverForObdWorkModeEventResponder {

    func received(newState: ObdWorkModeViewControllerState) {
        userInterface.render(newState: newState)
    }

    func received(newErrorMessage: ErrorMessage) {
        alert(title: newErrorMessage.title, message: newErrorMessage.message, action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { [weak self] (action) in
                self?.makeFinishedPresentingErrorUseCase(newErrorMessage).start()
            })
        })
    }
}

extension ObdWorkModeViewController: ObserverForCurrentConnectedCameraEventResponder {

    func connectedCameraDidChange(_ camera: WLCameraDevice?) {
        generalUseCaseFactory.makeGeneralUseCase(value: UnifiedCamera(local: nil, remote: nil)).start();
        generalUseCaseFactory.makeGeneralUseCase(value: UnifiedCamera(local: camera, remote: nil)).start();

        if camera == nil {
            navigationController?.popToRootViewController(animated: true)
        }
    }

}

extension ObdWorkModeViewController: KeyPathObserverForCurrentConnectedCameraEventResponder {

    func camera(_ camera: WLCameraDevice, attributeDidChange attributeKeyPath: PartialKeyPath<WLCameraDevice>) {
        generalUseCaseFactory.makeGeneralUseCase(value: UnifiedCamera(local: camera, remote: nil)).start()
    }

}

protocol ObdWorkModeViewControllerFactory {

}
