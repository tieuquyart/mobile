//
//  WLStatefulViewController.swift
//  Fleet
//
//  Created by forkon on 2020/2/11.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit
import StatefulViewController

protocol WLStatefulView: StatefulViewController {
    func setupStatefulView(with loadingView: UIView?/*, emptyView: UIView? = nil, errorView: UIView? = nil*/)
}

private var hasFinishedFirstLoadingKey: UInt8 = 8

extension WLStatefulView {

    private var defaultLoadingView: WLLoadingView {
        return UINib(nibName: String(describing: WLLoadingView.self), bundle: nil).instantiate(withOwner: nil, options: nil).first as! WLLoadingView
    }

    var hasFinishedFirstLoading: Bool {
        set {
            objc_setAssociatedObject(self, &hasFinishedFirstLoadingKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return (objc_getAssociatedObject(self, &hasFinishedFirstLoadingKey) as? Bool) ?? false
        }
    }

    func setupStatefulView(with loadingView: UIView? = nil/*, emptyView: UIView? = nil, errorView: UIView? = nil*/) {
        self.loadingView = loadingView

        if self.loadingView == nil {
            self.loadingView = defaultLoadingView
        }

        setupInitialViewState()
    }

    func hasContent() -> Bool {
        return hasFinishedFirstLoading
    }

}

protocol StatefulViewState: CaseIterable, RawRepresentable {
    var stateView: UIView { get }
}

enum DefaultStatefulViewState: String, StatefulViewState {
    case content
    case loading
    case error
    case empty

    var stateView: UIView {
        switch self {
        case .content:
            return UIView()
        case .loading:
            return UIView()
        case .error:
            return UIView()
        case .empty:
            return UIView()
        }
    }
}

protocol StatefulView: UIView {
    func transition<S: StatefulViewState>(to newState: S, with stateViewConfigurator: ((UIView) -> Void)? , animated: Bool)
}

private struct AssociatedKeys {
    static var viewStateMachine: UInt8 = 0
}

extension StatefulView {

    private var viewStateMachine: ViewStateMachine {
        return associatedObject(self, key: &AssociatedKeys.viewStateMachine) { [unowned self] in
            return ViewStateMachine(view: self)
        }
    }

    func transition<S: StatefulViewState>(to newState: S, with stateViewConfigurator: ((UIView) -> ())? = nil, animated: Bool) {
        if viewStateMachine[newState.rawValue as! String] == nil {
            viewStateMachine[newState.rawValue as! String] = newState.stateView
        }

        stateViewConfigurator?(viewStateMachine[newState.rawValue as! String]!)

        viewStateMachine.transitionToState(.view(newState.rawValue as! String), animated: animated)
    }

}
