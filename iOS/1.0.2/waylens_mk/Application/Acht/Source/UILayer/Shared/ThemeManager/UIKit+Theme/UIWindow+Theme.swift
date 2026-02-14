//
//  UIWindow+Theme.swift
//  Gaudi
//
//  Created by Giuseppe Lanza on 04/12/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

import UIKit

public extension UIWindow {
    func applyTheme(_ theme: ThemeProtocol) {
        theme.appearanceRules.apply()

        // Whenever UIAppearance changes values, they will not be reflected until the view re-renders itself. By removing and re-adding all the views to their window, you assure they are re-rendered according to the new theme.
        for view in subviews {
            view.removeFromSuperview()
            addSubview(view)
        }

        guard let root = rootViewController else { return }
        UIWindow.traverseViewControllerStackApplyingTheme(from: root)
    }
    
    static func traverseViewControllerStackApplyingTheme(from root: UIViewController) {
        // Standard BFS traversal.
        var queue = Set([root])
        var visited = Set<UIViewController>()
        
        while let controller = queue.first {
            queue.removeFirst()
            visited.insert(controller)
            (controller as? Themed)?.applyTheme()
            controller.children.forEach { queue.insert($0) }
            if let presented = controller.presentedViewController,
                !visited.contains(presented) {
                queue.insert(presented)
            }
        }
    }
}

@objc public extension UIWindow {
    func applyDefaultTheme(overrideLocal: Bool) {
        applyTheme(ThemeContainer.currentTheme)
    }
}
