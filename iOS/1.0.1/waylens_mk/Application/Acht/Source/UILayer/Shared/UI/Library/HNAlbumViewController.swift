//
//  HNAlbumViewController.swift
//  Acht
//
//  Created by Chester Shen on 9/21/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
#if useMixpanel
import Mixpanel
#endif

class HNAlbumViewController: BaseTableViewController {
    struct State: StateType {
        var dataSource = HNAlbumViewControllerDataSource(clips: [], owner: nil)
        var isEditing = false
        var indexesOfSelectedClips: [Int] = []
        var isSelectedAllClips: Bool {
            return !indexesOfSelectedClips.isEmpty && indexesOfSelectedClips.count >= dataSource.clips.count
        }
        var canToggleEditMode: Bool {
            return !dataSource.clips.isEmpty
        }
    }

    enum Action: ActionType {
        case loadClips
        case addClips(items: [SavedClip])
        case removeClip(SavedClip)
        case selectClip(index: Int)
        case deselectClip(index: Int)
        case selectAllClips
        case deselectAllClips
        case removeSelectedClips
        case toggleEditMode
        case exportClip(SavedClip)
    }

    enum Command: CommandType {
        case loadClips(completion: ([SavedClip]) -> Void)
        case showClip(index: Int)
        case removeClip(SavedClip)
        case removeSelectedClips([SavedClip])
        case exportClip(SavedClip)
    }

    var store: Store<Action, State, Command>!

    lazy var reducer: (State, Action) -> (state: State, command: Command?) = { [weak self] (state: State, action: Action) in
        var state = state
        var command: Command? = nil

        switch action {
        case .loadClips:
            command = Command.loadClips(completion: { (clips) in
                self?.store.dispatch(.addClips(items: clips))
            })
        case .addClips(let items):
            state.dataSource = HNAlbumViewControllerDataSource(clips: items, owner: self)
            if !state.canToggleEditMode && state.isEditing {
                state.isEditing = false
            }
            state.indexesOfSelectedClips.removeAll()
        case .removeClip(let clip):
            command = Command.removeClip(clip)
        case .removeSelectedClips:
            let selectedClips = state.indexesOfSelectedClips.map{state.dataSource.clips[$0]}
            command = Command.removeSelectedClips(selectedClips)
        case .toggleEditMode:
            state.isEditing = !state.isEditing
            state.indexesOfSelectedClips.removeAll()
        case .selectClip(let index):
            if state.isEditing {
                state.indexesOfSelectedClips.append(index)
            } else {
                command = Command.showClip(index: index)
            }
        case .deselectClip(let index):
            if state.isEditing {
                if let i = state.indexesOfSelectedClips.firstIndex(of: index) {
                    // If has selected, then deselect.
                    state.indexesOfSelectedClips.remove(at: i)
                }
            }
        case .selectAllClips:
            state.indexesOfSelectedClips = Array(0..<state.dataSource.clips.count)
        case .deselectAllClips:
            state.indexesOfSelectedClips.removeAll()
        case .exportClip(let clip):
            command = Command.exportClip(clip)
        }
        return (state, command)
    }

    private lazy var batchDeleteButton: UIButton = { [weak self] in
        let batchDeleteButton = UIButton(type: .custom)
        batchDeleteButton.setTitleColor(.white, for: .normal)
        batchDeleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 10.0)
        batchDeleteButton.setBackgroundImageColor(UIColor.semanticColor(.background(.tertiary)), disabledColor: UIColor.semanticColor(.background(.quaternary)))
        batchDeleteButton.addTarget(self, action: #selector(batchDeleteButtonTapped(_:)), for: .touchUpInside)
        return batchDeleteButton
    }()

    private var navBarSelectButtonItem: UIBarButtonItem!
    private var navBarSelectAllButtonItem: UIBarButtonItem!

    @IBOutlet private weak var countLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        title = NSLocalizedString("Album", comment: "Album")
        navigationController?.tabBarItem.title = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.allowsMultipleSelectionDuringEditing = true

        navBarSelectButtonItem = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(selectButtonTapped(_:)))
        navigationItem.rightBarButtonItem = navBarSelectButtonItem

        navBarSelectAllButtonItem = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(selectAllButtonTapped(_:)))

        let dataSource = HNAlbumViewControllerDataSource(clips: [], owner: self)
        store = Store<Action, State, Command>(reducer: reducer, initialState: State(dataSource: dataSource, isEditing: false, indexesOfSelectedClips: []))

        store.subscribe { [weak self] (state, previousState, command) in
            self?.stateDidChanged(state: state, previousState: previousState, command: command)
        }

        // 初始化UI
        stateDidChanged(state: store.state, previousState: nil, command: nil)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        SavedClipManager.shared.delegate = self
        store.dispatch(.loadClips)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        SavedClipManager.shared.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        batchDeleteButton.frame.size.width = view.frame.width
    }

    override func applyTheme() {
        super.applyTheme()

        if store != nil, store.state.dataSource.clips.isEmpty {
            view.backgroundColor = UIColor.semanticColor(.background(.secondary))
        } else {
            view.backgroundColor = UIColor.semanticColor(.background(.primary))
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        if isEditing != editing {
            super.setEditing(editing, animated: animated)

            updateSelectAllBarButton()
            updateBarButtons(animated)

            if editing {
                let batchDeleteButtonSize: CGSize

                if navigationController?.viewControllers.first == self {
                    batchDeleteButtonSize = UITabBar().sizeThatFits(view.frame.size)
                } else {
                    batchDeleteButtonSize = UIToolbar().sizeThatFits(view.frame.size)
                }

                batchDeleteButton.frame = CGRect(x: 0.0, y: 0.0, width: batchDeleteButtonSize.width, height: batchDeleteButtonSize.height)
                batchDeleteButton.isEnabled = false
                batchDeleteButton.alpha = 0.0
                batchDeleteButton.set(image: #imageLiteral(resourceName: "btn_delete_n"), title: NSLocalizedString("Delete", comment: "Delete"), titlePosition: UIButton.Position.bottom, additionalSpacing: 0.0, state: UIControl.State.normal)

                if navigationController?.viewControllers.first == self {
                    tabBarController?.tabBar.addSubview(batchDeleteButton)
                    tabBarController?.tabBar.isUserInteractionEnabled = false
                } else {
                    navigationController?.toolbar.setItems([], animated: false) // tricky code, make navigationController.toolbar can respond to user‘s touch When it first appeared

                    navigationController?.toolbar.addSubview(batchDeleteButton)
                    navigationController?.setToolbarHidden(false, animated: true)
                }
            } else {
                if navigationController?.viewControllers.first == self {
                    tabBarController?.tabBar.isUserInteractionEnabled = true
                }
            }

            if editing {
                if animated {
                    UIView.transition(with: batchDeleteButton, duration: TimeInterval(UINavigationController.hideShowBarDuration), options: [], animations: { [weak self] in
                        self?.batchDeleteButton.alpha = 1.0
                        }, completion: nil)
                } else {
                    batchDeleteButton.alpha = 1.0
                }
            } else {
                if animated {
                    if navigationController?.viewControllers.first != self {
                        navigationController?.setToolbarHidden(true, animated: true)
                    }

                    UIView.transition(with: batchDeleteButton, duration: TimeInterval(UINavigationController.hideShowBarDuration), options: [], animations: { [weak self] in
                        self?.batchDeleteButton.alpha = 0.0
                        }, completion: { [weak self] _ in
                            self?.batchDeleteButton.removeFromSuperview()
                    })
                } else {
                    batchDeleteButton.alpha = 0.0
                    batchDeleteButton.removeFromSuperview()

                    if navigationController?.viewControllers.first != self {
                        navigationController?.setToolbarHidden(true, animated: false)
                    }
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        store.dispatch(.selectClip(index: indexPath.row))
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        store.dispatch(.deselectClip(index: indexPath.row))
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
        case .loadClips(let handler):
            handler(SavedClipManager.shared.validClips)
        case .showClip(let index):
            let clip = store.state.dataSource.clips[index]
            let detailVC = LibraryDetailViewController.createViewController()
            if #available(iOS 13.0, *) {
                detailVC.modalPresentationStyle = .fullScreen
            }
            detailVC.clip = clip

            if #available(iOS 13.0, *) {
                detailVC.modalPresentationStyle = .fullScreen
            }

            present(detailVC, animated: true, completion: nil)
        case .removeClip(let clip):
            presentDeleteClipSheet(
                title: NSLocalizedString("The video will be deleted from your phone's storage", comment: "The video will be deleted from your phone's storage"),
                deleteHandler: {[weak self] in
                MixpanelHelper.track(event: "Delete album video on list")
                SavedClipManager.shared.removeClip(clip)
                self?.store.dispatch(.loadClips)
            })
        case .removeSelectedClips(let selectedClips):
            presentDeleteClipSheet(
                title: NSLocalizedString("The video(s) will be deleted from your phone's storage", comment: "The video(s) will be deleted from your phone's storage"),
                deleteHandler: { [weak self] in
                MixpanelHelper.track(event: "Batch delete album video(s) on list")
                selectedClips.forEach({ (clip) in
                    SavedClipManager.shared.removeClip(clip)
                })
                self?.store.dispatch(.loadClips)
            })
        case .exportClip(let clip):
            presentExportClipSheet(EditableClip(clip), camera: nil, streamIndex: clip.streamIndex)
        }
    }

    private func updateUI(from previousState: State?, to state: State) {
        if previousState == nil || previousState?.dataSource != state.dataSource {
            let dataSource = state.dataSource
            tableView.dataSource = dataSource
            tableView.reloadData()

            updateBarButtons(previousState == nil ? false : true)

            if dataSource.clips.isEmpty {
                showEmptyView(image: #imageLiteral(resourceName: "icon_album"), title: NSLocalizedString("No Videos", comment: "No Videos"), detail: NSLocalizedString("Exported videos will be here", comment: "Exported videos will be here"))
                countLabel.isHidden = true
            } else {
                countLabel.isHidden = false
                hideEmptyView()
            }

            applyTheme()
        }

        if previousState == nil || previousState?.isEditing != state.isEditing {
            if previousState == nil {
                updateSelectAllBarButton()
                updateBarButtons(false)
            }

            setEditing(state.isEditing, animated: true)
            tableView.allowsMultipleSelection = state.isEditing
        }

        if previousState == nil || previousState?.indexesOfSelectedClips != state.indexesOfSelectedClips {
            // Clear selections.
            tableView.indexPathsForSelectedRows?.forEach({ (indexPath) in
                tableView.deselectRow(at: indexPath, animated: false)
            })

            state.indexesOfSelectedClips.forEach { (index) in
                tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
            }

            if state.isEditing {
                updateSelectAllBarButton()

                batchDeleteButton.isEnabled = !state.indexesOfSelectedClips.isEmpty
                tabBarController?.tabBar.isUserInteractionEnabled = batchDeleteButton.isEnabled
            }
        }

        if previousState?.isEditing != state.isEditing || previousState?.indexesOfSelectedClips != state.indexesOfSelectedClips || previousState?.dataSource != state.dataSource {
            if state.isEditing {
                let count = state.indexesOfSelectedClips.count
                let format: String = NSLocalizedString("selected videos count", comment: "selected videos count")
                countLabel.text = String.localizedStringWithFormat(format, count)
            } else {
                let count = state.dataSource.clips.count
                let format: String = NSLocalizedString("video count", comment: "video count")
                countLabel.text = String.localizedStringWithFormat(format, count)
            }
        }

    }

    private func updateSelectAllBarButton() {
        if isEditing {
            let state = store.state
            if state.isSelectedAllClips {
                navBarSelectAllButtonItem.title = NSLocalizedString("Deselect All", comment: "Deselect All")
            } else {
                navBarSelectAllButtonItem.title = NSLocalizedString("Select All", comment: "Select All")
            }
            navigationItem.setLeftBarButton(navBarSelectAllButtonItem, animated: false)
        } else {
            navigationItem.setLeftBarButton(nil, animated: false)
        }
    }

    private func updateBarButtons(_ animated: Bool) {
        var newTitle = NSLocalizedString("Select", comment: "Select")

        if isEditing {
            newTitle = NSLocalizedString("Cancel", comment: "Cancel")
        }

        if store.state.canToggleEditMode {
            navBarSelectButtonItem.isEnabled = true
        } else {
            newTitle = ""
            navBarSelectButtonItem.isEnabled = false
        }

        if navBarSelectButtonItem.title != newTitle {
            if animated {
                UIView.transition(with: navigationController!.navigationBar, duration: CATransaction.animationDuration(), options: [], animations: { [weak self] in
                    self?.navBarSelectButtonItem.title = newTitle
                    }, completion: nil)
            } else {
                navBarSelectButtonItem.title = newTitle
            }
        }
    }

    @objc private func selectAllButtonTapped(_ sender: UIButton) {
        if store.state.isSelectedAllClips {
            store.dispatch(.deselectAllClips)
        } else {
            store.dispatch(.selectAllClips)
        }
    }

    @objc private func selectButtonTapped(_ sender: UIButton) {
        store.dispatch(.toggleEditMode)
    }

    @objc private func batchDeleteButtonTapped(_ sender: UIButton) {
        store.dispatch(.removeSelectedClips)
    }
}

extension HNAlbumViewController: AlbumVideoCellDelegate {

    func onDelete(clip: SavedClip) {
        store.dispatch(.removeClip(clip))
    }
    
    func onExport(clip: SavedClip) {
        store.dispatch(.exportClip(clip))
    }
    
}

extension HNAlbumViewController: SavedClipManagerDelegate {
    func clipListDidReload() {
        store.dispatch(.loadClips)
    }
    
    func clipDidUpdate(_ clip: SavedClip) {
        store.dispatch(.loadClips)
    }
}

final class HNAlbumViewControllerDataSource: NSObject, UITableViewDataSource {
    private weak var owner: HNAlbumViewController?
    private(set) var clips: [SavedClip] = []

    init(clips: [SavedClip], owner: HNAlbumViewController?) {
        self.clips = clips
        self.owner = owner
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clips.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumVideoCell", for: indexPath) as! AlbumVideoCell
        let clip = clips[indexPath.row]
        cell.clip = clip
        cell.delegate = owner
        return cell
    }

}
