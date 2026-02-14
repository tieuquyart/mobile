//
//  PlayVideoEventViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 1/4/22.
//  Copyright © 2022 waylens. All rights reserved.
//


import UIKit

class PlayVideoEventViewController: OverviewPlayerViewController<EventDetailHeaderView> {

    private var videoURL : String?
    private var event: Event?
    private var notiItem: NotiItem?
    private var isNoti : Bool
    private var longitude : Double = 0;
    private var latitude : Double = 0;
   

    init(url: String, eventModel: Event?) {
        self.videoURL = url
        self.event = eventModel
        self.isNoti = false
        super.init()
    }
    
    init(notiBean: NotiItem){
        self.notiItem = notiBean
        self.isNoti = true
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func exportClip() {
        if self.isNoti {
            let clip = EditableClip(HNClip(notiItem: notiItem!))
            presentExportClipSheet(clip, camera: nil, streamIndex: 0)
        }else{
            event?.url = videoURL ?? ""
            let clip = EditableClip(HNClip(event: event!))
            presentExportClipSheet(clip, camera: nil, streamIndex: 0)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let title = self.isNoti ? notiItem?.eventType?.description : event?.eventType?.description
        
        initHeader(text: title ?? "", leftButton: true)
        
        headerView.cloruseExportClip = { [weak self] in
            
            self?.exportClip()
        }
        
        
        if self.isNoti {
            headerView.update(with: notiItem!)
            playerPanel.duration = TimeInterval(notiItem?.clipDuration ?? 0)
            self.latitude = notiItem?.gpsLatitude ?? 0
            self.longitude = notiItem?.gpsLongitude ?? 0
            if let model = notiItem, model.markRead == false{
                readNotification(model)
            }
        }else{
            headerView.update(with: event!)
            playerPanel.duration = TimeInterval(event?.duration ?? 0)
            self.latitude = event?.gpsLatitude ?? 0
            self.longitude = event?.gpsLongitude ?? 0
        }
//        print("eventTypeStr \(event?.eventType?.toString()) - eventType.des \(event?.eventType?.description)")
       
        if self.longitude == 0 || self.latitude == 0 {
            self.alert(title: "Thông báo", message: "Không lấy được thông tin GPS")
        }
        
        print("event.gps \(latitude) - \(longitude)" )
        
        self.mapViewCustom.setMapView2(self.latitude, self.longitude, (self.isNoti ? notiItem?.eventType : event?.eventType)!, self)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        if !self.isNoti {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reload_trips"), object: nil,userInfo: nil)
        }else{
            NotificationCenter.default.post(name: Notification.Name.ReloadNotiList.reload, object: nil,userInfo: nil)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func readNotification(_ model: NotiItem) {
      
        NotificationServiceMK.shared.user_notification_read(notificationId: model.id!) { (result) in
            switch result {
            case .success(let value):
                print("mark read noti \(value)")
            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        playVideo()
    }

    override func createPlayerPanel() -> PlayerPanel {
        let playerPanel = PlayerPanelCreator.createEventDetailPlayerPanel()
        playerPanel.playSource = .remotePlayback
        return playerPanel
    }

    override func createHeaderView() -> EventDetailHeaderView {
        let header = EventDetailHeaderView.createFromNib()!
        return header
    }

    override func configActionButton(_ button: UIButton) {
        button.setTitle(NSLocalizedString("Export the Video", comment: "Export the Video"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.backgroundColor = UIColor.semanticColor(.tint(.primary))
        button.addTarget(self, action: #selector(actionButtonTapped(_:)), for: UIControl.Event.touchUpInside)
    }

    override func onPlay(_ play: Bool) {
        if play {
            playVideo()
        } else {
            playerPanel.stop()
        }
    }

}

//MARK: - Action

extension PlayVideoEventViewController {

    @objc private func actionButtonTapped(_ sender: UIButton) {
//        let clip = EditableClip(HNClip(event: event))
//       presentExportClipSheet(clip, camera: nil, streamIndex: 0)
    }

}


//MARK: - Private

extension PlayVideoEventViewController {

    private func playVideo() {
    
        if playerPanel.playState == .paused {
            playerPanel.resume()
        } else {
            playerPanel.playSource = .remotePlayback
            if self.isNoti {
                playerPanel.playVideo(self.notiItem?.url)
            }else{
                playerPanel.playVideo(self.videoURL)
            }
        }
    }

}


