//
//  PersonnelManagementViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class PersonnelManagementViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: PersonnelManagementUserInterfaceView
    private let viewControllerFactory: PersonnelManagementViewControllerFactory
    private let loadMemberListUseCaseFactory: LoadMemberListUseCaseFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory

    init(
        observer: Observer,
        userInterface: PersonnelManagementUserInterfaceView,
        loadMemberListUseCaseFactory: LoadMemberListUseCaseFactory,
        viewControllerFactory: PersonnelManagementViewControllerFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.loadMemberListUseCaseFactory = loadMemberListUseCaseFactory
        self.viewControllerFactory = viewControllerFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = userInterface
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Personnel Management", comment: "Personnel Management")
        
        observer.startObserving()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadMemberListUseCaseFactory.makeLoadMemberListUseCase().start()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

extension PersonnelManagementViewController: PersonnelManagementIxResponder {

    func presentAddNewMember() {
        let vc = viewControllerFactory.makeMemberViewController(with: nil).embedInNavigationController()

        if #available(iOS 13.0, *) {
            vc.modalPresentationStyle = .fullScreen
        }

        present(vc, animated: true, completion: nil)
    }

    func showDetail(for member: FleetMember) {
      //let vc = viewControllerFactory.makeMemberViewController(with: member)
        let vc = MemberController()
        vc.member = member
       navigationController?.pushViewController(vc, animated: true)
    }

}

extension PersonnelManagementViewController: ObserverForPersonnelManagementEventResponder {

    func received(newState: PersonnelManagementViewControllerState) {
        userInterface.render(newState: newState)
    }

    func received(newErrorMessage: ErrorMessage) {
        alert(title: newErrorMessage.title, message: newErrorMessage.message, action1: { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { [weak self] (action) in
                self?.makeFinishedPresentingErrorUseCase(newErrorMessage).start()
            })
        })
    }
    
}

protocol PersonnelManagementViewControllerFactory {
    func makeMemberViewController(with member: FleetMember?) -> UIViewController
}
