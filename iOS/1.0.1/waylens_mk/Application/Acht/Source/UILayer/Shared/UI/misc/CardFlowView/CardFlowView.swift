//
//  CardFlowView.swift
//  Acht
//
//  Created by forkon on 2019/10/14.
//  Copyright © 2019 Waylens. All rights reserved.
//

import UIKit

public protocol CardFlowViewDataSource: class {
    func numberOfCards(in cardFlowView: CardFlowView) -> Int
    func card(at index: Int, in cardFlowView: CardFlowView) -> CardFlowViewCard

    // Card Header
    func titleAndSubtitle(at index: Int, in cardFlowView: CardFlowView) -> (NSAttributedString, NSAttributedString?)?
    func headerViewForCard(at index: Int, in cardFlowView: CardFlowView) -> UIView?
}

extension CardFlowViewDataSource {

    public func titleAndSubtitle(at index: Int, in cardFlowView: CardFlowView) -> (NSAttributedString, NSAttributedString?)? {
        return nil
    }

    public func headerViewForCard(at index: Int, in cardFlowView: CardFlowView) -> UIView? {
        return nil
    }

}

public class CardFlowView: UIView, UITableViewDataSource, UITableViewDelegate {
    // MARK: Properties

    public private(set) var cardsContainer = UITableView()

    // MARK: Appearance

    override public var frame: CGRect {
        didSet {
            cardsContainer.frame = bounds
            cardsContainer.estimatedRowHeight = frame.height

            if oldValue == .zero {
                cardsContainer.backgroundColor = .clear
            }
        }
    }

    public var paddingBetweenCards: CGFloat = 20.0 {
        didSet {
            reloadData()
        }
    }

    public var topMargin: CGFloat = 20.0 {
        didSet {
            if cardsContainer.tableHeaderView == nil {
                cardsContainer.tableHeaderView = UIView()
                cardsContainer.tableHeaderView?.backgroundColor = .clear
            }

            cardsContainer.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: 0, height: topMargin)
        }
    }

    public var bottomMargin: CGFloat = 20.0 {
        didSet {
            if cardsContainer.tableFooterView == nil {
                cardsContainer.tableFooterView = UIView()
                cardsContainer.tableFooterView?.backgroundColor = .clear
            }

            cardsContainer.tableFooterView?.frame = CGRect(x: 0, y: 0, width: 0, height: bottomMargin)
        }
    }

    // MARK: Source

    public weak var dataSource: CardFlowViewDataSource? = nil

    // MARK: Delegate

//    public var delegate: TimelineFeedDelegate? = nil

    // MARK: Initializers

    init() {
        super.init(frame: .zero)
        setUpCardsContainer()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUpCardsContainer()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpCardsContainer() {
        backgroundColor = .clear

        cardsContainer.frame = bounds
        cardsContainer.backgroundColor = .clear
        cardsContainer.rowHeight = UITableView.automaticDimension
        cardsContainer.estimatedRowHeight = frame.height

        cardsContainer.dataSource = self
        cardsContainer.delegate = self

        cardsContainer.register(CardFlowViewCell.self, forCellReuseIdentifier: String(describing: CardFlowViewCell.self))
        cardsContainer.showsVerticalScrollIndicator = false

        topMargin = CGFloat(topMargin)
        bottomMargin = CGFloat(bottomMargin)

        addSubview(cardsContainer)
    }

    // MARK: Life cycle

    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
    }

    // MARK: Displaying data

    public func reloadData() {
        guard let _ = dataSource else { return }
        cardsContainer.reloadData()
    }

    public func reloadCard(at index: Int) {
        cardsContainer.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.fade)
    }

    // MARK: UITableViewDataSource

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { return 0 }
        return Int(dataSource.numberOfCards(in: self))
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CardFlowViewCell.self), for: indexPath) as! CardFlowViewCell

        guard let dataSource = dataSource else {
            return cell
        }

        if indexPath.row < Int(dataSource.numberOfCards(in: self) - 1) {
            cell.bottomPadding = paddingBetweenCards
        } else {
            cell.bottomPadding = 0.0
        }

        let card = dataSource.card(at: Int(indexPath.row), in: self)

        if let customHeader = dataSource.headerViewForCard(at: Int(indexPath.row), in: self) {
            customHeader.translatesAutoresizingMaskIntoConstraints = false
            cell.setUp(customHeaderView: customHeader, card: card)
        } else if let headerInfo = dataSource.titleAndSubtitle(at: Int(indexPath.row), in: self) {
            cell.setUp(title: headerInfo.0, subtitle: headerInfo.1, card: card)
        } else {
            cell.setUp(card: card)
        }

        return cell
    }

    // MARK: UITableViewDelegate

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

}
