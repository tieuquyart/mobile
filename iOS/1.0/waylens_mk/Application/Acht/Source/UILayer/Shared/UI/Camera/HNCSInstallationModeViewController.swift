//
//  HNCSInstallationModeViewController.swift
//  Acht
//
//  Created by forkon on 2019/6/17.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import WaylensCameraSDK

class HNCSInstallationModeViewController: BaseViewController, CameraRelated {
    private var selectedInstallationMode: CameraInstallationMode? = nil
    private var isUsingInSetupGuide: Bool {
        return camera == nil
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var guideLabel: UILabel!

    #if FLEET
    var applyButton: UIBarButtonItem!
    #endif

    @objc var camera: UnifiedCamera?

    static func createViewController() -> HNCSInstallationModeViewController {
        let vc = UIStoryboard(name: "CameraSettings", bundle: nil).instantiateViewController(withIdentifier: "HNCSInstallationModeViewController")
        return vc as! HNCSInstallationModeViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Camera View", comment: "Camera View")
        view.backgroundColor = UIColor.semanticColor(.background(.secondary))

        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()

        if !isUsingInSetupGuide {
            selectedInstallationMode = camera?.installationMode

            #if FLEET
            applyButton = UIBarButtonItem(title: NSLocalizedString("Apply", comment: "Apply"), style: UIBarButtonItem.Style.done, target: self, action: #selector(applySettingsIfNeeded))
            applyButton.isEnabled = false
            navigationItem.rightBarButtonItem = applyButton

            camera?.local?.settingsDelegate = self
            #endif
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isUsingInSetupGuide {
            NotificationCenter.default.addObserver(self, selector: #selector(handleCurrentDeviceDidChangeNotification), name: NSNotification.Name.WLCurrentCameraChange, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)

            #if FLEET
            camera?.local?.settingsDelegate = self
            #endif
        }

        refreshUI()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)

        #if !FLEET
        if parent == nil && !isUsingInSetupGuide { // navigationController pop
            applySettingsIfNeeded()
        }
        #endif
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }

    override func applyTheme() {
        super.applyTheme()

        tableView.reloadData()
    }

    @objc private func refreshUI() {
        if isUsingInSetupGuide {
            nextButton.isHidden = false
        } else {
            nextButton.isHidden = true

            #if FLEET
            if selectedInstallationMode != camera?.installationMode {
                applyButton.isEnabled = true
            } else {
                applyButton.isEnabled = false
            }
            #endif
        }

        nextButton.isEnabled = (selectedInstallationMode != nil)
        nextButton.backgroundColor = nextButton.isEnabled ? UIColor.semanticColor(.tint(.primary)) : UIColor.semanticColor(.background(.quaternary))

        if let selectedInstallationMode = selectedInstallationMode, let selectedIndex = CameraInstallationMode.allCases.firstIndex(of: selectedInstallationMode) {
            tableView.selectRow(at: IndexPath(row: selectedIndex, section: 0), animated: false, scrollPosition: .none)
        }
    }

    @objc private func applySettingsIfNeeded() {
        let upsideDown = selectedInstallationMode == .some(.lensDown) ? true : false

        if isUsingInSetupGuide {
            #if FLEET
            if let remoteCamera = UnifiedCameraManager.shared.local?.remote, let selectedInstallationMode = selectedInstallationMode {
                HNMessage.show(message: NSLocalizedString("Applying settings...", comment: "Applying settings..."))
                remoteCamera.commitSettings(of: selectedInstallationMode) { [weak self] (result) in
                    switch result {
                    case .success:
                        HNMessage.showSuccess(message: NSLocalizedString("Apply settings successfully!", comment: "Apply settings successfully!"))

                        WLBonjourCameraListManager.shared.currentCamera?.setAttitude(upsideDown)
                        WLBonjourCameraListManager.shared.currentCamera?.getAttitude()

                        let vc = SetupStepThreeViewController.createViewController()
                        self?.navigationController?.pushViewController(vc, animated: true)
                    case .failure(_):
                        HNMessage.dismiss()
                        self?.alert(message: NSLocalizedString("Failed to apply settings, please check network connection.", comment: "Failed to apply settings, please check network connection."), action1: { () -> UIAlertAction in
                            return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel) { _ in

                            }
                        }, action2: { () -> UIAlertAction in
                            return UIAlertAction(title: NSLocalizedString("Skip", comment: "Skip"), style: .default) { _ in
                                let vc = SetupStepThreeViewController.createViewController()
                                self?.navigationController?.pushViewController(vc, animated: true)
                            }
                        })
                    }
                }
            } else {
                WLBonjourCameraListManager.shared.currentCamera?.setAttitude(upsideDown)
                WLBonjourCameraListManager.shared.currentCamera?.getAttitude()

                let vc = SetupStepThreeViewController.createViewController()
                navigationController?.pushViewController(vc, animated: true)
            }
            #else
            if WLBonjourCameraListManager.shared.currentCamera?.isUpsideDown == upsideDown {
                return
            }

            WLBonjourCameraListManager.shared.currentCamera?.setAttitude(upsideDown)
            WLBonjourCameraListManager.shared.currentCamera?.getAttitude()
            #endif
        } else {
            if selectedInstallationMode == camera?.installationMode {
                return
            }

            #if FLEET
            if let remoteCamera = camera?.remote, let selectedInstallationMode = selectedInstallationMode {
                HNMessage.show(message: NSLocalizedString("Applying settings...", comment: "Applying settings..."))
                remoteCamera.commitSettings(of: selectedInstallationMode) { [weak self] (result) in
                    switch result {
                    case .success:
                        HNMessage.showSuccess(message: NSLocalizedString("Apply settings successfully!", comment: "Apply settings successfully!"))
                        self?.camera?.local?.setAttitude(upsideDown)
                        self?.camera?.local?.getAttitude()
                    case .failure(let error):
                        HNMessage.dismiss()
                        self?.alert(message: error?.localizedDescription ?? NSLocalizedString("Failed to apply settings, please check network connection.", comment: "Failed to apply settings, please check network connection."))
                    }
                }
            } else {
                camera?.local?.setAttitude(upsideDown)
                camera?.local?.getAttitude()
            }
            #else
            camera?.local?.setAttitude(upsideDown)
            camera?.local?.getAttitude()
            #endif
        }
    }

    @IBAction private func nextButtonTapped(_ sender: Any) {
        applySettingsIfNeeded()

        #if !FLEET
        let vc = SetupStepThreeViewController.createViewController()
        navigationController?.pushViewController(vc, animated: true)
        #endif
    }

    @objc private func handleCurrentDeviceDidChangeNotification() {
        navigationController?.popViewController(animated: false)
    }

    @objc private func handleApplicationDidEnterBackgroundNotification() {
        #if !FLEET
        applySettingsIfNeeded()
        #endif
    }

}

extension HNCSInstallationModeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CameraInstallationMode.allCases.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CameraInstallationModeCell", for: indexPath) as! CameraInstallationModeCell

        let installationMode = CameraInstallationMode.allCases[indexPath.row]
        cell.nameLabel.text = installationMode.name
        cell.pictureView.image = installationMode.image

        switch installationMode {
        case .lensUp:
            cell.pictureView.contentMode = .center
        case .lensDown:
            cell.pictureView.contentMode = .top
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedInstallationMode = CameraInstallationMode.allCases[indexPath.row]
        refreshUI()
    }

}

extension HNCSInstallationModeViewController: WLCameraSettingsDelegate {

    func onGetAttitude(_ isUpsideDown: Bool) {
        refreshUI()
    }

}

class CameraInstallationModeCell: UITableViewCell, Themed {
    @IBOutlet private weak var wrapperView: UIView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pictureView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    func applyTheme() {
        backgroundColor = UIColor.clear

        if isSelected {
            nameLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
            nameLabel.textColor = UIColor.semanticColor(.tint(.primary))
            wrapperView.layer.borderColor = UIColor.semanticColor(.tint(.primary)).cgColor
        } else {
            nameLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
            nameLabel.textColor = UIColor.semanticColor(.label(.secondary))
            wrapperView.layer.borderColor = UIColor.clear.cgColor
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

    private func setup() {
        selectionStyle = .none

        wrapperView.layer.borderColor = UIColor.clear.cgColor
        wrapperView.layer.borderWidth = 1.0
        wrapperView.layer.cornerRadius = 3.0
        wrapperView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        wrapperView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        wrapperView.layer.shadowRadius = 6.0
        wrapperView.layer.shadowOpacity = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        applyTheme()
    }

}

extension CameraInstallationMode {

    var name: String {
        switch self {
        case .lensUp:
            return NSLocalizedString("Lens Up", comment: "Camera Installation Mode")
        case .lensDown:
            return NSLocalizedString("Lens Down", comment: "Camera Installation Mode")
        }
    }

    var image: UIImage {
        switch self {
        case .lensUp:
            return UIImage(named: "lens up")!
        case .lensDown:
            return UIImage(named: "lens down")!
        }
    }

}
