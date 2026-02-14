//
//  LandscapeMenuViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

struct LandscapeMenuItem {
    var title: String
    var action: () -> ()
}

class LandscapeMenuViewController: BaseViewController {
    private var userInterface: LandscapeMenuUserInterfaceView!

    private let state: [LandscapeMenuItem]

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    init(
        items: [LandscapeMenuItem]
    ) {
        self.state = items

        super.init(nibName: nil, bundle: nil)

        self.userInterface = { [weak self] in
            let v = LandscapeMenuRootView()
            v.ixResponder = self
            return v
        }()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = userInterface
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userInterface.render(newState: state)
    }

}

//MARK: - Private

private extension LandscapeMenuViewController {

    func setup() {
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

}

extension LandscapeMenuViewController: LandscapeMenuIxResponder {

    func select(indexPath: IndexPath) {
        state[indexPath.row].action()
        dismiss()
    }

    func dismiss() {
        dismissMyself(animated: true)
    }

}
