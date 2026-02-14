//
//  AutoUpdateLogic.swift
//  Fleet
//
//  Created by forkon on 2019/10/9.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class AutoUpdateLogic {
    typealias UpdateBlock = (() -> ())

    private var updateTimer: Timer?
    private var updateBlock: UpdateBlock

    var isActive: Bool = false {
        didSet {
            if isActive != oldValue {
                let notificationCenter = NotificationCenter.default
                if isActive {
                    notificationCenter.addObserver(self, selector: #selector(startUpdateTimer), name: UIApplication.willEnterForegroundNotification, object: nil)
                    notificationCenter.addObserver(self, selector: #selector(discardUpdateTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
                    startUpdateTimer()
                } else {
                    notificationCenter.removeObserver(self)
                    discardUpdateTimer()
                }
            }
        }
    }

    init(updateBlock: @escaping UpdateBlock) {
        self.updateBlock = updateBlock
    }

    deinit {
        debugPrint("\(self) deinit")
        discardUpdateTimer()
    }
}

//MARK: - Private

extension AutoUpdateLogic {

    @objc private func startUpdateTimer() {
        discardUpdateTimer()

        updateTimer = Timer.scheduledTimer(withTimeInterval: 90.0, repeats: true) { [weak self] (timer) in
            self?.updateBlock()
        }
        updateTimer?.fire()
    }

    @objc private func discardUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

}
