//
//  TripDetailTimelineViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 12/30/21.
//  Copyright © 2021 waylens. All rights reserved.
//

import UIKit
import YNDropDownMenu
import ExpandableCell
import WaylensFoundation

struct ExpandableTrips {
    var isExpanded: Bool
    let trip : Trip
    var events : [Event]
}
class TripDetailTimelineViewController: BaseViewController {
    
    let idTripCell = "TripCell"
    let idTripDetailTimeLineTableViewCell = "TripDetailTimeLineTableViewCell"
    
    @IBOutlet weak var viewTopHeader: UIView!
    
    @IBOutlet weak var viewCall: UIView!
    @IBOutlet weak var plateLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var hourLable: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var viewGoDetail: UIView!
    @IBOutlet weak var viewLiveStream: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calendarViewContainer: UIView!
    var date = ""
    var cameraSn : String = ""
    var name : String = ""
    var isNeedReload = false
    let api : FleetViewAPI = FleetViewService()
    let apiVideo : EventAPI = EventService()
    var allItems = [ ExpandableTrips]()
    var driver : Driver!
    var heightRow = 120
    var hiddenSections = Set<Int>()
    
    func getExpandable(_ items : [Trip]) {
        updateData(items)
        for trip in items {
            let list = ExpandableTrips(isExpanded: false, trip: trip, events: [])
            allItems.append(list)
            tableView.reloadData()
        }
    }
    deinit {
        debugPrint("\(self) deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    func setBorderView(view : UIView) {
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyTheme()
        setBorderView(view: viewTopHeader)
        title = "Go Detail".localizeMk()
        self.dateLabel.text = Date().toString(format: .custom("dd/MM/yyyy"))
        self.date = Date().toString(format: .isoDate)
        tableView.register(UINib(nibName: idTripCell, bundle: nil), forCellReuseIdentifier: idTripCell)
        tableView.register(UINib(nibName: idTripDetailTimeLineTableViewCell, bundle: nil), forCellReuseIdentifier: idTripDetailTimeLineTableViewCell)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTripsWithObs(_:)), name: Notification.Name(rawValue: "reload_trips"), object: nil)
        self.viewGoDetail.addTapGesture {
            self.goDetailButtonTapped()
        }
        self.viewLiveStream.addTapGesture {
            self.goLiveButtonTapped()
        }
        self.calendarViewContainer.addTapGesture {
            self.showCalender()
        }
        getTrips(date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isNeedReload {
            isNeedReload = false
            reloadTripsWithCurrentDateSelected()
        }
        tableView.setPullRefreshAction(self, refreshAction: #selector(reloadTrips))
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func reloadTripsWithObs(_ noti: Notification){
        isNeedReload = true
    }
    
    @objc func reloadTripsWithCurrentDateSelected(){
        self.allItems.removeAll()
        getTrips(self.date)
        tableView.mj_header?.endRefreshing()
    }
    
    @objc func reloadTrips(){
        self.dateLabel.text = Date().toString(format: .isoDate)
        self.date = Date().toString(format: .isoDate)
        self.datePicker.date = Date()
        self.allItems.removeAll()
        
        getTrips(self.date)
        tableView.mj_header?.endRefreshing()
    }
    
    private lazy var datePicker : UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.autoresizingMask = .flexibleWidth
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        datePicker .backgroundColor = .white
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var toolBar : UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.onDoneClicked))]
        toolBar.sizeToFit()
        return toolBar
    }()
    
    private func addDatePicker() {
        self.view.addSubview(self.datePicker)
        self.view.addSubview(self.toolBar)
        NSLayoutConstraint.activate([
            self.datePicker.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.datePicker.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.datePicker.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.datePicker.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        NSLayoutConstraint.activate([
            self.toolBar.bottomAnchor.constraint(equalTo: self.datePicker.topAnchor),
            self.toolBar.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.toolBar.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.toolBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func onDoneClicked() {
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
    }
    
    @objc private func dateChanged(picker : UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let date = picker.date
        self.dateLabel.text = date.toString(format: .custom("dd/MM/yyyy"))
        self.date = date.toString(format: .isoDate)
        self.allItems.removeAll()
        onDoneButtonClick()
    }
    
    func showCalender() {
        self.addDatePicker()
    }
    
    @objc func onDoneButtonClick() {
        getTrips(self.date)
        toolBar.removeFromSuperview()
        datePicker.removeFromSuperview()
    }
    
    func goDetailButtonTapped() {
        if let phoneCallURL = URL(string: "tel://\(self.driver.statistics.phoneNo)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    func goLiveButtonTapped() {
        let liveVC = OverviewLiveViewController(driver: driver)
        AppViewControllerManager.topViewController?.navigationController?.pushViewController(liveVC, animated: true)
    }
    
    func setFontButton(button : UIButton) {
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 8)
        button.setTitleColor(UIColor.color(fromHex: ConstantMK.grayLabel), for: .normal)
    }
    func setTextButtonLocalized(button : UIButton , text : String) {
        button.titleLabel?.text = NSLocalizedString(text, comment: text)
    }
    
    func setFontLabel(label : UILabel) {
        label.font = UIFont(name: SF_FONT_BOLD, size: 13)
        label.textColor = UIColor.color(fromHex: ConstantMK.grayLabel)
    }
    func setTextLabelLocalized(label : UILabel , text : String) {
        label.text = NSLocalizedString(text, comment: text)
    }
    
    override func applyTheme() {
        super.applyTheme()
        self.view.backgroundColor = UIColor.semanticColor(SemanticColor.cardBackground)
        setBorderView(view: self.viewGoDetail)
        setBorderView(view: self.viewLiveStream)
        setBorderView(view: self.calendarViewContainer)
        plateLabel.text = driver.vehicle.plateNumber
        labelName.text = self.name
        self.viewContent.backgroundColor = UIColor.color(fromHex: ConstantMK.bg_main_color)
        self.viewGoDetail.layer.borderColor = UIColor.color(fromHex: "#165FCE").cgColor
    }
    
    func updateData(_ trips: [Trip]){
        var mileages = 0
        var eventCounts = 0
        var hours: Double = 0
        for trip in trips {
            mileages = mileages + (trip.distance ?? 0)
            eventCounts = eventCounts + (trip.eventCount ?? 0)
            hours = hours + (trip.hours ?? 0.0)
        }
        self.hourLable.text = "\(hours.format())"
        self.eventLabel.text = "\(mileages)"
        self.mileageLabel.text = "\(eventCounts)"
    }
    
    func getTrips(_ date : String) {
        print("getTrips date",date)
        self.showProgress()
        api.trips(cameraSn: self.cameraSn, searchDate: date, completion: { [weak self] (result) in
            self?.hideProgress()
            switch result {
            case .success(let dict):
                if let data = dict["data"] as? [JSON] {
                    if let tripData = try? JSONSerialization.data(withJSONObject: data, options: []){
                        do {
                            let trips = try JSONDecoder().decode([Trip].self, from: tripData).sorted(by: {$0.id! < $1.id!})
                            if trips.isEmpty {
                                self?.tableView.reloadData()
                            } else {
                                self?.getExpandable(trips)
                            }
                        } catch let err {
                            print("err get trips",err)
                        }
                    }
                }
                break
            case .failure(let err):
                self?.alert(message: err?.localizedDescription ?? NSLocalizedString("Failed to apply settings, please check network connection.", comment: "Failed to apply settings, please check network connection."))
                break
            }
        })
    }
    
    func getEvents(trip : Trip) {
        guard let tripId = trip.tripId else { return  }
        api.eventsOneTrip(tripId: tripId, completion: { [weak self] (result) in
            switch result {
            case .success(let dict):
                if let data = dict["data"] as? [JSON] {
                    if let eventData = try? JSONSerialization.data(withJSONObject: data, options: []),
                       let events = try? JSONDecoder().decode([Event].self, from: eventData).sorted(by: {$1.createTimeToDate().compare($0.createTimeToDate()) == .orderedDescending}) {
                        let expandableTrip = ExpandableTrips(isExpanded: false, trip: trip, events: events)
                        self?.allItems.append(expandableTrip)
                        self?.allItems = (self?.allItems.sorted(by: {$0.trip.drivingTimeToDate().timeIntervalSince1970 < $1.trip.drivingTimeToDate().timeIntervalSince1970}))!
                        self?.tableView.reloadData()
                        
                        print("LengOfList: \(self?.allItems.count ?? 0)")
                    }
                }
                break
            case .failure(let err):
                self?.alert(message: err?.localizedDescription ?? NSLocalizedString("Failed to apply settings, please check network connection.", comment: "Failed to apply settings, please check network connection."))
                break
            }
        })
    }
    
    func getEventbyTrip(trip : Trip , completion : @escaping ([Event]) -> () )   {
        self.showProgress()
        guard let tripId = trip.tripId else { return  }
        api.eventsOneTrip(tripId: tripId, completion: { [weak self] (result) in
            switch result {
            case .success(let dict):
                if let data = dict["data"] as? [JSON] {
                    if let eventData = try? JSONSerialization.data(withJSONObject: data, options: []),
                       let events = try? JSONDecoder().decode([Event].self, from: eventData) {
                        completion(events)
                    }
                }
                break
            case .failure(let err):
                self?.alert(message: err?.localizedDescription ?? NSLocalizedString("Failed to apply settings, please check network connection.", comment: "Failed to apply settings, please check network connection."))
                break
            }
        })
    }
}

extension TripDetailTimelineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.allItems[section].isExpanded {
            return 2
        } else {
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let model = allItems[indexPath.section].trip
            let cellTrip = tableView.dequeueReusableCell(withIdentifier: idTripCell, for: indexPath) as! TripCell
            cellTrip.config(model)
            cellTrip.setBorderWithExpanded(isExpanded: indexPath.row <= self.allItems.count ? self.allItems[indexPath.row].isExpanded : false)
            return cellTrip
        } else {
            let cellEvent = tableView.dequeueReusableCell(withIdentifier: idTripDetailTimeLineTableViewCell, for: indexPath) as! TripDetailTimeLineTableViewCell
            cellEvent.delegate = self
            cellEvent.config(items: allItems[indexPath.section].events, trip: allItems[indexPath.section].trip, driver: self.driver)
            return cellEvent
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if allItems[indexPath.section].isExpanded {
            allItems[indexPath.section].isExpanded = false
            let sections = IndexSet.init(integer: indexPath.section)
            self.tableView.reloadSections(sections, with: .automatic)
        } else {
            getEventbyTrip(trip: allItems[indexPath.section].trip, completion: {events in
                self.allItems[indexPath.section].events = events
                self.allItems[indexPath.section].isExpanded = true
                let sections = IndexSet.init(integer: indexPath.section)
                self.tableView.reloadSections(sections, with: .automatic)
                self.hideProgress()
            })
        }
    }
    
}

extension TripDetailTimelineViewController : EventVideoPlayDelegate {
    
    func playVideo(url: String, event: Event?) {
        let vc = PlayVideoEventViewController(url: url, eventModel: event)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func playVideoErr(errMsg: String) {
        self.alert(message: errMsg)
    }
    
    func showLoading(_ show: Bool) {
        if show {
            self.showProgress()
        } else {
            self.hideProgress()
        }
    }
}

extension Double {
    func format() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        let number = NSNumber(value: self)
        let formattedValue = (formatter.string(from: number) ?? "0").replacingOccurrences(of: ",", with: ".")
        return formattedValue
    }
}
