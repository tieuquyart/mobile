//
//  CountDownUseCase.swift
//  Fleet
//
//  Created by forkon on 2019/11/1.
//  Copyright © 2019 waylens. All rights reserved.
//

class CountDownUseCase: UseCase {
    let actionDispatcher: ActionDispatcher

    private var interval: TimeInterval
    private var repeatTimes: Int

    private var timer: Timer?
    private var repeatCount: Int = 0

    private lazy var player: AVAudioPlayer = {
        let soundUrl = Bundle.main.url(forResource: "countdown_3s", withExtension: "m4a")
        let player = try! AVAudioPlayer(contentsOf: soundUrl!)
        return player
    }()

    public init(interval: TimeInterval, repeatTimes: Int, actionDispatcher: ActionDispatcher) {
        self.interval = interval
        self.repeatTimes = repeatTimes
        self.actionDispatcher = actionDispatcher
    }

    public func start() {
        guard repeatTimes > 0, interval > 0 else {
            return
        }

        repeatCount = 0

        actionDispatcher.dispatch(CountDownActions.tick(repeatTimes))
        playSoundEffect()

        timer = Timer(timeInterval: interval, repeats: true, block: { (timer) in
            self.repeatCount += 1
            self.actionDispatcher.dispatch(CountDownActions.tick(self.repeatTimes - self.repeatCount))

            if self.repeatCount >= self.repeatTimes {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                self.timer?.invalidate()
                self.timer = nil
            }
        })
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.default)
    }

    private func playSoundEffect() {
        player.play()
    }

}

protocol CountDownUseCaseFactory {
    func makeCountDownUseCase() -> UseCase
}
