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
    @IBOutlet weak var plateLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var iconStatusDrive : UIImageView!
    
  //  private var dataSource: DriverDetailDataSource!
    private var driver: Driver

    let api : FleetViewAPI = FleetViewService.shared
    var indexPathClicked : Int?
    @IBOutlet weak var collectionView: UICollectionView!
    var itemsTrip : [Trip] = []
    var itemsEvents: [Event] = []
    var currentTripSelected = ""
    @IBOutlet weak var lblNoTrips: UILabel!
    @IBOutlet weak var lblCurrentTrip: UILabel!

    @IBOutlet weak var viewGoDetail: UIView!
    @IBOutlet weak var viewSharedTrip: UIView!
    @IBOutlet weak var viewLiveStream: UIView!
    
    @IBOutlet weak var viewTopStack: UIView!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var btnShare: UIButton!
    
    
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        dataSource = DriverDetailDataSource(driver: driver)
//        dataSource.delegate = self
        labelName.text = driver.name
        updateUI()
        configCollectionView()
      
        fetchTrips()
        self.viewGoDetail.addTapGesture {
            self.goDetailButtonTapped()
        }
        self.viewLiveStream.addTapGesture {
            self.goLiveButtonTapped()
        }
    }
    
    func configCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "TripFleetDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TripFleetDetailCollectionViewCell")
        
      ///  collectionView.register(Header.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setBorderView(view : UIView) {
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
    }
    
    func setFontButton(button : UIButton) {
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 8)
        button.setTitleColor(UIColor.color(fromHex: ConstantMK.grayLabel), for: .normal)
    }
    func setTextButtonLocalized(button : UIButton , text : String) {
        button.titleLabel?.text = NSLocalizedString(text, comment: text)
    }
    
    func setFontLabel(label : UILabel) {
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.color(fromHex: ConstantMK.grayLabel)
    }
    func setTextLabelLocalized(label : UILabel , text : String) {
        label.text = NSLocalizedString(text, comment: text)
    }
    
    

    override func applyTheme() {
        super.applyTheme()
        self.view.backgroundColor = UIColor.white
        self.viewBackground.backgroundColor = UIColor.color(fromHex: ConstantMK.bg_main_color)
        setBorderView(view: self.viewTopStack)
        setFontLabel(label: self.liveLabel)
        setFontLabel(label: self.detailLabel)
        setBorderView(view: self.viewGoDetail)
        setBorderView(view: self.viewLiveStream)
        setTextLabelLocalized(label: self.detailLabel, text: "Go Detail")
        
        setTextLabelLocalized(label: self.liveLabel, text: "Go Live")
    }

    @IBAction func shareTrip(_ sender: Any){
        if let url = URL(string: "http://fms.mkvision.com/#/trippl/" + self.currentTripSelected), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

//MARK: - Private

extension DriverPanelViewController {

    private func updateUI() {
        iconStatusDrive.image = UIImage(named: driver.vehicle.state == Vehicle.State.offline ?  "offline_small" : driver.vehicle.state == Vehicle.State.driving ?  "driving_small" : "parking_small")
        
        title = driver.name
        
        plateLabel.text = driver.vehicle.plateNumber
        
        mileageLabel.text = driver.statistics.mileage.localeStringValue
        
        eventLabel.text = "\(driver.statistics.eventCount)"
        
        durationLabel.text = driver.statistics.duration.localeStringValue
        
        btnShare.isHidden = true
        btnShare.setTitle("", for: .normal)
        btnShare.tintColor = UIColor.color(fromHex: ConstantMK.bgTabar)
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


extension DriverPanelViewController {

    func goDetailButtonTapped() {
        let driverDetailVC = TripDetailTimelineViewController(nibName: "TripDetailTimelineViewController", bundle: nil)
        driverDetailVC.driver = self.driver
        driverDetailVC.cameraSn = driver.vehicle.cameraSN
        driverDetailVC.name = driver.name
        AppViewControllerManager.topViewController?.navigationController?.pushViewController(driverDetailVC, animated: true)
    }

    func goLiveButtonTapped() {
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

//MARK: - DriverDetailDataSourceDelegate

//extension DriverPanelViewController: DriverDetailDataSourceDelegate {
//
//    func dataSource(_ driverListDataSource: DriverDetailDataSource, didUpdate trips: [Trip]) {
//        print("thanh trips ",trips.count)
//        self.itemsTrip = trips
//        self.collectionView.reloadData()
//    }
//
//    func dataSource(_ driverListDataSource: DriverDetailDataSource, didUpdateEvents events: [Event]) {
//        delegate?.viewController(self, dropPinsForEvents: events)
//    }
//
//    func dataSource(_ driverListDataSource: DriverDetailDataSource, didUpdate trip: Trip) {
//        delegate?.viewController(self, drawTrackFor: trip)
//    }
//
//    func dataSource(_ driverListDataSource: DriverDetailDataSource, didUpdate change: DataChange<Trip>) {
//        switch change {
//        case .inserted(let items):
//            items.forEach { (trip) in
//               delegate?.viewController(self, drawTrackFor: trip)
//            }
//        case .updated(let items):
//            items.forEach { (trip) in
//              //  delegate?.viewController(self, drawTrackFor: trip)
//            }
//        case .deleted(let items):
//            items.forEach { (trip) in
//               // delegate?.viewController(self, removeTrackFor: trip)
//            }
//        }
//    }
//}

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
                //print("err",err)
                break
            }
            // dispatchGroup.leave()
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
    
       
        api.trips(cameraSn: driver.vehicle.cameraSN, searchDate:  date, completion: { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            switch result {
            case .success(let value):
                if let tripDicts = value["data"] as? [JSON] {
                    
                    if let tripData = try? JSONSerialization.data(withJSONObject: tripDicts, options: []){
                        do {
                            
                            let trips = try JSONDecoder().decode([Trip].self, from: tripData).sorted(by: {$0.id! < $1.id!})
                            
                            
                            strongSelf.itemsTrip = trips
                            
                            if !trips.isEmpty {
                                if trips.count > 0 {
                                    strongSelf.collectionView(strongSelf.collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
                                }
                                strongSelf.lblNoTrips.text = ""
                            } else {
                                strongSelf.collectionView.isHidden = true
                                strongSelf.lblNoTrips.text = "No trips"
                                strongSelf.lblCurrentTrip.text = "No trips"
                                strongSelf.viewSharedTrip.isHidden = true
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
