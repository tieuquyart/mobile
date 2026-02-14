//
//  EventView.swift
//  Acht
//
//  Created by Đoàn Vũ on 05/04/2023.
//  Copyright © 2023 waylens. All rights reserved.
//

import UIKit

protocol EventViewDelegate {
    func onPlayVideo(event: Event?)
}

class EventView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var categoryLb: UILabel!
    @IBOutlet weak var eventLb: UILabel!
    @IBOutlet weak var timeLb: UILabel!
    var delegate : EventViewDelegate?
    var eventModel : Event?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        nibSetup()
    }
    
    private func nibSetup() {
        Bundle.main.loadNibNamed("EventView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        clipsToBounds = true
        contentView.backgroundColor = .clear
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.translatesAutoresizingMaskIntoConstraints = true
        viewStatus.layer.cornerRadius = 6.5
    }
    
    
    func setupData(item: Event, delegate : EventViewDelegate){
        eventModel = item
        categoryLb.text = setTextTranselate(text: item.eventCategory ?? "")
        eventLb.text = setTextTranselate(text: item.eventType?.description ?? "")
        timeLb.text = transDate(item.createTime ?? "")
        self.delegate = delegate
    }
    
    func setTextTranselate(text : String) -> String {
        return NSLocalizedString(text, comment: text)
    }
    
    func transDate(_ dateStr : String) -> String {
        let date = dateStr.toDate("yyy-MM-dd'T'HH:mm:ss")
        let str = date?.toFormat("HH:mm") ?? ""
        return str
    }
    
    @IBAction func onPlayVideo(_ sender: Any){
        self.delegate?.onPlayVideo(event: eventModel)
    }
}
