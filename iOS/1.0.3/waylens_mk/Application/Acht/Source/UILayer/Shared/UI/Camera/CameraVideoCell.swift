//
//  CameraVideoCell.swift
//  Acht
//
//  Created by gliu on 6/19/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit

protocol CameraVideoCellDelegate : NSObjectProtocol {
    func onLongpressed(cell : CameraVideoCell)
}

class CameraVideoCell: UITableViewCell {

    var type : HNVideoType = .parkingMotion

    static func cellIdentifier() ->String {
        return "CameraVideoCell"
    }

    @IBOutlet weak var upLine: UIView!
    @IBOutlet weak var downLine: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typeIcon: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var carName: UILabel!

    @IBOutlet weak var thumbnail: UIImageView!
    
    weak var delegate : CameraVideoCellDelegate?
    
    open fileprivate(set) lazy var longpressGestureRecognizer: UILongPressGestureRecognizer = { [unowned self] in
        let gesture = UILongPressGestureRecognizer()
        gesture.minimumPressDuration = 1.0
        gesture.addTarget(self, action: #selector(handleLongpressGestureRecognizer))
        return gesture
        }()

    func setType(type t : HNVideoType) {
        switch t {
        case .parkingMotion:
            self.typeLabel.text = NSLocalizedString("Motion", comment: "Motion")
            self.typeLabel.textColor = WLStyle.activityGreenColor
            self.typeIcon.image = #imageLiteral(resourceName: "icon_parking_mode_motion")
            break
        case .parkingHit:
            self.typeLabel.text = NSLocalizedString("Hit", comment: "Hit")
            self.typeLabel.textColor = WLStyle.activityYellowColor
            self.typeIcon.image = #imageLiteral(resourceName: "icon_parking_mode_hit")
            break
        case .parkingHeavy:
            self.typeLabel.text = NSLocalizedString("Heavy Hit", comment: "Heavy Hit")
            self.typeLabel.textColor = WLStyle.activityRedColor
            self.typeIcon.image = #imageLiteral(resourceName: "icon_parking_mode_heavy")
            break
        case .drivingHit:
            fallthrough
        default:
            self.typeLabel.text = NSLocalizedString("Bump", comment: "Bump")
            self.typeLabel.textColor = WLStyle.activityYellowColor
            self.typeIcon.image = #imageLiteral(resourceName: "icon_driving_mode_hit")
            break
        }
    }
    
    func setBeAlertType(alert bAlert : Bool, name : String?) {
        carName.isHidden = !bAlert
        if bAlert {
            carName.text = name ?? ""
            time.font = UIFont.boldSystemFont(ofSize: 14)
            upLine.isHidden = true
            downLine.isHidden = true
        } else {
            time.font = UIFont.boldSystemFont(ofSize: 24)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentView.addGestureRecognizer(longpressGestureRecognizer)
    }
    func setBeFirstInSection(isFirst : Bool) {
        upLine.isHidden = isFirst
    }
    func setBeLastInSection(isLast : Bool) {
        downLine.isHidden = isLast
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //MARK: - private
    @objc func handleLongpressGestureRecognizer() {
        if longpressGestureRecognizer.state == .ended {
            delegate?.onLongpressed(cell: self)
        }
    }
}
