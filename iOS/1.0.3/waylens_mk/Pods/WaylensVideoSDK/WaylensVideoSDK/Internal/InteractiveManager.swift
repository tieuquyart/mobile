//
//  InteractiveManager.swift
//  SC360
//
//  Created by Chester Shen on 11/19/18.
//  Copyright © 2018 Waylens. All rights reserved.
//

import Foundation
import UIKit
import GPUImage

protocol InteractionResponsive: class {
    func onMove(x: CGFloat, y: CGFloat)
    func onScale(_ diff: CGFloat)
}

class InteractiveManager {
    private var panGesture: UIPanGestureRecognizer?
    private var pinchGesture: UIPinchGestureRecognizer?
    weak var view: UIView?
    
    var lastScale: CGFloat = 1.0
    var lastLocation: CGPoint = .zero
    var lastTime: TimeInterval = 0
    weak var delegate: InteractionResponsive?
    var timer: Timer?
    var refreshInterval: TimeInterval = 0.04
    var deceleration: CGFloat = 0.02 // decelerate moving speed when inertia enabled, so it will stop eventaully
    // enable inertia so that the view can remain moving after dragging
    var inertiaEnabled: Bool = true {
        didSet {
            if !inertiaEnabled {
                stopTimer()
            }
        }
    }
    var speed: CGPoint = .zero
    
    init(view: UIView) {
        self.view = view
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        view.addGestureRecognizer(panGesture!)
        view.addGestureRecognizer(pinchGesture!)
    }
    
    func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            lastTime = Date().timeIntervalSince1970
            lastLocation = sender.location(in: view)
            stopTimer()
        } else if sender.state == .changed {
            guard let size = view?.bounds.size else {
                return
            }
            let location = sender.location(in: view)
            let dx = (location.x - lastLocation.x) / size.height
            let dy = (location.y - lastLocation.y) / size.width
            let now = Date().timeIntervalSince1970
            let inteval = CGFloat(now - lastTime)
            speed = CGPoint(x: min(5.0, dx/inteval), y: min(5.0, dy/inteval))
            lastTime = now
            delegate?.onMove(x: dx, y: dy)
            lastLocation = location
        } else if sender.state == .ended {
            if inertiaEnabled {
                print("speed \(speed)")
                speed = CGPoint(x: speed.x * CGFloat(refreshInterval), y: speed.y * CGFloat(refreshInterval))
                timer = Timer(timeInterval: refreshInterval, target: self, selector: #selector(nextMove), userInfo: nil, repeats: true)
                RunLoop.main.add(timer!, forMode: .common)
            }
        }
    }
    
    @objc func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            lastScale = sender.scale
            stopTimer()
        } else if sender.state == .changed {
            let diff = sender.scale / lastScale
            delegate?.onScale(diff)
            lastScale = sender.scale
        }
    }
    
    @objc func nextMove() {
        let normSpeed = sqrt(speed.x * speed.x + speed.y * speed.y)
        if normSpeed <= deceleration * CGFloat(refreshInterval) {
            stopTimer()
            return
        }
        let ratio = 1 - deceleration * CGFloat(refreshInterval) / normSpeed
        let dx = speed.x * ratio
        let dy = speed.y * ratio
        delegate?.onMove(x: dx, y: dy)
        speed = CGPoint(x: dx, y: dy)
    }
}
