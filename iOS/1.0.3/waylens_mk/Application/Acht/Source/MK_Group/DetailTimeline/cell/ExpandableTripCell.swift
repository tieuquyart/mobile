//
//  ExpandableTripCell.swift
//  Acht
//
//  Created by thanh on 09/01/2022.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import ExpandableCell

class ExpandableTripCell: ExpandableCelldev  {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var eventCategoryLabel: UILabel!
    
   
    var eventModel : Event?
    
    var handlePlayVideo : ((Event?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func btnVideoClick(_ sender: Any) {
        self.handlePlayVideo?(eventModel)
    }
    
    func  transDate(_ dateStr : String) -> String {
        let date = dateStr.toDate("yyyy-MM-dd'T'HH:mm:ss")
        let str = date?.toFormat("HH:mm") ?? ""
        return str
    }
    
    func config(item : Event) {
        timeLabel.text = transDate(item.startTime ?? "")
        eventTypeLabel.text = item.eventType?.description
        eventCategoryLabel.text = item.eventCategory
        self.eventModel = item
    }

}
