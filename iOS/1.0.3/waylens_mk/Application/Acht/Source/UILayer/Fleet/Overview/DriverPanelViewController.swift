//
//  DriverPanelViewController.swift
//  Acht
//
//  Created by forkon on 2019/9/23.
//  Copyright © 2019 Maxim Bilan. All rights reserved.
//

import UIKit
import MapKit
import DifferenceKit


class DriverPanelViewController: MapFloatingSubPanelController {
    @IBOutlet weak var viewLine: UIView!
//    @IBOutlet weak var plateLabel: UILabel!
//    @IBOutlet weak var mileageLabel: UILabel!
//    @IBOutlet weak var durationLabel: UILabel!
//    @IBOutlet weak var eventLabel: UILabel!
//    @IBOutlet weak var labelName: UILabel!
//    @IBOutlet weak var iconStatusDrive : UIImageView!
    private var driver: Driver
    let api : FleetViewAPI = FleetViewService.shared
    var indexPathClicked : Int?
    @IBOutlet weak var collectionView: UICollectionView!
    var itemsTrip : [Trip] = []
    var itemsEvents: [Event] = []
    var currentTripSelected = ""
    @IBOutlet weak var lblNoTrips: UILabel!
    @IBOutlet weak var lblCurrentTrip: UILabel!
    @IBOutlet weak var btnDetail: UIButton!
    @IBOutlet weak var viewSharedTrip: UIView!
//    @IBOutlet weak var viewTopStack: UIView!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnLive: UIButton!
    init(driver: Driver) {
        self.driver = driver
        super.init(nibName: String(describing: DriverPanelViewController.self), bundle: nil)
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
        applyTheme()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        configCollectionView()
        fetchTrips()
    }
    
    func configCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "TripFleetDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TripFleetDetailCollectionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setBorderView(view : UIView) {
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
    }
    override func applyTheme() {
        super.applyTheme()
//        setBorderView(view: self.viewTopStack)
        self.btnDetail.layer.cornerRadius = 8
        self.btnDetail.layer.borderWidth = 1
        self.btnDetail.layer.borderColor = UIColor.color(fromHex: "#0B4296").cgColor
        self.btnLive.layer.cornerRadius = 8
    }
    
    @IBAction func shareTrip(_ sender: Any){
        if let url = URL(string: "https://fms.mkvision.com/#/trippl/" + self.currentTripSelected), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    @IBAction func onLive(_ sender: Any) {
        if let vip = UserSetting.current.userProfile?.isVip() {
            if vip {
                let liveVC = OverviewLiveViewController(driver: driver)
                AppViewControllerManager.topViewController?.navigationController?.pushViewController(liveVC, animated: true)
            } else {
                self.showToast(message: "Vui lòng nâng cấp tài khoản để sử dụng chức năng này!", seconds: 1)
                
            }
        } else {
            self.showToast(message: "Vui lòng nâng cấp tài khoản để sử dụng chức năng này!", seconds: 1)
        }
    }
    @IBAction func onDetail(_ sender: Any) {
        let driverDetailVC = TripDetailTimelineViewController(nibName: "TripDetailTimelineViewController", bundle: nil)
        driverDetailVC.driver = self.driver
        driverDetailVC.cameraSn = driver.vehicle.cameraSN
        driverDetailVC.name = driver.name
        AppViewControllerManager.topViewController?.navigationController?.pushViewController(driverDetailVC, animated: true)
    }
}

//MARK: - Private

extension DriverPanelViewController {
    
    private func updateUI() {
//        iconStatusDrive.image = UIImage(named: driver.vehicle.state == Vehicle.State.offline ?  "offline_small" : driver.vehicle.state == Vehicle.State.driving ?  "driving_small" : "parking_small")
        title = driver.vehicle.plateNumber
//        plateLabel.text = driver.vehicle.plateNumber
//        mileageLabel.text = driver.statistics.mileage.localeStringValue
//        eventLabel.text = "\(driver.statistics.eventCount)"
//        durationLabel.text = driver.statistics.duration.localeStringValue
        btnShare.isHidden = true
        btnShare.setTitle("", for: .normal)
        btnShare.tintColor = UIColor.color(fromHex: ConstantMK.bgTabar)
        
        applyTheme()
    }
}
//MARK: - Actions
extension DriverPanelViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width) / 4
        return CGSize(width: width, height: width - 30)
    }
}

extension DriverPanelViewController : UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemsTrip.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TripFleetDetailCollectionViewCell", for: indexPath) as!  TripFleetDetailCollectionViewCell
        let item = itemsTrip[indexPath.row]
        cell.configTrip(trip: item)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = itemsTrip[indexPath.row]
        item.isClicked = true
        itemsTrip[indexPath.row] = item
        if let indexPathOld = self.indexPathClicked {
            if indexPathOld != indexPath.row {
                self.delegate?.viewController(self, removeTrackFor: itemsTrip[indexPathOld])
                itemsTrip[indexPathOld].isClicked  = false
            } else {
                return
            }
        }
        self.updateTrack(for: itemsTrip[indexPath.row])
        self.fetchEventOneTrip(trip: itemsTrip[indexPath.row])
        indexPathClicked = indexPath.row
        self.collectionView.reloadData()
        
    }
}
extension DriverPanelViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let selectedEvent = (view.annotation as? EventAnnotation)?.event {
            
            let event = itemsEvents.first { (event) -> Bool in
                return event.id == selectedEvent.id
            }
            
            if let event = event {
                delegate?.viewController(self, showDetailOf: event)
            }
        }
    }
    
}
extension DriverPanelViewController {
    private func fetchEventOneTrip(trip : Trip) {
        api.eventsOneTrip(tripId: trip.tripId ?? "", completion:  { [weak self] (result) in
            switch result {
            case .success(let dict):
                if let data = dict["data"] as? [JSON] {
                    if let self = self {
                        if let eventData = try? JSONSerialization.data(withJSONObject: data, options: []),
                           let events = try? JSONDecoder().decode([Event].self, from: eventData){
                            self.itemsEvents = events
                            self.delegate?.viewController(self, dropPinsForEvents:  self.itemsEvents)
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
    
    private func updateTrack(for trip: Trip) {
        lblCurrentTrip.text = "Trip#\(trip.id ?? 0)"
        viewSharedTrip.isHidden = false
        api.track(cameraSn: driver.vehicle.cameraSN, tripId: trip.tripId ?? "", completion: { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let value):
                if let trackPoints = value["data"] as? [JSON] {
                    if trackPoints.isEmpty {
                        strongSelf.showToast(message: "Không có thông tin chuyến đi", seconds: 1)
                        self?.btnShare.isHidden = true
                        self?.currentTripSelected = ""
                    } else {
                        self?.btnShare.isHidden = false
                        self?.currentTripSelected = trip.tripId ?? ""
                        trip.updateTrack(with: trackPoints) {
                            strongSelf.delegate?.viewController(strongSelf, drawTrackFor: trip)
                        }
                    }
                }
            case .failure(_):
                break
            }
        })
    }
    private func fetchTrips() {
        let date = Date().toString(format: .isoDate)
        api.trips(cameraSn: driver.vehicle.cameraSN, searchDate: date, completion: { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let value):
                if let tripDicts = value["data"] as? [JSON] {
                    if let tripData = try? JSONSerialization.data(withJSONObject: tripDicts, options: []){
                        do {
                            let trips = try JSONDecoder().decode([Trip].self, from: tripData).sorted(by: {$0.id! > $1.id!})
                            strongSelf.itemsTrip = trips
                            if !trips.isEmpty {
                                if trips.count > 0 {
                                    strongSelf.collectionView(strongSelf.collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
                                }
                                strongSelf.lblNoTrips.isHidden = true
                                strongSelf.collectionView.isHidden = false
                                strongSelf.viewSharedTrip.isHidden = false
                                strongSelf.viewLine.isHidden = false
                            } else {
                                strongSelf.collectionView.isHidden = true
                                strongSelf.lblNoTrips.text = "No trips"
                                strongSelf.viewSharedTrip.isHidden = true
                                strongSelf.viewLine.isHidden = true
                            }
                            strongSelf.collectionView.reloadData()
                            
                        } catch let err {
                            print("err get trips",err)
                        }
                    }
                }
                
            case .failure(_):
                break
            }
            
        })
    }
}

extension UIColor {
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
