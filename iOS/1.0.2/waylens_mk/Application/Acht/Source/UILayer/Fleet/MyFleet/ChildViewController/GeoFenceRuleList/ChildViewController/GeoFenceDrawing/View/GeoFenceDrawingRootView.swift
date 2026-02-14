//
//  GeoFenceDrawingRootView.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import MapKit

class GeoFenceDrawingRootView: UIView {
    weak var ixResponder: GeoFenceDrawingIxResponder?

    private let infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.numberOfLines = 0
        infoLabel.font = UIFont.systemFont(ofSize: 14.0)
        return infoLabel
    }()

    private lazy var mapView: MKMapView = { [weak self] in
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = self

        if let mapViewTapGestureRecognizer = self?.mapViewTapGestureRecognizer {
            mapView.addGestureRecognizer(mapViewTapGestureRecognizer)
        }

        return mapView
    }()

    private lazy var mapViewTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))

    private lazy var nextButton: UIButton = { [weak self] in
        let nextButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Next", comment: "Next"), color: UIColor.semanticColor(.tint(.primary)))

        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)

        return nextButton
    }()

    private lazy var doneButton: UIButton = { [weak self] in
        let doneButton = ButtonFactory.makeBigBottomButton(NSLocalizedString("Done", comment: "Done"), color: UIColor.semanticColor(.tint(.primary)))

        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)

        return doneButton
    }()

    private lazy var searchButton: UIButton = { [weak self] in
        let searchButton = UIButton(type: .custom)
        searchButton.set(
            title: NSLocalizedString("Search a location", comment: "Search a location"),
            titleFont: UIFont.systemFont(ofSize: 14.0),
            titleColor: UIColor.semanticColor(.label(.primary)),
            imageOnTitleLeft: #imageLiteral(resourceName: "search"),
            imageOnTitleRight: nil,
            margins: UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0),
            borderColor: UIColor.semanticColor(.border(.primary)),
            cornerRadius: UIButton.CornerRadius.halfHeight
        )

        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)

        return searchButton
    }()

    private lazy var userLocationButton: UIButton = { [weak self] in
        let userLocationButton = UIButton(type: .custom)
        userLocationButton.setImage(#imageLiteral(resourceName: "Location"), for: .normal)
        userLocationButton.sizeToFit()

        userLocationButton.addTarget(self, action: #selector(userLocationButtonTapped), for: .touchUpInside)

        return userLocationButton
    }()

    private lazy var cleanButton: UIButton = { [weak self] in
        let cleanButton = UIButton(type: .custom)
        cleanButton.setImage(#imageLiteral(resourceName: "Clean"), for: .normal)
        cleanButton.sizeToFit()

        cleanButton.addTarget(self, action: #selector(cleanButtonTapped), for: .touchUpInside)

        return cleanButton
    }()

    private lazy var rangeView: UITableViewCell = {
        let rangeView = UITableViewCell(style: .value1, reuseIdentifier: nil)
        TableViewCellFactory.configValue1StyleCell(rangeView)
        rangeView.textLabel?.text = NSLocalizedString("Range(miles)", comment: "Range(miles)")
        rangeView.detailTextLabel?.text = "0"

        let tap = UITapGestureRecognizer(target: self, action: #selector(rangeViewTapped))
        rangeView.addGestureRecognizer(tap)

        return rangeView
    }()

    private lazy var rangeField: UITextField = {
        let rangeField = UITextField()
        rangeField.isHidden = true

        return rangeField
    }()

    private var isFirstTimeShowingMap = true

    init() {
        super.init(frame: CGRect.zero)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let margin = layoutMargins.left
        let layoutFrame = layoutMarginsGuide.layoutFrame.insetBy(dx: 0.0, dy: margin)

        let rectDivider = RectDivider(rect: layoutFrame)

        if !infoLabel.isHidden {
            infoLabel.frame.size = infoLabel.sizeThatFits(layoutFrame.size)
            infoLabel.frame = rectDivider.divide(atDistance: infoLabel.frame.height, from: CGRectEdge.minYEdge)

            rectDivider.divide(atDistance: margin, from: CGRectEdge.minYEdge)
        }

        let bottomButtonHeight: CGFloat = 50.0

        if !nextButton.isHidden {
            nextButton.frame = rectDivider.divide(atDistance: bottomButtonHeight, from: CGRectEdge.maxYEdge)
            rectDivider.divide(atDistance: margin, from: CGRectEdge.maxYEdge)
        }

        if !doneButton.isHidden {
            doneButton.frame = rectDivider.divide(atDistance: bottomButtonHeight, from: CGRectEdge.maxYEdge)
            rectDivider.divide(atDistance: margin, from: CGRectEdge.maxYEdge)
        }

        if !rangeView.isHidden {
            rangeView.frame = rectDivider.divide(atDistance: 40.0, from: CGRectEdge.maxYEdge)
            rectDivider.divide(atDistance: margin, from: CGRectEdge.maxYEdge)
        }

        mapView.frame = rectDivider.remainder

        let mapFrameDivider = RectDivider(rect: mapView.frame)

        searchButton.frame = mapFrameDivider.divide(atDistance: 66.0, from: CGRectEdge.minYEdge).inset(by: UIEdgeInsets(top: 10.0, left: 47.0, bottom: 10.0, right: 47.0))
        searchButton.layer.cornerRadius = searchButton.frame.height / 2

        mapFrameDivider.divide(atDistance: 12.0, from: CGRectEdge.maxXEdge)

        let floatingButtonSideLenght: CGFloat = 32.0
        let floatingButtonAreaDivider = RectDivider(rect: mapFrameDivider.divide(atDistance: floatingButtonSideLenght, from: CGRectEdge.maxXEdge))

        floatingButtonAreaDivider.divide(atDistance: 50.0, from: CGRectEdge.maxYEdge)

        userLocationButton.frame = floatingButtonAreaDivider.divide(atDistance: floatingButtonSideLenght, from: CGRectEdge.maxYEdge)

        let padding: CGFloat = 20.0
        floatingButtonAreaDivider.divide(atDistance: padding, from: CGRectEdge.maxYEdge)

        cleanButton.frame = floatingButtonAreaDivider.divide(atDistance: floatingButtonSideLenght, from: CGRectEdge.maxYEdge)
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

private extension GeoFenceDrawingRootView {

    func setup() {
        let margin = UIScreen.main.bounds.shorterEdge * 0.05
        layoutMargins = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: margin)

        addSubview(infoLabel)
        addSubview(mapView)
        addSubview(rangeView)
        addSubview(nextButton)
        addSubview(doneButton)
        addSubview(searchButton)
        addSubview(userLocationButton)
        addSubview(cleanButton)
        applyTheme()
    }

    @objc
    func handleTap(_ tapGesture: UITapGestureRecognizer) {
        let tapPoint = tapGesture.location(in: mapView)
        let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)

        ixResponder?.composeGeoFence(with: coordinate)
    }

    @objc
    func rangeViewTapped() {
        ixResponder?.editRange()
    }

    @objc func searchButtonTapped() {
        ixResponder?.showLocationPicker()
    }

    @objc
    func doneButtonTapped() {
        ixResponder?.doneComposingGeoFence()
    }

    @objc
    func nextButtonTapped() {
        ixResponder?.nextStep()
    }

    @objc
    func cleanButtonTapped() {
        ixResponder?.cleanGeoFence()
    }

    @objc
    func userLocationButtonTapped() {
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }

}

extension GeoFenceDrawingRootView: GeoFenceDrawingUserInterface {

    func render(newState: GeoFenceDrawingViewControllerState) {
        if case .circle(_, let radius) = newState.shape {
            let convertedRadius = Measurement(value: radius ?? 0, unit: UnitLength.meters).converted(to: .miles).value
            rangeView.detailTextLabel?.text = "\(convertedRadius)"
        }

        if newState.isEditable {
            mapViewTapGestureRecognizer.isEnabled = true
            searchButton.isHidden = false
            nextButton.isHidden = true
            userLocationButton.isHidden = false

            switch newState.shape {
            case .some(.circle(let center, let radius)):
                infoLabel.text = NSLocalizedString("Select the central point on the map:", comment: "Select the central point on the map:")
                cleanButton.isHidden = true

                if center != nil, radius != nil {
                    rangeView.isHidden = false
                    doneButton.isHidden = false
                }
                else {
                    rangeView.isHidden = true
                    doneButton.isHidden = true
                }
            case .some(.polygon(let points)):
                infoLabel.text = NSLocalizedString("Tap on the map to siege the geo-fencing area:", comment: "Tap on the map to siege the geo-fencing area:")
                rangeView.isHidden = true

                if let points = points, !points.isEmpty {
                    cleanButton.isHidden = false
                }
                else {
                    cleanButton.isHidden = true
                }

                if let points = points, points.count >= 3 {
                    doneButton.isHidden = false
                }
                else {
                    doneButton.isHidden = true
                }
            default:
                break
            }
        }
        else {
            infoLabel.text = NSLocalizedString("The graph is for preview only and cannot be edited", comment: "The graph is for preview only and cannot be edited")

            mapViewTapGestureRecognizer.isEnabled = false
            cleanButton.isHidden = true
            searchButton.isHidden = true
            nextButton.isHidden = false
            doneButton.isHidden = true
            rangeView.isHidden = true
            userLocationButton.isHidden = true
        }

        setNeedsLayout()
        layoutIfNeeded()

        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)

        var fenceOverlay: MKOverlay? = nil

        if let shape = newState.shape {
            switch shape {
            case .circle(let center, let radius):
                if let center = center, let radius = radius {
                    fenceOverlay = MKCircle(center: center, radius: radius)
                    mapView.addOverlay(fenceOverlay!)

                    if newState.isEditable {
                        let annotation = GeoFenceCircleCenterAnnotation()
                        annotation.coordinate = center
                        mapView.addAnnotation(annotation)
                    }

                    if !isFirstTimeShowingMap { //avoid crash
                        self.mapView.updateRegionToShowAllAnnotationsAndOverlays(animated: false)
                    }
                }
            case .polygon(let points):
                if let points = points {
                    if points.count == 2 {
                        let polyline = MKPolyline(coordinates: points, count: points.count)
                        mapView.addOverlay(polyline)
                    }

                    fenceOverlay = MKPolygon(coordinates: points, count: points.count)
                    mapView.addOverlay(fenceOverlay!)

                    if newState.isEditable {
                        points.forEach { (coordinate) in
                            let annotation = GeoFencePolygonPointAnnotation()
                            annotation.coordinate = coordinate
                            mapView.addAnnotation(annotation)
                        }
                    }
                }
            }
        }

        if isFirstTimeShowingMap {
            isFirstTimeShowingMap = false

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) { [weak self] in
                guard let self = self else {
                    return
                }

                if !self.mapView.annotations.isEmpty || !self.mapView.overlays.isEmpty {
                    self.mapView.updateRegionToShowAllAnnotationsAndOverlays(animated: false)
                }
                else {
                    if self.mapView.userLocation.coordinate != CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0) {
                        self.mapView.setCenter(self.mapView.userLocation.coordinate, animated: false)
                    }
                }
            }
        }

        if let centralLocation = newState.centralLocation {
            mapView.setCenter(centralLocation.location.coordinate, animated: true)
        }

        let activityIndicatingState = newState.viewState.activityIndicatingState
        if activityIndicatingState == .none {
            HNMessage.dismiss()
        } else {
            if activityIndicatingState.isSuccess {
                if activityIndicatingState == .doneSaving {
                    HNMessage.dismiss()
                }
                else {
                    HNMessage.showSuccess(message: activityIndicatingState.message)
                    HNMessage.dismiss(withDelay: 1.0)
                }
            } else {
                if activityIndicatingState == .saving {
                    HNMessage.show()
                }
                else {
                    HNMessage.show(message: activityIndicatingState.message)
                }
            }
        }

    }

}

extension GeoFenceDrawingRootView: Themed {
    func applyTheme() {
        backgroundColor = UIColor.semanticColor(.background(.secondary))
        infoLabel.textColor = UIColor.semanticColor(.label(.secondary))
        searchButton.backgroundColor = UIColor.semanticColor(.background(.primary))
    }
}
extension GeoFenceDrawingRootView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case _ as GeoFenceCircleCenterAnnotation:
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            annotationView.image = #imageLiteral(resourceName: "Circular point")
            return annotationView
        case _ as GeoFencePolygonPointAnnotation:
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            annotationView.image = #imageLiteral(resourceName: "Polygonal point")
            return annotationView
        default:
            return MKAnnotationView()
        }
    }
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
        case let polyline as MKPolyline:
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.semanticColor(.tint(.primary))
            renderer.lineWidth = 2.0
            return renderer
        default:
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

class GeoFencingPointAnnotationView: MKAnnotationView {
    init(annotation: MKPointAnnotation) {
        super.init(annotation: annotation, reuseIdentifier: "Vehicle")
        image = #imageLiteral(resourceName: "path_start")
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GeoFenceCircleCenterAnnotation: MKPointAnnotation {

}

class GeoFencePolygonPointAnnotation: MKPointAnnotation {

}
