//
//  PCTVehicleTypeViewController.swift
//  Acht
//
//  Created by forkon on 2019/2/21.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class PCTVehicleTypeViewController: BaseViewController {
    fileprivate var selectedVehicleType: VehicleType? = nil {
        didSet {
            refreshUI()
        }
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cableNameLabel: UILabel!
    @IBOutlet weak var cableImageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    
    var cableType: PowerCableType!

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        initHeader(text: NSLocalizedString("Power Cord Test", comment: "Power Cord Test"), leftButton: true)
        view.backgroundColor = UIColor.semanticColor(.background(.secondary))

        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        refreshUI()
    }

    override func applyTheme() {
        super.applyTheme()

        refreshUI()
    }
    
    func refreshUI() {
        nextButton.isEnabled = (selectedVehicleType != nil)
        nextButton.layer.cornerRadius = 8
        nextButton.layer.masksToBounds = true
        nextButton.backgroundColor = nextButton.isEnabled ? UIColor.color(fromHex: ConstantMK.blueButton) : UIColor.semanticColor(.background(.quaternary))
        
        cableNameLabel.text = cableType.name
//        cableImageView.image = cableType.image
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PCTDoneTestViewController, let selectedVehicleType = selectedVehicleType {
            vc.vehicleType = selectedVehicleType
        }
    }
    
}

extension PCTVehicleTypeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VehicleType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleCell", for: indexPath) as! VehicleCell
        
        let vehicleType = VehicleType.allCases[indexPath.row]
        cell.nameLabel.text = vehicleType.name
        cell.detailLabel.text = vehicleType.description
        cell.isSelected = (selectedVehicleType == vehicleType)
        cell.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVehicleType = VehicleType.allCases[indexPath.row]
    }
    
}

class VehicleCell: UITableViewCell, Themed {
    
    @IBOutlet private weak var selectionIndicatorView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        applyTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

    private func setup() {
        selectionStyle = .none

        applyTheme()
    }

    func applyTheme() {
        backgroundColor = UIColor.clear

        selectionIndicatorView.backgroundColor = UIColor.clear
        selectionIndicatorView.layer.cornerRadius = selectionIndicatorView.frame.height / 2
        selectionIndicatorView.layer.borderColor = UIColor.color(fromHex: ConstantMK.blueButton).cgColor

        if isSelected {
            selectionIndicatorView.layer.borderWidth = 6.0
        } else {
            selectionIndicatorView.layer.borderWidth = 1.0
        }
    }
    
}

enum VehicleType: CaseIterable {
    case electric
    case hybridPlugin
    case traditional
}

extension VehicleType {
    
    var name: String {
        switch self {
        case .electric:
            return NSLocalizedString("Electric", comment: "vehicle type Electric")
        case .hybridPlugin:
            return NSLocalizedString("Plug-in Hybrid", comment: "vehicle type Plug-in Hybrid")
        case .traditional:
            return NSLocalizedString("Traditional", comment: "vehicle type Traditional")
        }
    }
    
    var description: String {
        switch self {
        case .electric:
            return NSLocalizedString("Pure electric powered vehicles such as Tesla, BMW i3, Nissan Leaf or other fully electric powertrain vehicles.", comment: "Pure electric powered vehicles such as Tesla, BMW i3, Nissan Leaf or other fully electric powertrain vehicles.")
        case .hybridPlugin:
            return NSLocalizedString("Plug-in hybrid vehicles such as Chevrolet Volt, Toyota Prius, Honda PHEV, or any vehicle that has both electric and gasoline/diesel drivetrains working together.", comment: "Plug-in hybrid vehicles such as Chevrolet Volt, Toyota Prius, Honda PHEV, or any vehicle that has both electric and gasoline/diesel drivetrains working together.")
        case .traditional:
            return NSLocalizedString("Vehicles with gasoline or diesel powertrains that do not feature a hybrid power or plug-in charging.", comment: "Vehicles with gasoline or diesel powertrains that do not feature a hybrid power or plug-in charging.")
        }
    }
    
}

