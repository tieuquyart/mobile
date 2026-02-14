//
//  TimeInfoDriverViewController.swift
//  DemoCSV
//
//  Created by TranHoangThanh on 8/24/22.
//

import UIKit
import SwiftCSV

extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
    
    func to2Date() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: self)
    }
}


class TimeInfoDriverViewController: UIViewController {
    var stringPath = ""
    @IBOutlet weak var tableView: UITableView!
    var timeStartDriving : String = ""
    var driverName : String = ""
    var timeStart : String = ""
    var timeStop : String = ""
    var check : Bool = false
    var timeACCoff : String = ""
    var timeDrivingBeans : [LogTimeDrivingBean] = []
    var isDrivingTime = false
    @IBOutlet weak var lblTotalTime: UILabel!
    
    private var allFieldsCount: Double {
        var sum : Double = 0
        timeDrivingBeans.forEach { sum += $0.timeDrivingCurrent }
        return sum
    }
    
    func minutesBetweenDates(_ oldDate: Date, _ newDate: Date) -> Double {

        //get both times sinces refrenced date and divide by 60 to get minutes
        let newDateMinutes = newDate.timeIntervalSinceReferenceDate/60
        let oldDateMinutes = oldDate.timeIntervalSinceReferenceDate/60

        //then return the difference
        return Double(newDateMinutes - oldDateMinutes)
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.isDrivingTime ? "Thời gian lái xe liên tục" : "Thời gian dừng dỗ"
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "TimeInfoDriveTableViewCell", bundle: nil), forCellReuseIdentifier: "TimeInfoDriveTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "TimeInfoDriveHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "TimeInfoDriveHeader")
        
        do {

            // Specifying a custom delimiter
            let csv : CSV = try CSV<Enumerated>(string: stringPath, delimiter: .comma)
            var line : [String] = []
           // print(tsv)
            let items : [[String]] = csv.rows
           
           //  print(items)
            for i in 0..<items.count {
                line = items[i]
            //  print(line[0])
                if self.isDrivingTime {
                    if (!check && line[0].isEqual("START DRIVING")) {
                        print("time START DRIVING:= " + line[1]);
                        timeStartDriving = line[1];
                        timeStart = line[1]
                        driverName = line[4]
                        print("driverName:= "+driverName);
                        check = true
                    } else if (check && line[0].isEqual("ACC_OFF")) {
                        print("time acc_off:= " + line[1]);
                        timeACCoff = line[1];
                        
                   
                       
                        if let timeAccOffDate = timeACCoff.to2Date() , let timeStartDrivingDate = timeStartDriving.to2Date() {
                            let timeDrivingCurrent = self.minutesBetweenDates(timeStartDrivingDate, timeAccOffDate)

                          
                            print("timeStart: \(timeStart), timeAccOff: \(timeACCoff), time driving: \(timeDrivingCurrent)");
                            
                            check = false;
                            /*=========*/
                            
                            let timeDrivingBean = LogTimeDrivingBean(driverName: driverName,timeStart: timeStart, timeACCoff: timeACCoff, timeDrivingCurrent: timeDrivingCurrent);
                            
                            timeDrivingBeans.append(timeDrivingBean);
                            self.tableView.reloadData()
                          
        
                        }
                       

                    } else if  (check &&  i == items.count - 1) {
                        
                        print("time acc_off:= " + line[0]);
                        timeACCoff = line[0];
                        
                        if let timeAccOffDate = timeACCoff.to2Date() , let timeStartDrivingDate = timeStartDriving.to2Date() {
                            let timeDrivingCurrent = self.minutesBetweenDates(timeStartDrivingDate, timeAccOffDate)

                          
                            print("timeStart: \(timeStart), timeAccOff: \(timeACCoff), time driving: \(timeDrivingCurrent)");
                            
                            check = false;
                            /*=========*/
                        
                            let timeDrivingBean = LogTimeDrivingBean(driverName: driverName,timeStart: timeStart, timeACCoff: timeACCoff, timeDrivingCurrent: timeDrivingCurrent);
                
                            timeDrivingBeans.append(timeDrivingBean);
                            
                            self.tableView.reloadData()

        
                        }
                       
            
                    }
                }else{
                    if (!check && line[0].isEqual("ACC_OFF")) {
                        print("time ACC_OFF:= " + line[1]);
                        timeACCoff = line[1]
                        check = true
                    } else if (check && line[0].isEqual("STOP PARKING")) {
                        print("time STOP:= " + line[1]);
                        timeStop = line[1];
                        
                   
                       
                        if let timeAccOffDate = timeACCoff.to2Date() , let timeStopDate = timeStop.to2Date() {
                            let timeStopPs = self.minutesBetweenDates(timeAccOffDate,timeStopDate)

                          
                            print("timeAccOff: \(timeACCoff), timeStop: \(timeStop), time stopPs: \(timeStopPs)");
                            
                            check = false;
                            /*=========*/
                            
                            let timeStopBean = LogTimeDrivingBean(driverName: "",timeStart: timeACCoff, timeACCoff: timeStop, timeDrivingCurrent: timeStopPs);
                            
                            timeDrivingBeans.append(timeStopBean);
                            self.tableView.reloadData()
                          
        
                        }
                       

                    } else if  (check &&  i == items.count - 1) {
                        
                        print("time acc_off:= " + line[0]);
                        timeStop = line[0];
                        
                        if let timeAccOffDate = timeACCoff.to2Date() , let timeStopDate = timeStop.to2Date() {
                            let timeStopPs = self.minutesBetweenDates(timeAccOffDate, timeStopDate)

                          
                            print("timeAccOff: \(timeACCoff), timeStop: \(timeStop), time stopPs: \(timeStopPs)");
                            
                            check = false;
                            /*=========*/
                        
                            let timeDrivingBean = LogTimeDrivingBean(driverName: "",timeStart: timeACCoff, timeACCoff: timeStop, timeDrivingCurrent: timeStopPs);
                
                            timeDrivingBeans.append(timeDrivingBean);
                            
                            self.tableView.reloadData()

        
                        }
                       
            
                    }
                }

            }
            
            self.lblTotalTime.text = self.isDrivingTime ? "Tổng thời lái xe : \(String(format: "%.2f",allFieldsCount)) phút" : "Tổng thời gian dừng đỗ : \(String(format: "%.2f",allFieldsCount)) phút"
          
        } catch let err {
            print("error", err)
        
        }

        
    }
}

extension TimeInfoDriverViewController : UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeDrivingBeans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeInfoDriveTableViewCell", for: indexPath) as! TimeInfoDriveTableViewCell
        let item = timeDrivingBeans[indexPath.row]
        if self.isDrivingTime {
            cell.config(item: item, index: indexPath.row)
        }else{
            cell.configTimeStop(item: item, index: indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TimeInfoDriveHeader") as! TimeInfoDriveHeader
//        headerView.customLabel.text = content[section].name  // set this however is appropriate for your app's model
//        headerView.sectionNumber = section
//        headerView.delegate = self
        headerView.config(isDrivingTime: self.isDrivingTime)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44  // or whatever
    }
    
    
}
