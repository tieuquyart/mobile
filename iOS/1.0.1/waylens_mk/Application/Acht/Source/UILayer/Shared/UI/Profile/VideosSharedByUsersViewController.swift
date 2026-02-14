//
//  VideosSharedByUsersViewController.swift
//  Acht
//
//  Created by forkon on 2019/6/12.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import AVKit

class VideosSharedByUsersViewController: BaseTableViewController {

    private struct State: StateType {
        var dataSource: VideosSharedByUsersViewControllerDataSource
        var hasMore: Bool
        var isLoading: Bool
    }

    private enum Action: ActionType {
        case loadVideos
        case loadMoreVideos
        case addVideos(items: [VideoEntry], keepOldVideos: Bool, hasMore: Bool)
        case selectVideo(index: Int)
        case exportVideo(item: VideoEntry)
    }

    private enum Command: CommandType {
        case loadVideos(completion: ([VideoEntry], Bool) -> Void)
        case loadMoreVideos(completion: ([VideoEntry], Bool) -> Void)
        case handleSelectedVideo(item: VideoEntry, indexPath: IndexPath)
        case exportVideo(item: VideoEntry)
    }

    private var store: Store<Action, State, Command>!

    private lazy var reducer: (State, Action) -> (state: State, command: Command?) = { [weak self] (state: State, action: Action) in
        guard let strongSelf = self else {
            return (state, nil)
        }

        var state = state
        var command: Command? = nil

        switch action {
        case .loadVideos:
            command = Command.loadVideos(completion: { (videos, hasMore) in
                self?.store.dispatch(.addVideos(items: videos, keepOldVideos: false, hasMore: hasMore))
            })
        case .loadMoreVideos:
            command = Command.loadMoreVideos(completion: { (videos, hasMore) in
                self?.store.dispatch(.addVideos(items: videos, keepOldVideos: true, hasMore: hasMore))
            })
        case .addVideos(let items, let keepOldVideos, let hasMore):
            state.dataSource = VideosSharedByUsersViewControllerDataSource(videos: keepOldVideos ? state.dataSource.videos + items : items, owner: strongSelf)
            state.hasMore = hasMore
        case .selectVideo(let index):
            command = Command.handleSelectedVideo(item: state.dataSource.videos[index], indexPath: IndexPath(row: index, section: 0))
        case .exportVideo(let item):
            command = Command.exportVideo(item: item)
        }
        return (state, command)
    }

    private lazy var horizonClient = HorizonClient()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Videos Shared by Users", comment: "Videos Shared by Users")

        tableView.separatorInset = .zero
        setPullRefreshAction(#selector(didPullRefresh), loadMoreAction: #selector(didLoadMore))

        let dataSource = VideosSharedByUsersViewControllerDataSource(videos: [], owner: self)
        store = Store<Action, State, Command>(reducer: reducer, initialState: State(dataSource: dataSource, hasMore: false, isLoading: false))

        store.subscribe { [weak self] (state, previousState, command) in
            self?.stateDidChanged(state: state, previousState: previousState, command: command)
        }

        // 初始化UI
        stateDidChanged(state: store.state, previousState: nil, command: nil)

        tableView.mj_header?.beginRefreshing()
    }

    static func createViewController() -> VideosSharedByUsersViewController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "VideosSharedByUsersViewController")
        return vc as! VideosSharedByUsersViewController
    }

    fileprivate func exportVideo(_ video: VideoEntry) {
        store.dispatch(.exportVideo(item: video))
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
        case .loadVideos(let completion):
            horizonClient.fetchVideos { result in
                switch result {
                case .success((let videos, let hasMore)):
                    completion(videos, hasMore)
                case .failure(_):
                    completion([], false)
                }
            }
        case .loadMoreVideos(let completion):
            horizonClient.fetchVideos(store.state.dataSource.videos.count) { result in
                switch result {
                case .success((let videos, let hasMore)):
                    completion(videos, hasMore)
                case .failure(_):
                    completion([], false)
                }
            }
        case .handleSelectedVideo(let item, _):
            let detailVC = LibraryDetailViewController.createViewController()
            detailVC.clip = item.toSavedClip()

            if #available(iOS 13.0, *) {
                detailVC.modalPresentationStyle = .fullScreen
            }

            present(detailVC, animated: true, completion: nil)
        case .exportVideo(let item):
            let clip = EditableClip(item.toSavedClip())
            let vc = ExportSessionViewController.createViewController(clip: clip, camera: nil, streamIndex: 0, exportDestination: .photoLibrary)
            self.navigationController?.pushViewController(vc, animated: true)
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

            if state.dataSource.videos.isEmpty {
                showEmptyView(
                    image: #imageLiteral(resourceName: "icon_album"),
                    title: NSLocalizedString("No Video", comment: "No Video"),
                    detail: ""
                )
            } else {
                hideEmptyView()
            }
        }
    }

    @objc private func didPullRefresh() {
        store.dispatch(.loadVideos)
    }

    @objc private func didLoadMore() {
        store.dispatch(.loadMoreVideos)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        store.dispatch(.selectVideo(index: indexPath.row))
    }
}

private final class VideosSharedByUsersViewControllerDataSource: NSObject, UITableViewDataSource {
    private weak var owner: VideosSharedByUsersViewController?
    private(set) var videos: [VideoEntry] = []

    init(videos: [VideoEntry], owner: VideosSharedByUsersViewController) {
        self.videos = videos
        self.owner = owner
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell

        cell.cleanupCell()

        let video = videos[indexPath.row]
        cell.video = video
        cell.exportHandler = { [weak self] in
            self?.owner?.exportVideo(video)
        }
        return cell
    }
}

class VideoCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!

    weak var video: VideoEntry? {
        didSet {
            refreshUI()
        }
    }
    var exportHandler: (() -> Void)?

    override func setSelected(_ selected: Bool, animated: Bool) {
        let bgColor = thumbnailImageView.backgroundColor
        super.setSelected(selected, animated: animated)
        thumbnailImageView.backgroundColor = bgColor
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let bgColor = thumbnailImageView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        thumbnailImageView.backgroundColor = bgColor
    }

    @IBAction func exportButtonTapped(_ sender: Any) {
        exportHandler?()
    }

    func cleanupCell() {
        titleLabel.text = nil
        thumbnailImageView.image = nil
    }

    private func refreshUI() {
        guard let video = video else {
            cleanupCell()
            return
        }

        titleLabel.text = video.title

        if let thumbnailURL = video.thumbnailURL {
            thumbnailImageView.hn_setImage(url: thumbnailURL, facedown: false, dewarp: true)
        } else {
            thumbnailImageView.image = nil
        }
    }

}

class VideoEntry: Decodable {
    var videoURL: URL?
    let id: Int64
    let title: String
    let thumbnailURL: URL?
    let duration: TimeInterval
    let createTime: TimeInterval

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case thumbnailURL = "thumbnail"
        case duration
        case createTime
    }

    required init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        id = try vals.decode(Int64.self, forKey: .id)
        title = try vals.decode(String.self, forKey: .title)
        thumbnailURL = URL(string: (try? vals.decode(String.self, forKey: .thumbnailURL)) ?? "")
        duration = try vals.decode(TimeInterval.self, forKey: .duration)
        createTime = try vals.decode(TimeInterval.self, forKey: .createTime)
    }

    func toSavedClip() -> SavedClip {
        let clipDict: [String : Any] = [
            "clipID": id,
            "url": videoURL?.absoluteString ?? "",
            "mediaType": "video",
            "thumbnailUrl": thumbnailURL?.absoluteString ?? "",
            "durationMs": duration,
            "captureTime": createTime
        ]
        return SavedClip(dict: clipDict)
    }

}
