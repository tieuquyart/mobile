//
//  GuideSkipAlertViewController.swift
//  Acht
//
//  Created by Chester Shen on 2/18/19.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

class HNAlertAction {
    enum Style {
        case normal
        case primary
        case cancel
    }
    let title: String
    let style: Style
    let handler: (()->Void)?
    
    init(title: String, style: Style, handler:(()->Void)?=nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

class GuideSkipAlertViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buttonContainer: UIStackView!
    @IBOutlet weak var background: UIView!
    
    var handlers = [(()->Void)?]()
    let tagStartNumber:Int = 1000
    var gradientLayer: CAGradientLayer?
    var image: UIImage? {
        didSet {
            imageView?.image = image
        }
    }
    var text: String? {
        didSet {
            titleLabel?.text = text
        }
    }

    private var presentingWindow: UIWindow? = nil
    
    static func createViewController() -> GuideSkipAlertViewController {
        let vc = GuideSkipAlertViewController(nibName: "GuideSkipAlertViewController", bundle: nil)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        titleLabel.text = text
        view.backgroundColor = .clear
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setGradientLayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = background.bounds
    }
    
    private func setGradientLayer() {
        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            gradientLayer?.frame = background.bounds
            let color3 = UIColor(rgb: 0x1C95EB).cgColor
            let color2 = UIColor(rgb: 0x0F2447, a: 0.9).cgColor
            let color1 = UIColor(rgb: 0x0C102B, a: 0.85).cgColor
            gradientLayer?.colors = [color1, color2, color3]
            gradientLayer?.locations = [0.0, 0.33, 1.0]
            gradientLayer?.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer?.endPoint = CGPoint(x: 0, y: 1)
            UIView.transition(
                with: background,
                duration: 0.6,
                options: .transitionCrossDissolve,
                animations: {
                    self.background.layer.addSublayer(self.gradientLayer!)
            },
                completion: nil
            )
        }
        if gradientLayer?.frame != background.bounds {
            gradientLayer?.frame = background.bounds
        }
    }
    
    private func buttonFor(action: HNAlertAction) -> UIButton {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle(action.title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        switch action.style {
        case .cancel:
            btn.backgroundColor = .clear
            btn.setTitleColor(UIColor.semanticColor(.label(.primary)), for: .normal)
        case .normal:
            btn.backgroundColor = .white
            btn.setTitleColor(UIColor.semanticColor(.label(.primary)), for: .normal)
            btn.layer.cornerRadius = 2
            btn.layer.borderColor = UIColor.semanticColor(.border(.primary)).cgColor
            btn.layer.borderWidth = 1
            btn.layer.masksToBounds = true
        default:
            btn.backgroundColor = UIColor.semanticColor(.tint(.primary))
            btn.setTitleColor(.white, for: .normal)
            btn.layer.cornerRadius = 2
            btn.layer.masksToBounds = true
        }
        btn.addTarget(self, action: #selector(onTapButton(_:)), for: .touchUpInside)
        btn.tag = tagStartNumber + handlers.count
        handlers.append(action.handler)
        return btn
    }

    func addActionsInRow(_ actions: [HNAlertAction]) {
        loadViewIfNeeded()
        let row = UIStackView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        for action in actions {
            row.addArrangedSubview(buttonFor(action: action))
        }
        row.spacing = 16
        row.distribution = .fillEqually
        buttonContainer.addArrangedSubview(row)
        row.heightAnchor.constraint(equalToConstant: 36).isActive = true
        row.widthAnchor.constraint(equalTo: buttonContainer.widthAnchor, constant: actions.count > 1 ? 0: -32).isActive = true
    }
    
    func addAction(_ action: HNAlertAction) {
        loadViewIfNeeded()
        let btn = buttonFor(action: action)
        buttonContainer.addArrangedSubview(btn)
        btn.widthAnchor.constraint(equalTo: buttonContainer.widthAnchor, constant: -32).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }

    @objc func onTapButton(_ button: UIButton) {
        let index = button.tag - tagStartNumber
        if index>=0 && index<handlers.count {
            dismiss(animated: true, completion: { [weak self] in
                self?.presentingWindow = nil
            })
            handlers[index]?()
        }
    }
    
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        win.rootViewController = vc
        vc.view.backgroundColor = .clear
        win.windowLevel = UIWindow.Level.alert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
        
        presentingWindow = win
    }
}
