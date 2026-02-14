//
//  GeoFenceRuleDetailRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import MapKit

class GeoFenceRuleDetailRootView: ViewContainTableViewAndBottomButton {
    weak var ixResponder: GeoFenceRuleDetailIxResponder?

    private lazy var mapView: MKMapView = { [weak self] in
        let mapView = MKMapView()
        mapView.delegate = self
        return mapView
    }()

    private let textView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets.zero
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont.systemFont(ofSize: 14.0)
        textView.isEditable = false
        return textView
    }()

    private let loadingIndicator: WLActivityIndicator = WLActivityIndicator(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 30.0))

    private var dataSource: GeoFenceRuleDetailDataSource? = nil

    override init() {
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        mapView.frame = CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: tableView.frame.size.height - tableView.contentInset.bottom)
        loadingIndicator.center = CGPoint(x: mapView.frame.width / 2, y: mapView.frame.height / 2)
    }

    override func applyTheme() {
        super.applyTheme()

        textView.textColor = UIColor.semanticColor(.label(.secondary))

        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                loadingIndicator.isLight = true
            }
            else {
                loadingIndicator.isLight = false
            }
        }
    }
}

//MARK: - Private

private extension GeoFenceRuleDetailRootView {

    func setup() {
        tableView.isScrollEnabled = false
        addBottomItemView(textView, height: 100.0)

        let triggeringVehiclesButton = ButtonFactory.makeBigBottomButton(
            NSLocalizedString("Triggering Vehicles", comment: "Triggering Vehicles"),
            titleColor: UIColor.semanticColor(.tint(.primary)),
            color: UIColor.clear,
            borderColor: UIColor.semanticColor(.tint(.primary))
        )
        triggeringVehiclesButton.addTarget(self, action: #selector(triggeringVehiclesButtonTapped), for: UIControl.Event.touchUpInside)
        addBottomItemView(triggeringVehiclesButton)

        let deleteButton = ButtonFactory.makeBigBottomButton(
            NSLocalizedString("Delete", comment: "Delete"),
            titleColor: UIColor.semanticColor(.label(.tertiary)),
            color: UIColor.clear,
            borderColor: UIColor.semanticColor(.label(.tertiary))
        )
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: UIControl.Event.touchUpInside)
        addBottomItemView(deleteButton)

        tableView.addSubview(mapView)
        tableView.separatorColor = UIColor.clear

        addSubview(loadingIndicator)
    }

    @objc func triggeringVehiclesButtonTapped() {
        ixResponder?.showTriggeringVehicles()
    }

    @objc func deleteButtonTapped() {
        ixResponder?.deleteGeoFenceRule()
    }

}

extension GeoFenceRuleDetailRootView: GeoFenceRuleDetailUserInterface {

    func render(newState: GeoFenceRuleDetailViewControllerState) {
        let placeholderData = 0...30
        dataSource = GeoFenceRuleDetailDataSource(items: Array(placeholderData))

        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.reloadData()

        guard let rule = newState.rule else {
            return
        }

        let text = """
        \(NSLocalizedString("Create Time", comment: "Create Time")): \(rule.createTime.dateManager.fleetDate.toStringUsingInNotificationList())

        \(NSLocalizedString("Location", comment: "Location")): \(newState.fence?.address ?? "")

        \(NSLocalizedString("Trigger Mode", comment: "Trigger Mode")): \(rule.type)
        """

        textView.text = text

        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)

        if let geoFence = newState.fence {
            switch geoFence.shape {
            case .circle(let center, let radius):
//                let annotation = GeoFenceCircleCenterAnnotation()
//                annotation.coordinate = center
//                mapView.addAnnotation(annotation)

                let circle = MKCircle(center: center, radius: radius)
                mapView.addOverlay(circle)
            case .polygon(let points):
//                points.forEach { (coordinate) in
//                    let annotation = GeoFencePolygonPointAnnotation()
//                    annotation.coordinate = coordinate
//                    mapView.addAnnotation(annotation)
//                }

                let polygon = MKPolygon(coordinates: points, count: points.count)
                mapView.addOverlay(polygon)
            default:
                break
            }
            mapView.updateRegionToShowAllAnnotationsAndOverlays(animated: false)
        }

        let activityIndicatingState = newState.viewState.activityIndicatingState
        if activityIndicatingState == .loading {
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()

            if activityIndicatingState.isSuccess {
                HNMessage.showSuccess(message: activityIndicatingState.message)
                HNMessage.dismiss(withDelay: 1.0)
            }
            else if activityIndicatingState == .none {
                HNMessage.dismiss()
            }
            else {
                HNMessage.show()
            }
        }
    }

}

extension GeoFenceRuleDetailRootView: MKMapViewDelegate {

//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        switch annotation {
//        case _ as GeoFenceCircleCenterAnnotation:
//            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
//            annotationView.image = #imageLiteral(resourceName: "Circular point")
//            return annotationView
//        case _ as GeoFencePolygonPointAnnotation:
//            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
//            annotationView.image = #imageLiteral(resourceName: "Polygonal point")
//            return annotationView
//        default:
//            return nil
//        }
//    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case let circle as MKCircle:
            let renderer = MKCircleRenderer(circle: circle)
            renderer.strokeColor = UIColor.semanticColor(.tint(.primary))
            renderer.lineWidth = 2.0
            renderer.fillColor = UIColor.semanticColor(.tint(.primary)).withAlphaComponent(0.3)
            return renderer
        case let polygon as MKPolygon:
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.strokeColor = UIColor.semanticColor(.tint(.primary))
            renderer.lineWidth = 2.0
            renderer.fillColor = UIColor.semanticColor(.tint(.primary)).withAlphaComponent(0.3)
            return renderer
        default:
            return MKOverlayRenderer(overlay: overlay)
        }
    }

}

public class GeoFenceRuleDetailDataSource: TableArrayDataSource<Int> {

    public convenience init(items: [Int]) {
        self.init(
            array: items,
            tableSettings: [
                TableSetting.rowHeight({_ in return 90.0}),
                TableSetting.sectionHeaderHeight({_ in return 0.001})
            ],
            cellInstantiator: { (indexPath) -> CellInstantiateType in
                return .Class(cellStyle: .default)
        }
        ) { (cell, item, indexPath) in
            cell.backgroundColor = UIColor.clear
        }
    }

}
