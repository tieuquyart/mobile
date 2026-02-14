//
//  LocationPickerContentViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/31.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class LocationPickerContentViewController: BaseViewController {
    private let observer: Observer
    private let userInterface: LocationPickerUserInterfaceView
    private let viewControllerFactory: LocationPickerContentViewControllerFactory
    private let makeFinishedPresentingErrorUseCase: FinishedPresentingErrorUseCaseFactory
    private let searchLocationUseCaseFactory: SearchLocationUseCaseFactory
    private let selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory

    private lazy var searchBar: UISearchBar = { [weak self] in
        let searchBar = UISearchBar()
        searchBar.placeholder = NSLocalizedString("Search a location", comment: "Search a location")
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        return searchBar
    }()

    init(
        observer: Observer,
        userInterface: LocationPickerUserInterfaceView,
        viewControllerFactory: LocationPickerContentViewControllerFactory,
        searchLocationUseCaseFactory: SearchLocationUseCaseFactory,
        selectorSelectUseCaseFactory: SelectorSelectUseCaseFactory,
        makeFinishedPresentingErrorUseCase: @escaping FinishedPresentingErrorUseCaseFactory
    ) {
        self.observer = observer
        self.userInterface = userInterface
        self.viewControllerFactory = viewControllerFactory
        self.searchLocationUseCaseFactory = searchLocationUseCaseFactory
        self.selectorSelectUseCaseFactory = selectorSelectUseCaseFactory
        self.makeFinishedPresentingErrorUseCase = makeFinishedPresentingErrorUseCase

        super.init(nibName: nil, bundle: nil)

        navigationItem.titleView = searchBar
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = userInterface
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        observer.startObserving()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        searchBar.becomeFirstResponder()
    }

    override func applyTheme() {
        super.applyTheme()

        view.backgroundColor = UIColor.semanticColor(.background(.secondary))
    }
}

//MARK: - Private

private extension LocationPickerContentViewController {

}

extension LocationPickerContentViewController: LocationPickerIxResponder {

    func select(indexPath: IndexPath) {
        selectorSelectUseCaseFactory.makeSelectorSelectUseCase(indexPath: indexPath).start()
        dismissMyself(animated: true)
    }

}

extension LocationPickerContentViewController: ObserverForLocationPickerEventResponder {

    func received(newState: LocationPickerViewControllerState) {
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

extension LocationPickerContentViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchLocationUseCaseFactory.makeSearchLocationUseCase(query: searchText).start()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissMyself(animated: true)
    }

}

protocol LocationPickerContentViewControllerFactory {

}
