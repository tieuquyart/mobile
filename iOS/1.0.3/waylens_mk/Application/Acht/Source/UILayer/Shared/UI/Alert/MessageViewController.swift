//
//  MessageViewController.swift
//  Acht
//
//  Created by forkon on 2019/3/12.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
#if useMixpanel
import Mixpanel
#endif
import WaylensFoundation

class MessageViewController: BaseTableViewController {

    private struct State: StateType {
        var dataSource: MessageViewControllerDataSource
        var hasMore: Bool
        var isLoading: Bool
    }

    private enum Action: ActionType {
        case loadMessages
        case loadMoreMessages
        case addMessages(items: [Message], keepOldMessages: Bool, hasMore: Bool)
        case selectMessage(index: Int)
        case popToPreviousViewController
    }

    private enum Command: CommandType {
        case loadMessages(completion: ([Message], Bool) -> Void)
        case loadMoreMessages(completion: ([Message], Bool) -> Void)
        case handleMessage(item: Message, indexPath: IndexPath)
        case markAllNotificationsRead
    }

    private var store: Store<Action, State, Command>!

    private lazy var reducer: (State, Action) -> (state: State, command: Command?) = { [weak self] (state: State, action: Action) in
        var state = state
        var command: Command? = nil

        switch action {
        case .loadMessages:
            command = Command.loadMessages(completion: { (messages, hasMore) in
                self?.store.dispatch(.addMessages(items: messages, keepOldMessages: false, hasMore: hasMore))
            })
        case .loadMoreMessages:
            command = Command.loadMoreMessages(completion: { (messages, hasMore) in
                self?.store.dispatch(.addMessages(items: messages, keepOldMessages: true, hasMore: hasMore))
            })
        case .addMessages(let items, let keepOldMessages, let hasMore):
            state.dataSource = MessageViewControllerDataSource(messages: keepOldMessages ? state.dataSource.messages + items : items, owner: self)
            state.hasMore = hasMore

            if let selectedMessageID = self?.selectedMessageID, !state.dataSource.messages.isEmpty {
                if let selectedIndex = state.dataSource.messages.firstIndex(where: {$0.id == selectedMessageID}) {
                    command = Command.handleMessage(item: state.dataSource.messages[selectedIndex], indexPath: IndexPath(row: selectedIndex, section: 0))
                }
                self?.selectedMessageID = nil
            }
        case .selectMessage(let index):
            command = Command.handleMessage(item: state.dataSource.messages[index], indexPath: IndexPath(row: index, section: 0))
        case .popToPreviousViewController:
            command = Command.markAllNotificationsRead
        }
        return (state, command)
    }

    var selectedMessageID: Int64? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Message", comment: "Message")

        setPullRefreshAction(#selector(didPullRefresh), loadMoreAction: #selector(didLoadMore))
        tableView.separatorInset = .zero

        let dataSource = MessageViewControllerDataSource(messages: [], owner: self)
        store = Store<Action, State, Command>(reducer: reducer, initialState: State(dataSource: dataSource, hasMore: false, isLoading: false))

        store.subscribe { [weak self] (state, previousState, command) in
            self?.stateDidChanged(state: state, previousState: previousState, command: command)
        }

        // 初始化UI
        stateDidChanged(state: store.state, previousState: nil, command: nil)

        tableView.mj_header?.beginRefreshing()

        MixpanelHelper.track(event: "Enter Message Page")
    }

    static func createViewController() -> MessageViewController {
        let vc = UIStoryboard(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "MessageViewController")
        return vc as! MessageViewController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)

        if parent == nil { // will be popped
            store.dispatch(.popToPreviousViewController)
        }
    }

    private func stateDidChanged(state: State, previousState: State?, command: Command?) {
        updateUI(from: previousState, to: state)
        executeCommand(command)
    }

    private func executeCommand(_ command: Command?) {
        guard let command = command else {
            return
        }

        switch command {
        case .loadMessages(let completion):
            WaylensClientS.shared.fetchNotifications { (result) in
                switch result {
                case .success(let resultDict):
                    let messageDicts = resultDict["notifications"] as? [[String : Any]]
                    let hasMore = (resultDict["hasMore"] as? Bool) ?? false

                    let messages: [Message] = messageDicts?.compactMap({ (messageDict) -> Message? in
                        do {
                            let messageJsonData = try JSONSerialization.data(withJSONObject: messageDict, options: [])
                            let message = try JSONDecoder().decode(Message.self, from: messageJsonData)
                            return message
                        } catch {
                            Log.error("parse message error: \(error)")
                            return nil
                        }
                    }) ?? []

                    completion(messages, hasMore)
                case .failure(let error):
                    Log.error("fetch messages error: \(String(describing: error))")
                    completion([], false)
                }
            }
        case .loadMoreMessages(let completion):
            WaylensClientS.shared.fetchNotifications(cursor: store.state.dataSource.messages.count) { (result) in
                switch result {
                case .success(let resultDict):
                    let messageDicts = resultDict["notifications"] as? [[String : Any]]
                    let hasMore = (resultDict["hasMore"] as? Bool) ?? false

                    let messages: [Message] = messageDicts?.compactMap({ (messageDict) -> Message? in
                        do {
                            let messageJsonData = try JSONSerialization.data(withJSONObject: messageDict, options: [])
                            let message = try JSONDecoder().decode(Message.self, from: messageJsonData)
                            return message
                        } catch {
                            Log.error("parse message error: \(error)")
                            return nil
                        }
                    }) ?? []

                    completion(messages, hasMore)
                case .failure(let error):
                    Log.error("fetch messages error: \(String(describing: error))")
                    completion([], true)
                }
            }
        case .handleMessage(let item, let indexPath):
            if !item.isRead {
                item.isRead = true
                tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                WaylensClientS.shared.markNotificationRead(item.id, completion: nil)
            }

            switch item.type {
            case .dataUsage:
                if let cameraSN = item.cameraSN {
                    presentDataPlanViewController(forCamera: cameraSN)
                }
            case .dataPlan:
                if let cameraSN = item.cameraSN {
                    presentDataPlanViewController(forCamera: cameraSN)
                }
            case .onlineStatus:
                break
            case .appVersion:
                UIApplication.shared.open(URL(string: "https://itunes.apple.com/us/app/id1254026388")!, options: [:], completionHandler: nil)
            case .firmware:
                if let camera = UnifiedCameraManager.shared.cameras.first {
                    showFirmwareViewController(for: camera)
                } else {
                    alertCameraWiFiConnectionMessage()
                }
            case .general:
                if let url = item.link {
                    openBrowser(withURL: url)
                }
            default:
                break
            }

            tableView.deselectRow(at: indexPath, animated: true)
        case .markAllNotificationsRead:
            WaylensClientS.shared.markAllNotificationsRead { (result) in

            }
        }
    }

    private func updateUI(from previousState: State?, to state: State) {
        if previousState == nil || state.dataSource != previousState?.dataSource {
            if tableView.mj_header!.isRefreshing {
                tableView.mj_header?.endRefreshing()
            }

            if state.hasMore {
                tableView.mj_footer?.endRefreshing()
            } else {
                tableView.mj_footer?.endRefreshingWithNoMoreData()
            }

            tableView.dataSource = state.dataSource
            tableView.reloadData()

            if state.dataSource.messages.isEmpty {
                showEmptyView(
                    image: #imageLiteral(resourceName: "message_empty"),
                    title: NSLocalizedString("No Message", comment: "No Message"),
                    detail: NSLocalizedString("Nothing to Report", comment: "Nothing to Report")
                )
            } else {
                hideEmptyView()
            }
        }
    }

    @objc private func didPullRefresh() {
        store.dispatch(.loadMessages)
    }

    @objc private func didLoadMore() {
        store.dispatch(.loadMoreMessages)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        store.dispatch(.selectMessage(index: indexPath.row))
    }
}

private final class MessageViewControllerDataSource: NSObject, UITableViewDataSource {
    private weak var owner: MessageViewController?
    private(set) var messages: [Message] = []

    init(messages: [Message], owner: MessageViewController?) {
        self.messages = messages
        self.owner = owner
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
}

class MessageCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customDetailTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var customImageView: UIImageView!

    weak var message: Message? {
        didSet {
            refreshUI()
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let customImageViewBackgroundColor = customImageView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        customImageView.backgroundColor = customImageViewBackgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let customImageViewBackgroundColor = customImageView.backgroundColor
        super.setSelected(selected, animated: animated)
        customImageView.backgroundColor = customImageViewBackgroundColor
    }

    private func refreshUI() {
        guard let message = message else {
            cleanupCell()
            return
        }

        titleLabel.text = message.title

        if message.isRead {
            titleLabel.font = UIFont(name: "BeVietnamPro-Semibold", size: 16)!
        } else {
            titleLabel.font = UIFont(name: "BeVietnamPro-Regular", size: 14)!
        }

        customDetailTextLabel.text = message.body
        timeLabel.text = Date(timeIntervalSince1970: message.createTime).toStringUsingInMessageCell()

        customImageView.image = nil
        if let imageURL = message.imageURL {
            customImageView.af_setImage(withURL: imageURL)
        }
    }

    private func cleanupCell() {
        titleLabel.text = nil
        customDetailTextLabel.text = nil
        timeLabel.text = nil
        customImageView.image = nil
    }

}

class Message: Decodable {
    enum MessageType {
        case dataUsage, dataPlan, onlineStatus, appVersion, firmware, general, unknown

        init(stringValue: String) {
            switch stringValue {
            case "DataUsage":
                self = .dataUsage
            case "DataPlan":
                self = .dataPlan
            case "OnlineStatus":
                self = .onlineStatus
            case "AppVersion":
                self = .appVersion
            case "Firmware":
                self = .firmware
            case "General":
                self = .general
            default:
                self = .unknown
            }
        }
    }

    let id: Int64
    let type: MessageType
    let cameraSN: String?
    let title: String
    let body: String
    let link: URL?
    let imageURL: URL?
    let createTime: TimeInterval
    var isRead: Bool

    enum CodingKeys: String, CodingKey {
        case id = "notificationID"
        case cameraSN
        case createTime
        case isRead
        case content
    }

    enum ContentKeys: String, CodingKey {
        case imageURL = "image"
        case link
        case type = "notificationType"
        case title
        case titleLocKey
        case titleLocArgs
        case body
        case bodyLocKey
        case bodyLocArgs
    }

    required init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        id = try vals.decode(Int64.self, forKey: .id)
        createTime = (try vals.decode(TimeInterval.self, forKey: .createTime)) / 1000
        isRead = try vals.decode(Bool.self, forKey: .isRead)
        cameraSN = try? vals.decode(String.self, forKey: .cameraSN)

        let content = try vals.nestedContainer(keyedBy: ContentKeys.self, forKey: .content)
        imageURL = URL(string: (try? content.decode(String.self, forKey: .imageURL)) ?? "")
        type = MessageType(stringValue: try content.decode(String.self, forKey: .type))

        var possibleLink: URL? = nil
        if var string = try? content.decode(String.self, forKey: .link), !string.isEmpty {
            string.addHttpSchemePrefixIfNeeded()

            if !string.isValidURL() {
                string = "http://www.waylens.com"
            }

            possibleLink = URL(string: string)
        }
        link = possibleLink

        var title = try content.decode(String.self, forKey: .title)
        let titleLocKey = try content.decode(String.self, forKey: .titleLocKey)
        let titleLocArgs = try content.decode([String].self, forKey: .titleLocArgs)
        if !titleLocKey.isEmpty {
            title = String(format: NSLocalizedString(titleLocKey, comment: ""), arguments: titleLocArgs)
        }
        self.title = title

        var body = try content.decode(String.self, forKey: .body)
        let bodyLocKey = try content.decode(String.self, forKey: .bodyLocKey)
        let bodyLocArgs = try content.decode([String].self, forKey: .bodyLocArgs)
        if !bodyLocKey.isEmpty {
            body = String(format: NSLocalizedString(bodyLocKey, comment: ""), arguments: bodyLocArgs)
        }
        self.body = body
    }

}
