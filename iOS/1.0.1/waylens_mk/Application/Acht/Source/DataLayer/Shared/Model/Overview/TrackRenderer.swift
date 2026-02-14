//
//  TrackRenderer.swift
//  Fleet
//
//  Created by forkon on 2019/12/23.
//  Copyright © 2019 waylens. All rights reserved.
//

import MapKit

class TrackRenderer: MKPolylineRenderer {

    override init(overlay: MKOverlay) {
        super.init(overlay: overlay)

    //    strokeColor = UIColor.semanticColor(.tint(.primary))
        strokeColor = UIColor.red
        lineWidth = 2
        lineCap = .round

        if let trackPolyline = overlay as? TrackPolyline {
            if let trip = trackPolyline.track?.owner, /*!trip.isFinish ||*/ trip.isLatestTrip {
                self.strokeColor = UIColor.color(fromHex: ConstantMK.blueButton)
               // strokeColor = UIColor(rgb: 0x4A90E2, a: 0.73)
            } else {
                self.strokeColor = UIColor.red
                //strokeColor = UIColor(rgb: 0x999999, a: 0.73)
            }
        }
    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        super.draw(mapRect, zoomScale: zoomScale, in: context)

        if let trackPolyline = overlay as? TrackPolyline, trackPolyline.pointCount > 0 {
            let screenScale: CGFloat = min(UIScreen.main.scale, 2.0)
            let trackStartPointRadius: CGFloat = 5.0 * screenScale / zoomScale
            let trackStartPointBorderWidth: CGFloat = lineWidth * screenScale / zoomScale
            let trackStartPointFillColor = UIColor.white.cgColor

            let arrowHeadLength: CGFloat = 14.0 * screenScale / zoomScale
            let arrowHeadWidth: CGFloat = 9.0 * screenScale / zoomScale
            let arrowHeadBorderWidth: CGFloat = 2.0 * screenScale / zoomScale
            let arrowHeadFillColor = UIColor(rgb: 0xFFCB41).cgColor
            let arrowHeadFillColorFinish = UIColor.white.cgColor

            context.saveGState()
            context.setStrokeColor(strokeColor?.cgColor ?? UIColor.clear.cgColor)
//
            let mapPoints = trackPolyline.points()
           
            let trackStartPoint = point(for: mapPoints[0])

            context.beginPath()
            context.addEllipse(in:
                CGRect(
                    x: trackStartPoint.x - trackStartPointRadius,
                    y: trackStartPoint.y - trackStartPointRadius,
                    width: trackStartPointRadius * 2,
                    height: trackStartPointRadius * 2
                )
            )
            context.closePath()
            context.setLineWidth(trackStartPointBorderWidth)
            context.setFillColor(trackStartPointFillColor)
            context.drawPath(using: CGPathDrawingMode.fillStroke)

            context.setLineWidth(arrowHeadBorderWidth)

            if let trip = trackPolyline.track?.owner, /*!trip.isFinish ||*/ trip.isLatestTrip {
                context.setFillColor(arrowHeadFillColor)
            } else {
                context.setFillColor(arrowHeadFillColorFinish)
            }

            var prevMapPoint: MKMapPoint!
            var mapPoint: MKMapPoint!

            var prevArrowEndPoint: CGPoint?

            for i in 0..<trackPolyline.pointCount {
                if i == 0 {
                    prevMapPoint = mapPoints[0]
                    continue
                }

                mapPoint = mapPoints[i]
                let prevCGPt = point(for: prevMapPoint)
                let cgPoint = point(for: mapPoint)

                if prevArrowEndPoint == nil {
                    prevArrowEndPoint = prevCGPt
                }

                let xDist: CGFloat = (cgPoint.x - prevArrowEndPoint!.x)
                let yDist: CGFloat = (cgPoint.y - prevArrowEndPoint!.y)
                let distance = sqrt((xDist * xDist) + (yDist * yDist))

                if distance >= arrowHeadLength * 2 {
                    context.beginPath()

                    let arrow = UIBezierPath.arrow(
                        from: prevCGPt,
                        to: cgPoint,
                        tailWidth: 0.0,
                        headWidth: arrowHeadWidth,
                        headLength: arrowHeadLength
                    )

               //     print( "thanh arrow.cgPath" , arrow.cgPath)
                   
                    context.addPath(arrow.cgPath)
                
                    context.closePath()

                    context.drawPath(using: CGPathDrawingMode.fillStroke)

                    prevArrowEndPoint = cgPoint
                }

                prevMapPoint = mapPoint
            }
//
            context.restoreGState()
        }
        
        
        
        
        
        
        
    }

}
