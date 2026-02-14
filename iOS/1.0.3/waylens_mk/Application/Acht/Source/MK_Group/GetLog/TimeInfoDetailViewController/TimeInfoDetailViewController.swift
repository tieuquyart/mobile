//
//  TimeInfoDetailViewController.swift
//  DemoCSV
//
//  Created by TranHoangThanh on 8/25/22.
//

import UIKit
import SwiftCSV

class TimeInfoDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var stringPath = ""
    var timeDriving : String = ""
    var longitude : String = ""
    var latitude : String = ""
    var unclear : String = ""
    var timeDetails : [LogTimeDetail] = []
    var searchTimeDetails : [LogTimeDetail] = []
    
    func getTime(str : String) -> String {
        let drivingArr : [String] = str.components(separatedBy: " ")
        return drivingArr.count == 2 ? drivingArr[1] : ""
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    var searching = false
    fileprivate func setupSearchBar() {
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }
    
//    func validate(value: String) -> Bool {
//        let PHONE_REGEX = "^[a-zA-Z_ ]*$"
//        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
//        let result = phoneTest.evaluate(with: value)
//        return result
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Báo cáo tốc độ"
        setupSearchBar()
        tableView.register(UINib(nibName: "TimeInfoDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "TimeInfoDetailTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TimeInfoDetailHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "TimeInfoDetailHeader")

        do {
            // Specifying a custom delimiter
            let csv : CSV = try CSV<Enumerated>(string: stringPath, delimiter: .comma)
            var line : [String] = []
           // print(tsv)
            let items : [[String]] = csv.rows
           
           // "[a-zA-Z]+"
//            let news = items.filter({ values in
//                let check = values[0].range(of: #"[a-zA-Z]+"#, options: .regularExpression)
//                return !(check != nil)
//            })
            let news = items.filter({ values in
                let check = values[0].matchsIn(regexString: "[a-zA-Z]+")
                return !check
            })
   //          print(news)
            for i in 0..<news.count {
                line = news[i]
                var strSpeed = ""
                for i in 3..<line.count {
                    strSpeed =  strSpeed + "\(line[i]),"
                }
                
               print("line[0]",line[0])
                
                let timeVal = line[0]
                
               
                let log = LogTimeDetail(time:  getTime(str: timeVal), coordinate: "\(line[1]) , \(line[2])", speed: strSpeed)
                self.timeDetails.append(log)
                self.tableView.reloadData()
            }

        } catch let err {
            print("error", err)
        
        }
    }




}


extension TimeInfoDetailViewController: UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searching ? searchTimeDetails.count :   timeDetails.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeInfoDetailTableViewCell", for: indexPath) as! TimeInfoDetailTableViewCell
        let item = searching ? searchTimeDetails[indexPath.row] : timeDetails[indexPath.row]
        cell.config(item: item, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TimeInfoDetailHeader") as! TimeInfoDetailHeader
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44  // or whatever
    }
    
    
}


extension TimeInfoDetailViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searching = true
        
        
        if searchText.isEmpty {
            searching = false
            searchTimeDetails.removeAll()
        } else {
            searching = true
            searchTimeDetails = timeDetails.filter{$0.time.range(of: searchText, options: .caseInsensitive) != nil}
        }
        self.tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
    
}
