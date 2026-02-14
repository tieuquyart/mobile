import Foundation

/// Timeout wrapps a callback deferral that may be cancelled.
///
/// Usage:
/// Timeout(1.0) { println("1 second has passed.") }
///
class TimeoutHandler: NSObject {
    private var timer: Timer?
    private var callback: (() -> Void)?

    init(_ delaySeconds: TimeInterval, _ callback: @escaping () -> Void) {
        super.init()
        self.callback = callback
        self.timer = Timer.scheduledTimer(
            timeInterval: TimeInterval(delaySeconds),
            target: self,
            selector: #selector(invoke),
            userInfo: nil,
            repeats: false
        )
    }

    @objc func invoke() {
        self.callback?()
        self.callback = nil
        self.timer = nil
    }

    func cancel() {
        self.timer?.invalidate()
        self.timer = nil
    }
}
