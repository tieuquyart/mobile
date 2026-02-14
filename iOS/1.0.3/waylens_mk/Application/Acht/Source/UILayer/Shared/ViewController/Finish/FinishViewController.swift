//
//  FinishViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

struct FinishViewControllerConfig {
    var icon: UIImage
    var title: String
    var subtitle: String
    var buttonTitle: String
    var buttonAction: (UIViewController?) -> ()

    static var finish: FinishViewControllerConfig {
        return FinishViewControllerConfig(
            icon: #imageLiteral(resourceName: "icon_done"),
            title: NSLocalizedString("Finished", comment: "Finished"),
            subtitle: "",
            buttonTitle: NSLocalizedString("OK", comment: "OK")
        ) { viewController in
            viewController?.navigationController?.popToRootViewController(animated: true)
        }
    }
}

class FinishViewController: BaseViewController {
    private var userInterface: FinishUserInterfaceView!

    private let state: FinishViewControllerConfig

    init(
        config: FinishViewControllerConfig
    ) {
        self.state = config

        super.init(nibName: nil, bundle: nil)

        self.userInterface = { [weak self] in
            let v = FinishRootView()
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        userInterface.render(newState: state)
    }

}

//MARK: - Private

private extension FinishViewController {

    func setup() {
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

}

extension FinishViewController: FinishIxResponder {

    func buttonTapped() {
        state.buttonAction(self)
    }

}
