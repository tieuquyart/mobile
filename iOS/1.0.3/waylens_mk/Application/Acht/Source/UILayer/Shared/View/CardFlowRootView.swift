//
//  CardFlowRootView.swift
//  Acht
//
//  Created by forkon on 2019/11/20.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class CardFlowRootView: UIView {
    private(set) var cardFlowView = CardFlowView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func configCardFlowView(_ cardFlowView: CardFlowView) {
        cardFlowView.frame = bounds
        cardFlowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        cardFlowView.topMargin = 30.0
        cardFlowView.bottomMargin = 30.0

        cardFlowView.backgroundColor = UIColor.clear
    }

}

//MARK: - Private

private extension CardFlowRootView {

    func setup() {
        backgroundColor = UIColor.semanticColor(.background(.secondary))

        setupCardFlow()
    }

    func setupCardFlow() {
        guard cardFlowView.superview == nil else { return }
        configCardFlowView(cardFlowView)
        addSubview(cardFlowView)
    }

}
