//
//  MemberProfileInfoComposingViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class MemberProfileInfoComposingViewController: BaseViewController {
    private let memberProfileInfoType: ProfileInfoType
    private let userInterface: MemberProfileInfoComposingUserInterfaceView
    private let composingUseCaseFactory: ComposingMemberProfileInfoUseCaseFactory

    init(
        memberProfileInfoType: ProfileInfoType,
        userInterface: MemberProfileInfoComposingUserInterfaceView,
        composingUseCaseFactory: ComposingMemberProfileInfoUseCaseFactory
    ) {
        self.memberProfileInfoType = memberProfileInfoType
        self.userInterface = userInterface
        self.composingUseCaseFactory = composingUseCaseFactory

        super.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Finish", comment: "Finish"), style: .done, target: self, action: #selector(finishButtonTapped(_:)))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = userInterface
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = memberProfileInfoType.description

        userInterface.render(memberProfileInfoType: memberProfileInfoType)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        userInterface.didAppear()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension MemberProfileInfoComposingViewController {

    @objc func finishButtonTapped(_ sender: Any) {
        let editedInfoType: ProfileInfoType = userInterface.composedMemberProfileInfo(for: memberProfileInfoType)
        composingUseCaseFactory.makeComposingMemberProfileInfoUseCase(profileInfoType: editedInfoType).start()

        navigationController?.popViewController(animated: true)
    }

}

extension MemberProfileInfoComposingViewController: MemberProfileInfoComposingIxResponder {

}

extension MemberProfileInfoComposingViewController: ObserverForMemberProfileInfoComposingEventResponder {

}

protocol MemberProfileInfoComposingViewControllerFactory {

}
