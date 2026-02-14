//
//  BaseCardFlowViewController.swift
//  Fleet
//
//  Created by forkon on 2019/10/16.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class BaseCardFlowViewController: BaseViewController, CardFlowViewDataSource {
    private(set) var cardFlowView = CardFlowView()

    override func viewDidLoad() {
        super.viewDidLoad()

       setupCardFlow()
    }

    override func applyTheme() {
        super.applyTheme()
        view.backgroundColor = UIColor.semanticColor(.cardBackground)
    }

    open func addAdditionalConfig(to cardFlowView: CardFlowView) {

    }

    public func numberOfCards(in cardFlowView: CardFlowView) -> Int {
        return 0
    }

    func card(at index: Int, in cardFlowView: CardFlowView) -> CardFlowViewCard {
        return CardFlowViewCard(contentView: UIView())
    }

}

//MARK: - Private

private extension BaseCardFlowViewController {

    private func setupCardFlow() {
        guard cardFlowView.superview == nil else { return }

        cardFlowView.frame = view.bounds
        cardFlowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cardFlowView.center = view.center
        cardFlowView.dataSource = self

        cardFlowView.topMargin = 30.0
        cardFlowView.bottomMargin = 0.0

       

        addAdditionalConfig(to: cardFlowView)

        view.addSubview(cardFlowView)
        cardFlowView.reloadData()
    }

}
