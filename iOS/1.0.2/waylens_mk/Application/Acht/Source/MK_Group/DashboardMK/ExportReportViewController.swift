//
//  ExportReportViewController.swift
//  Acht
//
//  Created by TranHoangThanh on 8/30/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import LBTATools
import DropDown
import SVProgressHUD


//class FileSystem {
//
//    static let documentsDirectory: URL = {
//        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        return urls[urls.endIndex - 1]
//    }()
//
//    static let cacheDirectory: URL = {
//        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
//        return urls[urls.endIndex - 1]
//    }()
//
//    static let downloadDirectory: URL = {
//        let directory: URL = FileSystem.documentsDirectory.appendingPathComponent("/Download/")
//        return directory
//    }()
//
//
//}

struct DriverReport  {
    let id: Int
    let name : String
}

protocol ExportReportVCDelegate{
    func onClickViewSelectDate(show:Bool)
}



class ExportReportViewController: BaseViewController {


    @IBOutlet weak var btnDownload: UIButton!

    @IBOutlet weak var btnShowLicensePlate: UIView!
    @IBOutlet weak var btnShowSpeed: UIView!
    @IBOutlet weak var btnShowDrivingTime: UIView!
    @IBOutlet weak var btnShowSyntheticReport: UIView!
    @IBOutlet weak var btnShowDriverName: UIView!
    
    @IBOutlet weak var lblShowDrivingTime: UILabel!
    @IBOutlet weak var lblShowSpeed: UILabel!
    @IBOutlet weak var lblShowLicensePlate: UILabel!
    @IBOutlet weak var lblShowSyntheticReport: UILabel!
    @IBOutlet weak var lblShowDriverName: UILabel!
    @IBOutlet weak var lbTitle: UILabel?
    @IBOutlet weak var viewTitle: UIView!
    
    var delegate : ExportReportVCDelegate?
    
    let chooselicenseplates = DropDown()
    let chooseShowSpeed = DropDown()
    let chooseDrivingTime = DropDown()
    let chooseSyntheticReport = DropDown()
    let chooseDriverName = DropDown()

    
    var key : String = ""
    
    var key1 : String = ""
    
    var licensePlate : String = ""
   //  var driverName : String = ""
    
    var driverId : Int = 0
    
    var link : URL?
    
    var driversReport : [DriverReport] = []
    var plateNos = [String]()
   // var plateNosChoose = [String]()
   // var plateNos = [String]()
  //  var drivers : [String] = []
    var driverIds = [Int]()
    //ar driverIdsChoose = [Int]()
    var index : Int = 0
    
    @IBOutlet weak var titleLicensePlate: UILabel!
    
    @IBOutlet weak var dateRangeMkView: DateRangeMKHeaderView!
    
    
    var statusDriving : Bool = false
    
    var dateRange = DateRange(from: Date(), to: Date())
    
    
    func configDateRange() {
        if let last = Date().getLast7Day() {
            self.dateRangeMkView.dateRange = DateRange(from: last, to: Date())
        }
        self.dateRangeMkView.closureDate = { [weak self] newRange in
            self?.dateRange = newRange
        }
        
        self.dateRangeMkView.delegate = self
    }
    
    @IBOutlet weak var tokenJpushBtn: UIButton!
    
    func formatTextLicensePlate() -> Bool {
        
        
        if let licenseText = lblShowLicensePlate.text {
            if licenseText.isEmpty  {
                self.showAlert(title: "Thông báo", message: "Xuất báo cáo Không có dữ liệu")
                return false
            }
        }
        return true
    }
    
    func formatTextdriveName() -> Bool {
        
        
        if let driveNameText = lblShowDriverName.text {
            if driveNameText.isEmpty  {
                self.showAlert(title: "Thông báo", message: "Xuất báo cáo Không có dữ liệu")
                return false
            }
        }
        return true
    }
    
    func formatTextdriveTime() -> Bool {
        
        
        if let drivingTimeText = lblShowDrivingTime.text {
            if drivingTimeText.isEmpty  {
                self.showAlert(title: "Thông báo", message: "Xuất báo cáo Không có dữ liệu")
                return false
            }
        }
        return true
    }
    
  
    
   
    func getFileExcel() {
        
        let startTime = dateRange.from.dateManager.fleetDate.dateAt(.startOfDay).date.toString(format: .isoDate)
        
        let endTime  = dateRange.to.dateManager.fleetDate.dateAt(.endOfDay).date.toString(format: .isoDate)
        
//        let param = ParamExcel(plate_no: "30G00573" , fleer_id: "", start_time: "2022-08-28T00:00:00+07:00", end_time: "2022-08-29T23:59:59+07:00").convertToDict()
//        self.performSyncRequest(param: param)
//        print("request param")
        
        var param : [String : Any] = [:]
        
        if index == 2 {
            param = ParamExcelDrivingTime(continuous: statusDriving, fleet_id: "", start_time: startTime + "T00:00:00+07:00" , end_time: endTime + "T23:59:59+07:00").convertToDict()
        } else if index == 5 {
            
            
//            {
//              "start_time": "2022-10-05T00:00:00+07:00",
//              "end_time": "2022-10-07T23:59:59+07:00",
//              "fleet_id": null
//            }
            
            
            param = ParamExcelDetailPicture(start_time: startTime + "T00:00:00+07:00" , end_time: endTime + "T23:59:59+07:00", fleet_id: "").convertToDict()
            
        } else if index == 4 {
            
            if lblShowSyntheticReport.text == "B5.1 Báo cáo tổng hợp theo xe" {
                param = ParamExcelList(list_plate_no: self.plateNos , fleet_id: "", start_time: startTime + "T00:00:00+07:00" , end_time: endTime + "T23:59:59+07:00").convertToDict()
//                if licensePlate == "Tất cả" {
//                    param = ParamExcelList(list_plate_no: self.plateNos , fleet_id: "", start_time: startTime + "T00:00:00+07:00" , end_time: endTime + "T23:59:59+07:00").convertToDict()
//                } else {
//                    param = ParamExcelList(list_plate_no: self.lblShowLicensePlate.text ?? "" , fleet_id: "", start_time: startTime + "T00:00:00+07:00" , end_time: endTime + "T23:59:59+07:00").convertToDict()
//                }
                
            } else {
                
                param = ParamDriverExcel(driver_id: self.driverIds, fleet_id: "", start_time: startTime + "T00:00:00+07:00", end_time: endTime + "T23:59:59+07:00").convertToDict()
                
//                if driverName == "Tất cả" {
//                    param = ParamDriverExcel(driver_id: self.driverIds, fleet_id: "", start_time: startTime + "T00:00:00+07:00", end_time: endTime + "T23:59:59+07:00").convertToDict()
//                } else {
//                    param = ParamDriverExcel(driver_id: self.driverIds, fleet_id: "", start_time: startTime + "T00:00:00+07:00", end_time: endTime + "T23:59:59+07:00").convertToDict()
//                }
                
            }

        } else {
            
            param = ParamExcel(plate_no: self.licensePlate , fleet_id: "", start_time: startTime + "T00:00:00+07:00" , end_time: endTime + "T23:59:59+07:00").convertToDict()
            
         //   param = ParamExcel(plate_no: "30G00573" , fleer_id: "", start_time: "2022-08-28T00:00:00+07:00" , end_time: "2022-08-29T23:59:59+07:00").convertToDict()
        }
        performSyncRequest(key : self.key , param: param)
        
        
    }
    
    
    @IBAction func btnDownLoad(_ sender: Any) {
        if index == 5 {
            getFileExcel()
            
        } else if index == 2 {
            if formatTextdriveTime() {
                getFileExcel()
            }
        }
        else if index == 4 {
            if lblShowSyntheticReport.text == "B5.1 Báo cáo tổng hợp theo xe" {
                if formatTextLicensePlate() {
                   getFileExcel()
               }
            } else {
                
                if formatTextdriveName() {
                    getFileExcel()
                }
              
            }
        
        } else {
            
            if formatTextLicensePlate() {
               getFileExcel()
           }
        }
         
//        if btnDownload.titleLabel?.text == "Xem" {
//            let vc = ExcelViewController(nibName: "ExcelViewController", bundle: nil)
//            vc.link = self.link
//            self.navigationController?.pushViewController(vc, animated: true)
//        } else {
//            getFileExcel()
//        }
     
    }
    
    func performSyncRequest(key : String , param : [String : Any])
    {
        SVProgressHUD.show("", maxTime: 60)
     //  let documentsUrl = (FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first as URL?)!
      //  let destinationFileUrl = documentsUrl.appendingPathComponent("attachName")
        let baseUrl = AppConfig.Server.production.rawValue
        let url = String(format: "\(baseUrl)/api/admin/excel/\(key)")
       guard let serviceUrl = URL(string: url) else { return }
       var urlrequest = URLRequest(url: serviceUrl)
       urlrequest.httpMethod = "POST"
       urlrequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
      
       urlrequest.setValue(AccountControlManager.shared.keyChainMgr.token , forHTTPHeaderField: "x-access-token")
       urlrequest.addValue("", forHTTPHeaderField: "Accept-Encoding")
       let requestBody : [String: Any] = param
       guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else { return }
      urlrequest.httpBody = httpBody
      urlrequest.timeoutInterval = 60
       do {
           let convertedString = String(data: httpBody, encoding: String.Encoding.utf8)
           print("Sync Request Body: \(convertedString!)")
       }

       let downloadTask = URLSession.shared.downloadTask(with: urlrequest, completionHandler: { (tempLocalUrl, response, error) in
           
           
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        print("Success: \(statusCode)")
            }
           
           guard let fileURL = tempLocalUrl else { return }
               do {
                   let documentsURL = try
                              FileManager.default.url(for: .documentDirectory,
                                                      in: .userDomainMask,
                                                      appropriateFor: nil,
                                                      create: false)
                   
                 //  let startTime = self.dateRange.from.dateManager.fleetDate.dateAt(.startOfDay).date.toString(format: .isoDate)
                   
                   let savedURL = documentsURL.appendingPathComponent("\(key) \(self.licensePlate).xlsx")
                          print("saveUrl", savedURL)
                   if  FileManager.default.fileExists(atPath: savedURL.path) {
                        try FileManager.default.removeItem(at: savedURL)
                   }
                   
                   try FileManager.default.moveItem(at: fileURL, to: savedURL)
                   self.link =  savedURL
                          
                   
                   DispatchQueue.main.async {
                       SVProgressHUD.dismiss()
                       self.showAlert(title: "Thông báo", message: "Tải về thành công")
                  //     self.btnDownload.setTitle("Xem", for: .normal)
                   }
                      
                        
               } catch {
                   SVProgressHUD.dismiss()
                   print(error.localizedDescription)
               }
       })

       downloadTask.resume()
    }

    
    
    
   
    

    init(title: String, index : Int, delegate : ExportReportVCDelegate?) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.index = index
        self.delegate = delegate
        getKey()

    }
    
    func getKey() {
        
       switch index {
       case 0:
           self.key = "vehicleFleet"
           break
       case 1:
           self.key = "vehicleSpeed"
       case 2:
           self.key = "drivingTime"
       case 3:
           self.key = "stopVehicle"
       case 4:
           self.key = "b51"
       case 5:
           self.key = "detailPicture"
       default:
           self.key = ""
       }
        
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func createBorder(for views: UIView..., color: UIColor, width: CGFloat) {
        // create border for many views or a view
        for view in views {
            view.layer.borderWidth = width
            view.layer.borderColor = color.cgColor
        }
    }
    func createCornerRadius(for views: UIView..., radius: CGFloat) {
        // create border for many views or a view
        for view in views {
            view.layer.cornerRadius = radius
        }
    }
    
    
    func setBorderView(for views: UIView...) {
        
        for view in views {
            view.layer.cornerRadius = 12
            view.layer.masksToBounds = true
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.color(fromHex: ConstantMK.borderGrayColor).cgColor
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        configDateRange()
        config()
        ConstantMK.borderButton([self.btnDownload])
        setBorderView(for: btnShowSpeed,btnShowLicensePlate,btnShowDrivingTime,btnShowSyntheticReport,btnShowDriverName)
        self.btnShowLicensePlate.addTapGesture {
            print("btnShowLicensePlate")
            self.getListVehicle()
        }
      
       
        self.btnShowSpeed.addTapGesture {
           print("btnShowSpeed")
            self.setupchooseShowSpeed()
        }
        self.btnShowDrivingTime.addTapGesture {
            print("btnShowDrivingTime")
            self.setupchooseDrivingTime()
        }
        
        self.btnShowSyntheticReport.addTapGesture {
            print("btnShowSyntheticReport")
            self.setupShowSyntheticReport()
        }
        
        self.btnShowDriverName.addTapGesture {
            print("btnShowDriverName")
            self.getListDriver()
        }
      
        configBtnDownload()
    }
    
    func configBtnDownload() {
        let smsImage  = UIImage(named: "arrow-down-mk")!
        btnDownload.addRightIcon(image: smsImage)
    }
    
    func config() {
  
        switch index {
        case 0,3:
            self.btnShowDrivingTime.isHidden = true
            self.btnShowSpeed.isHidden = true
            self.btnShowSyntheticReport.isHidden = true
            self.btnShowDriverName.isHidden = true
        case 1 :
            self.lblShowSpeed.text =  "B2.1 Tốc độ của xe"
            self.btnShowDrivingTime.isHidden = true
            self.btnShowSyntheticReport.isHidden = true
            self.btnShowDriverName.isHidden = true
            break
        case 2:
            self.titleLicensePlate.text = "Thời gian lái xe liên tục"
            self.btnShowSpeed.isHidden = true
            self.btnShowLicensePlate.isHidden = true
            self.btnShowSyntheticReport.isHidden = true
            self.btnShowDriverName.isHidden = true
            break
        case 4:
            self.lblShowSyntheticReport.text = "B5.1 Báo cáo tổng hợp theo xe"
            self.btnShowSpeed.isHidden = true
            self.btnShowDrivingTime.isHidden = true
            self.btnShowDriverName.isHidden = true
        case 5:
            self.titleLicensePlate.isHidden = true
            self.btnShowSpeed.isHidden = true
            self.btnShowLicensePlate.isHidden = true
            self.btnShowDrivingTime.isHidden = true
            self.btnShowSyntheticReport.isHidden = true
            self.btnShowDriverName.isHidden = true
        default:
           // getListVehicle()
            
            break
           
        }
        
        self.view.backgroundColor = .white
       
    }
    
    @IBAction func clickTokenJpushBtn(_ sender: Any) {
        self.showAlert(title: "Thông báo", message: "Copy thành công")
        UIPasteboard.general.string = JPush.shared().registrationID ?? ""
    }
    
    func setupchooseShowSpeed() {
        chooseShowSpeed.anchorView = btnShowSpeed
        chooseShowSpeed.direction = .top
        chooseShowSpeed.bottomOffset = CGPoint(x: 40, y: btnShowSpeed.bounds.height)

        chooseShowSpeed.dataSource = ["B2.1 Tốc độ của xe","B2.2 Quá tốc độ giới hạn"]
        chooseShowSpeed.show()
        chooseShowSpeed.selectionAction = { [weak self] (index , item) in
            print(item)
            self?.lblShowSpeed.text = item
            if item == "B2.1 Tốc độ của xe" {
                self?.key = "vehicleSpeed"
            } else if item == "B2.2 Quá tốc độ giới hạn" {
                self?.key = "overSpeed"
            }
            print(self?.key ?? "")
        }
    }
    
    func setupShowSyntheticReport() {
        chooseSyntheticReport.anchorView = btnShowSyntheticReport
        chooseSyntheticReport.direction = .top
        
        chooseSyntheticReport.bottomOffset = CGPoint(x: 40, y: btnShowSyntheticReport.bounds.height)
        
        chooseSyntheticReport.dataSource = ["B5.1 Báo cáo tổng hợp theo xe","B5.2 Báo cáo tổng hợp theo lái xe"]
        chooseSyntheticReport.show()
        chooseSyntheticReport.selectionAction = { [weak self] (index , item) in
            self?.lblShowSyntheticReport.text = item
            print(item)
            if item == "B5.1 Báo cáo tổng hợp theo xe" {
                self?.key = "b51"
                self?.btnShowDriverName.isHidden = true
                self?.btnShowLicensePlate.isHidden = false
            } else if item == "B5.2 Báo cáo tổng hợp theo lái xe" {
                self?.key = "b52"
                self?.btnShowDriverName.isHidden = false
                self?.btnShowLicensePlate.isHidden = true
            }
            print(self?.key ?? "")
        }
        
    }
    
    func setupchooseDrivingTime() {
        chooseDrivingTime.anchorView = btnShowDrivingTime
        chooseDrivingTime.direction = .top
        chooseDrivingTime.bottomOffset = CGPoint(x: 40, y: btnShowDrivingTime.bounds.height)
        
        chooseDrivingTime.dataSource = ["Tất cả","Lái xe liên tục quá 4 giờ"]
        chooseDrivingTime.show()
        chooseDrivingTime.selectionAction = { [weak self] (index , item) in
            self?.lblShowDrivingTime.text = item
            
            if item == "Tất cả" {
                self?.statusDriving = false
            } else if item == "Lái xe liên tục quá 4 giờ" {
                self?.statusDriving = true
            }
        }
    }
    
    func setupChooselicenseplates() {
        
        chooselicenseplates.anchorView = btnShowLicensePlate
        chooselicenseplates.direction = .top
        
        chooselicenseplates.bottomOffset = CGPoint(x: 40, y: btnShowLicensePlate.bounds.height)
        self.plateNos.insert("Tất cả", at: 0)
        chooselicenseplates.dataSource = self.plateNos
        
        chooselicenseplates.show()
        chooselicenseplates.selectionAction = { [weak self] (index , item) in
            self?.lblShowLicensePlate.text = item
            self?.licensePlate = item
            if index == 0 {
                self?.plateNos.removeFirst()
            } else {
                self?.plateNos = [self?.plateNos[index] ?? ""]
            }
        
        }
    
    }
    
    func setupChooseDrivers() {
        
        chooseDriverName.anchorView = btnShowDriverName
        chooseDriverName.direction = .top
        
        chooseDriverName.bottomOffset = CGPoint(x: 40, y: btnShowDriverName.bounds.height)
       
        self.driversReport.insert(DriverReport(id: 0, name: "Tất cả"), at: 0)
        
        chooseDriverName.dataSource = self.driversReport.map { item in
               item.name
        }
        
        chooseDriverName.show()
        chooseDriverName.selectionAction = { [weak self] (index , item) in
            self?.lblShowDriverName.text = item
            if index == 0 {
                self?.driverIds = self?.driversReport.map { item in
                        item.id
                 } ?? []
                self?.driverIds.removeFirst()
            } else {
                self?.driverIds = [self?.driversReport[index].id ?? 0]
            }
           
//            self?.driverName = item
        //    self?.driverId = self?.driversReport[index].id ?? 0
        }
        
        

        
    }
    
    func getListDriver() {
        
        DriverService.shared.list_driver(completion: { (result) in
        
            switch result {
                
            case .success(let value):
                ConstantMK.parseJson(dict: value, handler: {success, msg, code  in
                    if success {
                        if let data = value["data"] as? [JSON] {
                            if let infoData = try? JSONSerialization.data(withJSONObject: data , options: []){
                                do {
                                    
            
                                    let items = try JSONDecoder().decode([DriverItemModel].self, from: infoData)
                                
                                    self.driversReport =  items.map { item in
                                        let val = DriverReport(id: item.id ?? 0, name: item.name ?? "")
                                        return val
                                    }
                                    
                                    
        //                            self.drivers = items.map { item in
        //                                item.name ?? ""
        //                            }
                                    
                                    self.driverIds = items.map { item in
                                        item.id ?? 0
                                    }
                                    
                                     print("Drivers.count", self.driverIds.count)
                                    self.setupChooseDrivers()
                                } catch let err {
                                    print("err get VehicleProfile",err)
                                }
                            }
                        }
                    }else{
                        self.showErrorResponse(code: code)
                    }
                })
               
            case .failure(let err):
              HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
            }

        })
        
    }
    
    func getListVehicle() {
        
        VehicleService.shared.listVehicle(completion: { (result) in
        
            switch result {
                
            case .success(let value):
                ConstantMK.parseJson(dict: value, handler: { success, msg, code in
                    if success {
                        if let data = value["data"] as? [JSON] {
                            if let infoData = try? JSONSerialization.data(withJSONObject: data , options: []){
                                do {
                                    
                                    let items = try JSONDecoder().decode([VehicleItemModel].self, from: infoData)
                                
                                    
                                
                                    self.plateNos = items.map { item in
                                        item.plateNo ?? ""
                                    }
                                    
                                    print("plateNos", self.plateNos.count)
                                    self.setupChooselicenseplates()
                                } catch let err {
                                    print("err get VehicleProfile",err)
                                }
                            }
                        }
                    }else{
                        self.showErrorResponse(code: code)
                    }
                })
               
            case .failure(let err):
            
              HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
            }

        })
        
    }
    
    

}

extension ExportReportViewController : DateRangeMKHeaderViewDelegate{
    func onClickShowDateView(isShow : Bool) {
        self.delegate?.onClickViewSelectDate(show: isShow)
    }
}

extension ExportReportViewController : URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let url = downloadTask.originalRequest?.url else { return }
        let documentsPath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
       
        try? FileManager.default.removeItem(at: destinationURL)
        
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
            
        } catch let error {
            print("Copy Error: \(error.localizedDescription)")
        }
    }
}





extension UIViewController{

func showToast(message : String, seconds: Double){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }

func showToast(message : String, seconds: Double, completion: (() -> Void)? = nil){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            completion?()
            alert.dismiss(animated: true)
        }
    }
    
    func toastMessage( message: String){
        guard let window = UIApplication.shared.keyWindow else {return}
        let messageLbl = UILabel()
        messageLbl.text = message
        messageLbl.textAlignment = .center
        messageLbl.font = UIFont.systemFont(ofSize: 12)
        messageLbl.textColor = .white
        messageLbl.backgroundColor = UIColor(white: 0, alpha: 0.5)

        let textSize:CGSize = messageLbl.intrinsicContentSize
        let labelWidth = min(textSize.width, window.frame.width - 40)

        messageLbl.frame = CGRect(x: 20, y: 30, width: labelWidth + 30, height: textSize.height + 20)
        messageLbl.center.x = window.center.x
        messageLbl.layer.cornerRadius = messageLbl.frame.height/2
        messageLbl.layer.masksToBounds = true
        window.addSubview(messageLbl)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

        UIView.animate(withDuration: 1, animations: {
            messageLbl.alpha = 0
        }) { (_) in
            messageLbl.removeFromSuperview()
        }
        }
    }
 }
