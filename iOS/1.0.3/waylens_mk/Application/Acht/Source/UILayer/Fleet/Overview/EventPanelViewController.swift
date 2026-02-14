//
//  EventDetailViewController.swift
//  Fleet
//
//  Created by forkon on 2019/9/25.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class EventPanelViewController: MapFloatingSubPanelController {

    private var event: Event
    private var dataSource: EventDetailDataSource!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var plateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playButton: UIButton!
    
    init(event: Event) {
        self.event = event
        super.init(nibName: "EventPanelViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = EventDetailDataSource(event: event)
        dataSource.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateUI()
        delegate?.viewController(self, dropPinsForEvents: [event])
    }

    override func applyTheme() {
        super.applyTheme()

        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                activityIndicator.style = .white
            }
            else {
                activityIndicator.style = .gray
            }
        }
    }

}

//MARK: - Private

extension EventPanelViewController {

    private func updateUI() {
        imageView.image = FleetResource.Image.iconNoShadow29x29(for: event.eventType!)
        nameLabel.text = event.eventType!.description
        plateLabel.text = event.plateNo
        addressLabel.text = ""

        dateLabel.text = (event.startTime!.toDate("yyyy-MM-dd'T'HH:mm:ss")?.date ?? Date()).dateManager.fleetDate.toStringUsingInNotificationList()

        if dateLabel.text != nil, let abbreviation = UserSetting.current.fleetTimeZone.abbreviation(){
            dateLabel.text = dateLabel.text! + " (\(abbreviation))"
        }

        if dataSource.isFetching {
            playButton.isHidden = true
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true

            if event.url == "" {
                playButton.isHidden = true
            } else if event.clipId != "" {
                playButton.isHidden = false
            }
        }
    }

}

//MARK: - Actions

extension EventPanelViewController {

    @IBAction func playButtonTapped(_ sender: Any) {
        let vc = EventDetailViewController(event: event)
        let navController = BaseNavigationController(rootViewController: vc)

        if #available(iOS 13.0, *) {
            navController.modalPresentationStyle = .fullScreen
        }

        AppViewControllerManager.topViewController?.present(navController, animated: true, completion: nil)
    }

}

extension EventPanelViewController: EventDetailDataSourceDelegate {

    func dataSource(_ eventDetailDataSource: EventDetailDataSource, didUpdate event: Event) {
        updateUI()
    }

}
