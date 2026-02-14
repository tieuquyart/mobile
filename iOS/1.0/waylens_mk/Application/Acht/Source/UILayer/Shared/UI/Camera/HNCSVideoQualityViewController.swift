//
//  HNCSVideoQualityViewController.swift
//  Acht
//
//  Created by gliu on 6/5/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import RxSwift
import WaylensCameraSDK

class HNCSVideoQualityViewController: BaseTableViewController, CameraRelated, UITextFieldDelegate {
    
    @IBOutlet weak var debugInput: UITextField!
    @IBOutlet weak var singleStreamSwitch: UISwitch!

    private let qualityCellReuseIdentifier = "Quality Cell"

    private struct Sections: OptionSet {
        let rawValue: Int

        static let streamSwitch = Sections(rawValue: 1 << 0)
        static let mainStream   = Sections(rawValue: 1 << 1)
        static let subStream    = Sections(rawValue: 1 << 2)
    }

    private enum Section {
        case streamSwitch
        case mainStream
        case subStream
    }

    private enum CellReuseIdentifiers {
        static let switchCell = "Switch Cell"
        static let qualityCell = "Quality Cell"
    }

    private var disposeBag = DisposeBag()

    private struct State: StateType {
        var isSupportedMultiStream: Bool
        var isSubStreamOnly: Bool
        var mainStreamQuality: WLVideoQuality? = nil
        var subStreamQuality: WLVideoQuality? = nil

        var sections: [Section] {
            if isSupportedMultiStream {
                return [.streamSwitch, .mainStream, .subStream]
            } else {
                return [.mainStream]
            }
        }

        init(isSupportedMultiStream: Bool, isSubStreamOnly: Bool) {
            self.isSupportedMultiStream = isSupportedMultiStream
            self.isSubStreamOnly = isSubStreamOnly
        }
    }

    private enum Action: ActionType {
        case setMainStreamQuality(_ quality: WLVideoQuality)
        case setSubStreamQuality(_ quality: WLVideoQuality)
        case setNewCamera(_ camera: UnifiedCamera)
        case setSubStreamOnly(_ isOnly: Bool)
        case refreshQuality(camera: UnifiedCamera?)
        case fetchQuality
    }

    private enum Command: CommandType {
        case setMainStreamQuality(_ quality: WLVideoQuality)
        case setSubStreamQuality(_ quality: WLVideoQuality)
        case setSubStreamOnly(_ isOnly: Bool)
        case fetchQuality
    }

    private lazy var reducer: (State, Action) -> (state: State, command: Command?) = { [weak self] (state: State, action: Action) in
        var state = state
        var command: Command? = nil

        switch action {
        case .setNewCamera(let camera):
            state.isSubStreamOnly = camera.local?.isSubStreamOnly ?? false
        case .setSubStreamOnly(let isOnly):
            state.isSubStreamOnly = isOnly
            command = Command.setSubStreamOnly(isOnly)
        case .setMainStreamQuality(let quality):
            command = Command.setMainStreamQuality(quality)
        case .setSubStreamQuality(let quality):
            command = Command.setSubStreamQuality(quality)
        case .refreshQuality(let camera):
            state.mainStreamQuality = camera?.local?.quality
            state.subStreamQuality = camera?.local?.subQuality
        case .fetchQuality:
            command = Command.fetchQuality
        }
        return (state, command)
    }

    private var store: Store<Action, State, Command>!

    @objc dynamic var camera: UnifiedCamera? {
        didSet {
            if isViewLoaded {
                if let camera = camera {
                    store.dispatch(.setNewCamera(camera))
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Video Quality", comment: "Video Quality")

        tableView.sectionHeaderHeight = 12
        tableView.backgroundColor = UIColor.semanticColor(.background(.secondary))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellReuseIdentifiers.switchCell)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellReuseIdentifiers.qualityCell)

        let isSupportedMultiStream = camera?.featureAvailability.isSubStreamOnlyAvailable ?? false

        store = Store<Action, State, Command>(reducer: reducer, initialState: State(isSupportedMultiStream: isSupportedMultiStream, isSubStreamOnly: true))

        store.subscribe { [weak self] (state, previousState, command) in
            self?.stateDidChanged(state: state, previousState: previousState, command: command)
        }

        if let camera = camera {
            store.dispatch(.setNewCamera(camera))
        }

        self.rx.observeWeakly(WLVideoQuality.self, #keyPath(camera.local.quality))
            .subscribe(onNext: { [weak self] quality in
                self?.store.dispatch(.refreshQuality(camera: self?.camera))
            }).disposed(by: disposeBag)

        self.rx.observeWeakly(WLVideoQuality.self, #keyPath(camera.local.subQuality))
            .subscribe(onNext: { [weak self] quality in
                self?.store.dispatch(.refreshQuality(camera: self?.camera))
            }).disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        camera?.local?.settingsDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if camera?.local?.settingsDelegate === self {
            camera?.local?.settingsDelegate = nil
        }
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
        case .setMainStreamQuality(let quality):
            camera?.local?.quality = quality
        case .setSubStreamQuality(let quality):
            camera?.local?.subQuality = quality
        case .setSubStreamOnly(let isOnly):
            camera?.local?.doSetSubStreamOnly(isOnly)
            camera?.local?.doGetSubStreamOnly()
        case .fetchQuality:
            camera?.local?.doGetQuality()
        }
    }

    private func updateUI(from previousState: State?, to state: State) {
        if previousState == nil || previousState?.isSubStreamOnly != state.isSubStreamOnly {
            tableView.reloadData()
        }

        if previousState == nil || previousState?.mainStreamQuality != state.mainStreamQuality {
            updateSection(.mainStream)
        }

        if previousState == nil || previousState?.subStreamQuality != state.subStreamQuality {
            updateSection(.subStream)
        }

    }

    private func updateSection(_ section: Section) {
        if let index = store.state.sections.firstIndex(of: section) {
            tableView.reloadSections([index], with: .none)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return store.state.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let s = store.state.sections[section]

        switch s {
        case .streamSwitch:
            return 1
        case .mainStream:
            return WLVideoQuality.allMainStreamQualities.count
        case .subStream:
            return WLVideoQuality.allSubStreamQualities.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let s = store.state.sections[section]

        switch s {
        case .streamSwitch:
            return nil
        case .mainStream:
            return NSLocalizedString("Main Stream", comment: "Main Stream")
        case .subStream:
            return NSLocalizedString("Sub Stream", comment: "Sub Stream")
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == store.state.sections.count - 1 {
            return NSLocalizedString("video_quality_description", comment: "Super High: 36Mbps.\nHigh: 28Mbps.\nNormal: 20Mbps.\nLow: 10Mbps.\nSuper Low: 5Mbps.\n* The bitrate will be effective from next recording.")
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let s = store.state.sections[indexPath.section]

        switch s {
        case .streamSwitch:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifiers.switchCell, for: indexPath)
            cell.textLabel?.text = NSLocalizedString("Sub Stream Only", comment: "Sub Stream Only")
            cell.selectionStyle = .none

            let switchControl = UISwitch()
            switchControl.isOn = store.state.isSubStreamOnly
            switchControl.addTarget(self, action: #selector(singleStreamSwitchValueChaged), for: .valueChanged)

            cell.accessoryView = switchControl

            return cell
        case .mainStream:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifiers.qualityCell, for: indexPath)

            let quality = WLVideoQuality.allMainStreamQualities[indexPath.row]
            cell.textLabel?.text = quality.name

            if quality == store.state.mainStreamQuality {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            if store.state.isSubStreamOnly {
                cell.contentView.alpha = 0.5
                cell.isUserInteractionEnabled = false
            } else {
                cell.contentView.alpha = 1.0
                cell.isUserInteractionEnabled = true
            }

            return cell
        case .subStream:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifiers.qualityCell, for: indexPath)

            let quality = WLVideoQuality.allSubStreamQualities[indexPath.row]
            cell.textLabel?.text = quality.name

            if quality == store.state.subStreamQuality {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let s = store.state.sections[indexPath.section]

        switch s {
        case .mainStream:
            let quality = WLVideoQuality.allMainStreamQualities[indexPath.row]

            if quality != store.state.mainStreamQuality {
                store.dispatch(.setMainStreamQuality(quality))
            }
        case .subStream:
            let quality = WLVideoQuality.allSubStreamQualities[indexPath.row]

            if quality != store.state.subStreamQuality {
                store.dispatch(.setSubStreamQuality(quality))
            }
        default:
            break
        }
    }

    @IBAction func singleStreamSwitchValueChaged(_ sender: UISwitch) {
        store.dispatch(.setSubStreamOnly(sender.isOn))
    }

}

extension HNCSVideoQualityViewController: WLCameraSettingsDelegate {

    func onSetQuality(_ success: Bool) {
//        if success {
        store.dispatch(.fetchQuality)
        store.dispatch(.setSubStreamOnly(store.state.isSubStreamOnly))
//        }
    }

}

extension WLVideoQuality {

    static var allMainStreamQualities: [WLVideoQuality] {
        return [
            Video_Quality_Supper,
            Video_Quality_HI,
            Video_Quality_Mid,
            Video_Quality_LOW,
            Video_Quality_SuperLOW,
            Video_Quality_Mid_5FPS,
            Video_Quality_LOW_5FPS,
            Video_Quality_SuperLOW_5FPS
        ]
    }

    static var allSubStreamQualities: [WLVideoQuality] {
        return [
            Video_Quality_HI,
            Video_Quality_Mid,
            Video_Quality_LOW
        ]
    }

    var name: String {
        switch self {
        case Video_Quality_Supper:
            return NSLocalizedString("Super High", comment: "Video Quality")
        case Video_Quality_HI:
            return NSLocalizedString("High", comment: "Video Quality")
        case Video_Quality_Mid:
            return NSLocalizedString("Normal", comment: "Video Quality")
        case Video_Quality_LOW:
            return NSLocalizedString("Low", comment: "Video Quality")
        case Video_Quality_SuperLOW:
            return NSLocalizedString("Super Low", comment: "Video Quality")
        case Video_Quality_Mid_5FPS:
            return NSLocalizedString("Normal 5FPS", comment: "Video Quality")
        case Video_Quality_LOW_5FPS:
            return NSLocalizedString("Low 5FPS", comment: "Video Quality")
        case Video_Quality_SuperLOW_5FPS:
            return NSLocalizedString("Super Low 5FPS", comment: "Video Quality")
        default:
            return NSLocalizedString("Unknown Video Quality", comment: "Video Quality")
        }
    }

}
