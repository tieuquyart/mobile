//
//  TrackPolyline.swift
//  Fleet
//
//  Created by forkon on 2019/9/28.
//  Copyright © 2019 waylens. All rights reserved.
//

import MapKit

class TrackPolyline: MKPolyline {

   var track: Track? = nil
    
   

  
    

    convenience init(track: Track) {
        self.init(coordinates: track.coordinates, count: track.coordinates.count)
        self.track = track
        
//        let coordinates = track.coordinates
//
//        for item in coordinates {
//            let placemark = MKPlacemark(coordinate: item ,  addressDictionary: nil)
//            placemarks.append(MKMapItem(placemark: placemark))
//        }

        
//        
//        directionsRequest.transportType = MKDirectionsTransportType.automobile
//        
//        for (k, item) in placemarks.enumerated() {
//                if k < (placemarks.count - 1) {
//                    directionsRequest.source = item
//                    directionsRequest.destination = placemarks[k+1]
//                 
//                    let directions = MKDirections(request: directionsRequest)
//                    directions.calculate { response, error in
//                        if error == nil {
//                            self.myRoute = response?.routes[0] as? MKRoute
//                            if let polyline = self.myRoute?.polyline {
//                              
////                                if let last = mapView.overlays.last {
////                                    mapView.insertOverlay(polyline, below: last)
////                                } else {
////                                    mapView.addOverlay(polyline, level: .aboveRoads)
////                                }
//                               
//                            }
//                            
//                        }
//                    }
//                }
//            }
    }
}
