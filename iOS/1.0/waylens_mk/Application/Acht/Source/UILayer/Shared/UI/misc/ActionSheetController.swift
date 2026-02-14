//
//  ActionSheetController.swift
//  Acht
//
//  Created by forkon on 2019/4/28.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class ActionSheetController: UIViewController {
    private struct Configuration {
        var margin: CGFloat
        var defaultActionCellHeight: CGFloat
        var separatorInset: UIEdgeInsets
    }

    enum ActionGroup {
        case defaultActions
        case deleteAction
        case cancelAction
    }

    private lazy var backgroundView: UIView = {[unowned self] in
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = self.backgroundColor
        backgroundView.isUserInteractionEnabled = true
        return backgroundView
    }()
    private lazy var tableView: UITableView = {[unowned self] in
        let tableView = UITableView(frame: self.backgroundView.bounds, style: .plain)
        tableView.alwaysBounceVertical = false
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor.semanticColor(.separator(.custom(color: UIColor(rgb: 0x99A0A9))))
        tableView.separatorInset = self.configuration.separatorInset
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.removeSeparatorOnLastCell()
        return tableView
    }()
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8.0
        return stackView
    }()
    private lazy var configuration: Configuration = {
        let configuration = Configuration(
            margin: 8.0,
            defaultActionCellHeight: 56.0,
            separatorInset: UIEdgeInsets(top: 0.0, left: 13.0, bottom: 0.0, right: 13.0)
        )
        return configuration
    }()

    private let actions: [ActionSheetAction]
    private let defaultActions: [ActionSheetAction]
    private let destructiveActions: [ActionSheetAction]
    private let cancelActions: [ActionSheetAction]

    var backgroundColor: UIColor = UIColor.semanticColor(.background(.senary)).withAlphaComponent(0.95) {
        didSet {
            backgroundView.backgroundColor = backgroundColor
        }
    }
    var dimmingViewBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.6)
    var dimBackground: Bool = false
    var accessoryView: UIView? = nil

    init(title: String?, actions: [ActionSheetAction]) {
        self.actions = actions
        self.defaultActions = actions.filter{$0.style == .default}
        self.destructiveActions = actions.filter{$0.style == .destructive}
        self.cancelActions = actions.filter{$0.style == .cancel}
        super.init(nibName: nil, bundle: nil)

        self.title = title

        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        accessoryView?.removeFromSuperview()
        accessoryView = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapDimmingBackground))
        tapGestureRecognizer.delaysTouchesBegan   = false
        tapGestureRecognizer.delegate             = self
        view.addGestureRecognizer(tapGestureRecognizer)

        view.backgroundColor = UIColor.clear

        view.addSubview(backgroundView)
        view.addSubview(stackView)

        if let accessoryView = accessoryView {
            accessoryView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(accessoryView)
            accessoryView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
            accessoryView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        }

        if title?.isEmpty == false {
            let headerLabel = UILabel()
            headerLabel.font = UIFont.systemFont(ofSize: 12.0)
            headerLabel.numberOfLines = 0
            headerLabel.textColor = UIColor.semanticColor(.label(.primary))
            headerLabel.textAlignment = .center
            headerLabel.text = title
            headerLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 36.0).isActive = true
            stackView.addArrangedSubview(headerLabel)
        }

        let margin = configuration.margin
        let width = UIScreen.main.bounds.width - margin * 2

        tableView.register(ActionSheetCell.self, forCellReuseIdentifier: "Cell")
        tableView.heightAnchor.constraint(equalToConstant: configuration.defaultActionCellHeight * CGFloat(defaultActions.count)).isActive = true
        tableView.widthAnchor.constraint(equalToConstant: width).isActive = true
        stackView.addArrangedSubview(tableView)

        destructiveActions.forEach { (action) in
            let destructiveButton = UIButton(type: UIButton.ButtonType.custom)
            destructiveButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .light)
            destructiveButton.setTitle(action.title, for: .normal)
            destructiveButton.setTitleColor(UIColor.semanticColor(.label(.tertiary)), for: .normal)
            destructiveButton.setBackgroundImage(with: UIColor.black.withAlphaComponent(0.18), for: UIControl.State.normal)
            destructiveButton.setBackgroundImage(with: UIColor.black.withAlphaComponent(0.28), for: UIControl.State.highlighted)
            destructiveButton.layer.cornerRadius = 3.0
            destructiveButton.clipsToBounds = true

            destructiveButton.addTarget(self, action: #selector(destructiveButtonTapped(_:)), for: UIControl.Event.touchUpInside)

            destructiveButton.widthAnchor.constraint(equalToConstant: width).isActive = true
            destructiveButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true

            stackView.addArrangedSubview(destructiveButton)
        }

        for (i, action) in cancelActions.enumerated() {
            let cancelButton = UIButton(type: UIButton.ButtonType.custom)
            cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .light)
            cancelButton.setTitle(action.title, for: .normal)
            cancelButton.setTitleColor(UIColor.white, for: .normal)
            cancelButton.setBackgroundImage(with: UIColor.white.withAlphaComponent(0.18), for: UIControl.State.normal)
            cancelButton.setBackgroundImage(with: UIColor.white.withAlphaComponent(0.10), for: UIControl.State.highlighted)
            cancelButton.layer.cornerRadius = 3.0
            cancelButton.clipsToBounds = true
            cancelButton.tag = i

            cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: UIControl.Event.touchUpInside)

            cancelButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
            cancelButton.widthAnchor.constraint(equalToConstant: width).isActive = true

            stackView.addArrangedSubview(cancelButton)
        }

        stackView.systemLayoutSizeFitting(CGSize.zero)

        stackView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 70.0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -margin).isActive = true

        backgroundView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -margin).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let presentingViewController = presentingViewController {
            return presentingViewController.supportedInterfaceOrientations
        } else {
            return super.supportedInterfaceOrientations
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if (traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass)
            || (traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass) {
            // your custom implementation here
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

}

private extension ActionSheetController {

    @objc func tapDimmingBackground() {
        if let lastCancelAction = cancelActions.last {
            lastCancelAction.handler?(lastCancelAction)
            dismiss(animated: true, completion: nil)
        }
    }

    @objc func destructiveButtonTapped(_ sender: UIButton) {
        let action = destructiveActions[sender.tag]
        action.handler?(action)
        dismiss(animated: true, completion: nil)
    }

    @objc func cancelButtonTapped(_ sender: UIButton) {
        let action = cancelActions[sender.tag]
        action.handler?(action)
        dismiss(animated: true, completion: nil)
    }
}

extension ActionSheetController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchLocation = touch.location(in: self.view)
        if backgroundView.frame.contains(touchLocation) {
            return false
        } else {
            return true
        }
    }

}

extension ActionSheetController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return defaultActions.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ActionSheetCell

        let action = defaultActions[indexPath.row]
        cell.action = action
        cell.separatorInset = configuration.separatorInset

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let action = defaultActions[indexPath.row]
        action.handler?(action)
    }

}

extension ActionSheetController: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = ActionSheetPresentationController(presentedViewController: presented, presenting: presenting)
        controller.dimmingViewBackgroundColor = dimBackground ? dimmingViewBackgroundColor : UIColor.clear
        return controller
    }

}

class ActionSheetAction {
    enum Style : Int {
        case `default`
        case cancel
        case destructive
    }

    private(set) var title: String?
    private(set) var images: [UIImage]
    private(set) var style: ActionSheetAction.Style
    private(set) var handler: ((ActionSheetAction) -> Void)?

    init(title: String?, style: ActionSheetAction.Style, handler: ((ActionSheetAction) -> Void)? = nil) {
        self.title = title
        self.images = []
        self.style = style
        self.handler = handler
    }

    init(title: String?, images: [UIImage], handler: ((ActionSheetAction) -> Void)? = nil) {
        self.title = title
        self.images = images
        self.style = .default
        self.handler = handler
    }
}

extension ActionSheetAction {

    class func deleteAction(handler: ((ActionSheetAction) -> Void)? = nil) -> ActionSheetAction {
        return ActionSheetAction(title: NSLocalizedString("Delete", comment: "Delete"), style: .destructive, handler: handler)
    }

    class func cancelAction(handler: ((ActionSheetAction) -> Void)? = nil) -> ActionSheetAction {
        return ActionSheetAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: handler)
    }

}

private class ActionSheetCell: UITableViewCell {
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8.0
        return stackView
    }()
    private var stackViewTrailingConstraint: NSLayoutConstraint!

    private var customTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .light)
        textLabel.textColor = UIColor.white
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    private var customTextLabelLeadingConstraint: NSLayoutConstraint!

    var action: ActionSheetAction? {
        didSet {
            updateUI(with: action)
        }
    }

    override var separatorInset: UIEdgeInsets {
        didSet {
            setNeedsUpdateConstraints()
            updateConstraints()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()

        customTextLabelLeadingConstraint.constant = separatorInset.left + 26.0
        stackViewTrailingConstraint.constant = -(separatorInset.right + 6.0)
    }

    private func updateUI(with action: ActionSheetAction?) {
        stackView.removeAllArrangedSubviews()

        action?.images.forEach({ (image) in
            let imageView = UIImageView()
            imageView.setTemplateImage(image, color: UIColor.semanticColor(.label(.primary)))
            imageView.contentMode = .center
            imageView.widthAnchor.constraint(equalToConstant: 22.0).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
            stackView.addArrangedSubview(imageView)
        })

        customTextLabel.text = action?.title
    }

    private func setup() {
        backgroundColor = UIColor.clear

        let selectedBgView = UIView()
        selectedBgView.backgroundColor = UIColor.black.withAlphaComponent(0.20)
        selectedBgView.layer.cornerRadius = 3.0
        selectedBackgroundView = selectedBgView

        addSubview(stackView)
        addSubview(customTextLabel)

        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackViewTrailingConstraint = stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0)
        stackViewTrailingConstraint.isActive = true

        customTextLabelLeadingConstraint = customTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0)
        customTextLabelLeadingConstraint.isActive = true
        customTextLabel.trailingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -10.0).isActive = true
        customTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0.0).isActive = true
        customTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0).isActive = true
    }
}

private class ActionSheetPresentationController: UIPresentationController {

    var dimmingViewBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.6) {
        didSet {
            dimmingView.backgroundColor = dimmingViewBackgroundColor
        }
    }

    lazy var dimmingView: UIView = {[weak self] in
        let dimmingView = UIView(frame: self?.containerView?.bounds ?? CGRect.zero)
        dimmingView.backgroundColor = self?.dimmingViewBackgroundColor
        return dimmingView
    }()

    override var frameOfPresentedViewInContainerView: CGRect {
        return containerView!.frame
    }

    override func containerViewWillLayoutSubviews() {
        dimmingView.frame = containerView!.bounds
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func presentationTransitionWillBegin() {
        let presentedViewControllerView = presentedViewController.view
        presentedViewControllerView?.layer.cornerRadius = 20.0
        presentedViewControllerView?.layer.shadowColor = UIColor.black.cgColor

        dimmingView.frame = containerView!.bounds
        dimmingView.alpha = 0.0
        containerView?.addSubview(dimmingView)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: {[weak self] (viewControllerTransitionCoordinatorContext) in
            self?.dimmingView.alpha = 1.0
        }, completion: nil)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: {[weak self] (viewControllerTransitionCoordinatorContext) in
            self?.dimmingView.alpha = 0.0
        }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
}
