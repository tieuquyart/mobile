//
//  HNCSWiFiModeViewController.swift
//  Acht
//
//  Created by forkon on 2019/8/13.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import SVProgressHUD
import WaylensCameraSDK

class HNCSWiFiModeViewController: BaseTableViewController, CameraRelated {
    private struct Sections: OptionSet {
        let rawValue: Int

        static let streamSwitch = Sections(rawValue: 1 << 0)
        static let mainStream   = Sections(rawValue: 1 << 1)
        static let subStream    = Sections(rawValue: 1 << 2)
    }

    private enum Section {
        case apMode
        case clientMode
    }

    private enum CellReuseIdentifiers {
        static let apModeCell = "AP Mode Cell"
        static let hotspotCell = "Hotspot Cell"
    }

    private struct State: StateType {
        private(set) var hotspots: [String]? = nil
        var connectedHotspot: String? = nil
        var currentWiFiMode: WLWiFiMode? = nil

        var sections: [Section] {
            return [.apMode, .clientMode]
        }

        init(currentWiFiMode: WLWiFiMode? = nil, hotspots: [String]? = nil) {
            self.currentWiFiMode = currentWiFiMode
            self.hotspots = hotspots
        }

        mutating func reset() {
            hotspots = nil
            connectedHotspot = nil
            currentWiFiMode = nil
        }

        mutating func updateHotspots(_ newHotspots: [String]) {
            hotspots = newHotspots
        }

        mutating func removeHotspot(_ hotspot: String) {
            if let index = hotspots?.firstIndex(of: hotspot) {
                hotspots?.remove(at: index)
            }
        }
    }

    private enum Action: ActionType {
        case setCamera(_ camera: UnifiedCamera)
        case chooseWiFiMode(_ mode: WLWiFiMode)
        case chooseHotspot(_ ssid: String)
        case tapAddHotspot
        case addHotspot(ssid: String, password: String)
        case removeHotspot(ssid: String)
        case refreshHotspotList
    }

    private enum Command: CommandType {
        case fetchHotspotList
        case setWiFiMode(_ mode: WLWiFiMode)
        case showAddHotspotAlert
        case addHotspot(ssid: String, password: String)
        case removeHotspot(ssid: String)
        case connectHotspot(ssid: String)
    }

    private var isViewAppeared: Bool = false
    private lazy var ssidHelper: IOS13SSIDHelper = IOS13SSIDHelper()

    private lazy var reducer: (State, Action) -> (state: State, command: Command?) = { [weak self] (state: State, action: Action) in
        var state = state
        var command: Command? = nil

        switch action {
        case .setCamera(let camera):
            state.currentWiFiMode = camera.local?.wifiMode
            state.connectedHotspot = WLBonjourCameraListManager.shared.currentWiFi

            if let wifiHostList = camera.local?.wifiHostList as? [String] {
                state.updateHotspots(wifiHostList)
            } else {
                command = Command.fetchHotspotList
            }
        case .chooseWiFiMode(let mode):
            state.reset()
            command = Command.setWiFiMode(mode)
        case .chooseHotspot(let ssid):
            state.reset()
            command = Command.connectHotspot(ssid: ssid)
        case .tapAddHotspot:
            command = Command.showAddHotspotAlert
        case .addHotspot(let ssid, let password):
            command = Command.addHotspot(ssid: ssid, password: password)
        case .removeHotspot(let ssid):
            state.removeHotspot(ssid)
            command = Command.removeHotspot(ssid: ssid)
        case .refreshHotspotList:
            if let wifiHostList = self?.camera?.local?.wifiHostList as? [String] {
                state.updateHotspots(wifiHostList)
            }
        }
        return (state, command)
    }

    private var store: Store<Action, State, Command>!

    @objc dynamic var camera: UnifiedCamera? {
        didSet {
            if isViewLoaded {
                if let camera = camera {
                    store.dispatch(.setCamera(camera))

                    if isViewAppeared, let localCamera = camera.local, localCamera.settingsDelegate == nil {
                        localCamera.settingsDelegate = self
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("WiFi Mode", comment: "WiFi Mode")

        tableView.sectionHeaderHeight = 12
        tableView.backgroundColor = UIColor.semanticColor(.background(.secondary))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellReuseIdentifiers.apModeCell)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellReuseIdentifiers.hotspotCell)

        store = Store<Action, State, Command>(reducer: reducer, initialState: State())

        store.subscribe { [weak self] (state, previousState, command) in
            self?.stateDidChanged(state: state, previousState: previousState, command: command)
        }

        if let camera = camera {
            store.dispatch(.setCamera(camera))
        }

        if #available(iOS 13.0, *) {
            ssidHelper.requestPermission()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        camera?.local?.settingsDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        isViewAppeared = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if camera?.local?.settingsDelegate === self {
            camera?.local?.settingsDelegate = nil
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        isViewAppeared = false
    }

    private func stateDidChanged(state: State, previousState: State?, command: Command?) {
        executeCommand(command)
        updateUI(from: previousState, to: state)
    }

    private func executeCommand(_ command: Command?) {
        guard let command = command else {
            return
        }

        switch command {
        case .fetchHotspotList:
            camera?.local?.updateHostNum()
        case .setWiFiMode(let mode):
            if mode == Wifi_Mode_Client {
                if let hotspots = store.state.hotspots, hotspots.isEmpty {
                    showAddHotspotAlert { [weak self] ssid in
                        self?.camera?.local?.connect(toSSID: ssid)
                    }
                } else {
                    if let ssid = store.state.hotspots?.first {
                        camera?.local?.connect(toSSID: ssid)
                    }
                }
            } else {
                camera?.local?.setWifiMode(Int32(mode.rawValue), toSSID: nil)
            }
        case .showAddHotspotAlert:
            showAddHotspotAlert()
        case .addHotspot(let ssid, let password):
            camera?.local?.addHost(ssid, password: password)
        case .removeHotspot(let ssid):
            camera?.local?.removeHost(ssid)
        case .connectHotspot(let ssid):
            camera?.local?.connect(toSSID: ssid)

            HNMessage.show(message: NSLocalizedString(String(format: "Switching to %@...", ssid), comment: "switching WiFi mode message"))
            HNMessage.dismiss(withDelay: 15.0) { [weak self] in
                if self?.camera?.local == nil {
                    self?.alert(
                        title: NSLocalizedString("Please connect camera and this device to the same WiFi.", comment: "Please connect camera and this device to the same WiFi."),
                        message: ""
                    )
                }
            }
        }
    }

    private func updateUI(from previousState: State?, to state: State) {
        if previousState == nil || previousState?.currentWiFiMode != state.currentWiFiMode {
            tableView.reloadData()
        }

        if previousState == nil || previousState?.hotspots != state.hotspots {
            if !tableView.isEditing {
                updateSection(.clientMode)
            }
        }
    }

    private func updateSection(_ section: Section) {
        if let index = store.state.sections.firstIndex(of: section) {
            tableView.reloadSections([index], with: .none)
        }
    }

    private func showAddHotspotAlert(with completion: ((String) -> Void)? = nil) {
        let alert = UIAlertController(
            title: NSLocalizedString("Add Hotspot", comment: "Add Hotspot"),
            message: nil,
            preferredStyle: .alert
        )

        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("SSID", comment: "SSID")
        }
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Password", comment: "Password")
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: "Add"), style: .default, handler: { [weak self] (_) in
            if let ssid = alert.textFields?.first?.text, !ssid.isEmpty, let password = alert.textFields?.last?.text, !password.isEmpty {
                self?.store.dispatch(.addHotspot(ssid: ssid, password: password))
                completion?(ssid)
            }
        }))

        present(alert, animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return store.state.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let s = store.state.sections[section]

        switch s {
        case .apMode:
            return 1
        case .clientMode:
            if let hotspots = store.state.hotspots {
                return hotspots.count + 1 // 1 for add hotspot cell
            } else {
                return 1 // 1 for add hotspot cell
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let s = store.state.sections[section]

        switch s {
        case .apMode:
            return NSLocalizedString("AP Mode", comment: "AP mode")
        case .clientMode:
            return NSLocalizedString("Client Mode", comment: "Client Mode")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let s = store.state.sections[indexPath.section]

        var cell: UITableViewCell!

        switch s {
        case .apMode:
            cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifiers.apModeCell, for: indexPath)

            cell.textLabel?.text = NSLocalizedString("AP", comment: "AP mode")

            if store.state.currentWiFiMode == Wifi_Mode_AP {
                cell.accessoryType = .checkmark
                cell.isUserInteractionEnabled = false
            } else {
                cell.accessoryType = .none
                cell.isUserInteractionEnabled = true
            }
        case .clientMode:
            cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifiers.hotspotCell, for: indexPath)

            cell.accessoryType = .none
            cell.isUserInteractionEnabled = true

            let row = indexPath.row
            if let hotspots = store.state.hotspots, row < hotspots.count {
                let hotspot = hotspots[row]
                cell.textLabel?.textColor = UIColor.black
                cell.textLabel?.text = hotspot

                if hotspot == store.state.connectedHotspot {
                    cell.accessoryType = .checkmark
                    cell.isUserInteractionEnabled = false
                }
            } else {
                cell.textLabel?.textColor = UIColor.semanticColor(.tint(.primary))
                cell.textLabel?.text = NSLocalizedString("Add hotspot...", comment: "Add hotspot...")
            }

        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let message = NSLocalizedString("Switching Wi-Fi mode will cause Wifi restart.  You need to reconnect the camera Wi-Fi.", comment: "switching WiFi mode message")

        let s = self.store.state.sections[indexPath.section]

        switch s {
        case .apMode:
            alert(message: message, okHandler:  { [unowned self] in
                self.store.dispatch(.chooseWiFiMode(Wifi_Mode_AP))
            })
        case .clientMode:
            let row = indexPath.row

            if let hotspots = self.store.state.hotspots, row < hotspots.count {
                let hotspot = hotspots[indexPath.row]
                alert(message: message, okHandler:  { [unowned self] in
                    self.store.dispatch(.chooseHotspot(hotspot))
                })
            } else {
                self.store.dispatch(.tapAddHotspot)
            }
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let s = store.state.sections[indexPath.section]

        switch s {
        case .clientMode:
            let row = indexPath.row

            if let hotspots = store.state.hotspots, row < hotspots.count {
                let hotspot = hotspots[row]

                if hotspot != store.state.connectedHotspot {
                    return true
                }
            }
        default:
            break
        }

        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let s = store.state.sections[indexPath.section]

            switch s {
            case .clientMode:
                let row = indexPath.row

                if let hotspots = store.state.hotspots, row < hotspots.count {
                    let hotspot = hotspots[row]
                    store.dispatch(.removeHotspot(ssid: hotspot))
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            default:
                break
            }
        }
    }
}

extension HNCSWiFiModeViewController: WLCameraSettingsDelegate {

    func onWiFiHostListChanged(_ hostList: [Any]) {
        store.dispatch(.refreshHotspotList)
    }

}

extension WLWiFiMode {

    var name: String {
        switch self {
        case Wifi_Mode_AP:
            return NSLocalizedString("AP", comment: "WiFi Mode")
        case Wifi_Mode_Client:
            return NSLocalizedString("Client", comment: "WiFi Mode")
        default:
            return NSLocalizedString("Unknown WiFi Mode", comment: "Unknown WiFi Mode")
        }
    }

}
