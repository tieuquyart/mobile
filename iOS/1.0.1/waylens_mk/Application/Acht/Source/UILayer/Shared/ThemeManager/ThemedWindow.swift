//
//  ThemedWindow.swift
//  Acht
//
//  Created by forkon on 2020/3/13.
//  Copyright © 2020 waylens. All rights reserved.
//

import UIKit

open class ThemedWindow: UIWindow {
    public var lightTheme: ThemeProtocol {
        didSet {
            if #available(iOS 13.0, *) {
                switch UITraitCollection.current.userInterfaceStyle {
                case .light, .unspecified: applyCurrentTheme()
                case .dark: break
                @unknown default: applyCurrentTheme()
                }
            } else {
                applyCurrentTheme()
            }
        }
    }

    public var darkTheme: ThemeProtocol {
        didSet {
            guard #available(iOS 13.0, *),
                case .dark = UITraitCollection.current.userInterfaceStyle else { return }
            applyCurrentTheme()
        }
    }

    public var currentTheme: ThemeProtocol {
        if #available(iOS 13.0, *) {
            switch UITraitCollection.current.userInterfaceStyle {
            case .light, .unspecified: return lightTheme
            case .dark: return darkTheme
            @unknown default: return lightTheme
            }
        } else {
            return lightTheme
        }
    }

    public required init(lightTheme: ThemeProtocol, darkTheme: ThemeProtocol) {
        self.lightTheme = lightTheme
        self.darkTheme = darkTheme
        super.init(frame: .zero)

        applyCurrentTheme()
    }

    @available(iOS 13.0, *)
    public required init(lightTheme: ThemeProtocol, darkTheme: ThemeProtocol, windowScene: UIWindowScene) {
        self.lightTheme = lightTheme
        self.darkTheme = darkTheme
        super.init(windowScene: windowScene)

        applyCurrentTheme()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *), UITraitCollection.current.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyCurrentTheme()
        }
    }

    func applyCurrentTheme() {
        ThemeContainer.currentTheme = currentTheme
    }
}
