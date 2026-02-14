//
//  GeoFenceListCardContentView.swift
//  Fleet
//
//  Created by forkon on 2019/11/20.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import MapKit

class GeoFenceListCardContentView: CardFlowViewCardContentView<CardFlowViewCardEventHandler<GeoFenceListItem>> {

    private enum Config {
        static let defaultHeight: CGFloat = 257.0
    }

    var item: GeoFenceListItem? {
        didSet {
            updateUI()
        }
    }

    private lazy var mapView: MKMapView = { [weak self] in
        let mapView = MKMapView()
        mapView.isUserInteractionEnabled = false
        mapView.delegate = self
        return mapView
    }()

    private lazy var infoView: UITableViewCell = {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        TableViewCellFactory.configSubtitleStyleCell(cell)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byTruncatingMiddle
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        return cell
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrameDivider = RectDivider(rect: layoutMarginsGuide.layoutFrame)

        mapView.frame = layoutFrameDivider.divide(atDistance: 184.0, from: CGRectEdge.maxYEdge)
        infoView.frame = layoutFrameDivider.remainder
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }

}

//MARK: - Private

private extension GeoFenceListCardContentView {

    func setup() {
        layoutMargins = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)

        addSubview(mapView)
        addSubview(infoView)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGestureRecognizer)

        applyTheme()

        updateUI()
    }

    func updateUI() {
        if let item = item {
            let ruleInfos = item.fenceRuleList.map{"\($0.name) (\($0.type))"}

            if ruleInfos.isEmpty {
                infoView.textLabel?.attributedText = NSAttributedString.titleAndTagString(
                    title: "",
                    titleFont: UIFont(name: "BeVietnamPro-Regular", size: 14)!,
                    tag: NSLocalizedString("Not Used", comment: "Not Used"),
                    tagBackgroundColor: UIColor.semanticColor(.memberTagBackground)
                )
            }
            else {
                infoView.textLabel?.text = ruleInfos.joined(separator: "\n")
            }

            infoView.detailTextLabel?.text = item.address

            if item.shape != .unknown {
                infoView.accessoryType = .disclosureIndicator

                mapView.removeAnnotations(mapView.annotations)
                mapView.removeOverlays(mapView.overlays)

                switch item.shape {
                case .circle(let center, let radius):
//                    let annotation = GeoFenceCircleCenterAnnotation()
//                    annotation.coordinate = center
//                    mapView.addAnnotation(annotation)

                    let circle = MKCircle(center: center, radius: radius)
                    mapView.addOverlay(circle)
                case .polygon(let points):
//                    points.forEach { (coordinate) in
//                        let annotation = GeoFencePolygonPointAnnotation()
//                        annotation.coordinate = coordinate
//                        mapView.addAnnotation(annotation)
//                    }

                    let polygon = MKPolygon(coordinates: points, count: points.count)
                    mapView.addOverlay(polygon)
                default:
                    break
                }

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) { [weak self] in
                    self?.mapView.updateRegionToShowAllAnnotationsAndOverlays(animated: false)
                }
            }
            else {
                let activityIndicatorView = UIActivityIndicatorView(style: .gray)
                infoView.accessoryView = activityIndicatorView
                activityIndicatorView.startAnimating()
            }

            if ruleInfos.isEmpty {
                frame.size.height = Config.defaultHeight
            }
            else {
                frame.size.height = 235.0 + 22.0 * CGFloat(ruleInfos.count)
            }
        }
        else {
            infoView.textLabel?.text = nil
            infoView.detailTextLabel?.text = nil
            infoView.accessoryType = .none

            frame.size.height = Config.defaultHeight
        }
    }

    @objc
    func handleTap() {
        if let item = item {
            eventHandler?.selectBlock?(item)
        }
    }

}

extension GeoFenceListCardContentView: Themed {

    func applyTheme() {
        infoView.textLabel?.textColor = UIColor.semanticColor(.label(.secondary))
        infoView.detailTextLabel?.textColor = UIColor.semanticColor(.label(.primary))
    }

}

extension GeoFenceListCardContentView: MKMapViewDelegate {

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
