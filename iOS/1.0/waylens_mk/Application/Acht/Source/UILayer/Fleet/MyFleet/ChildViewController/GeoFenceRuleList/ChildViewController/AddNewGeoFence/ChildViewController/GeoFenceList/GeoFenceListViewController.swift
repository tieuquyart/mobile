//
//  GeoFenceListViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class GeoFenceListViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: GeoFenceListUserInterfaceView
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let loadGeoFenceListUseCaseFactory: LoadGeoFenceListUseCaseFactory
    private let loadGeoFenceUseCaseFactory: LoadGeoFenceUseCaseFactory
    private let viewControllerFactory: GeoFenceListViewControllerFactory
    private let selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory
    private let removeGeoFenceUseCaseFactory: RemoveGeoFenceUseCaseFactory

    init(
        observer: Observer,
        userInterface: GeoFenceListUserInterfaceView,
        viewControllerFactory: GeoFenceListViewControllerFactory,
        loadGeoFenceListUseCaseFactory: LoadGeoFenceListUseCaseFactory,
        loadGeoFenceUseCaseFactory: LoadGeoFenceUseCaseFactory,
        selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory,
        removeGeoFenceUseCaseFactory: RemoveGeoFenceUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        self.loadGeoFenceListUseCaseFactory = loadGeoFenceListUseCaseFactory
        self.loadGeoFenceUseCaseFactory = loadGeoFenceUseCaseFactory
        self.selectorSelectUseCaseFactory = selectorSelectUseCaseFactory
        self.removeGeoFenceUseCaseFactory = removeGeoFenceUseCaseFactory
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

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
        
        observer.startObserving()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadGeoFenceListUseCaseFactory.makeLoadGeoFenceListUseCase().start()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension GeoFenceListViewController {

}

extension GeoFenceListViewController: GeoFenceListIxResponder {

    func select(indexPath: IndexPath) {
        selectorSelectUseCaseFactory.makeSelectorSelectUseCase(indexPath: indexPath).start()

        if let vc = viewControllerFactory.makeViewController(for: indexPath) {
            if let navVC = vc as? UINavigationController {
                navVC.delegate = self
                navVC.modalPresentationStyle = .fullScreen
                present(navVC, animated: true, completion: nil)
            }
            else {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    func requestGeoFenceShapeDetail(with fenceId: GeoFenceId) {
        loadGeoFenceUseCaseFactory.makeLoadGeoFenceUseCase(geoFenceID: fenceId).start()
    }

    func delete(item: GeoFence) {
        alert(
            title: nil,
            message: String(format: NSLocalizedString("Are you sure to delete \"%@\"?", comment: "Are you sure to delete \"%@\"?"), item.name),
            action1: { () -> UIAlertAction in
                return UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        }) { () -> UIAlertAction in
            return UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete"), style: .destructive, handler: { [weak self] _ in
                self?.removeGeoFenceUseCaseFactory.makeRemoveGeoFenceUseCase(fenceID:item.fenceID, completion: {}).start()
            })
        }
    }

}

extension GeoFenceListViewController: ObserverForGeoFenceListEventResponder {

    func received(newState: GeoFenceListViewControllerState) {
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

extension GeoFenceListViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.title = navigationController.title
    }

}

protocol GeoFenceListViewControllerFactory {
    func makeViewController(for selection: IndexPath) -> UIViewController?
}
