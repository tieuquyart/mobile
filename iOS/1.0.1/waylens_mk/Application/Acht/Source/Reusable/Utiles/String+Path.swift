//
//  String+Path.swift
//  Acht
//
//  Created by Chester Shen on 9/22/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
extension String {
    var pathComponents: [String] {
        return (self as NSString).pathComponents
    }
    
    static func pathWithComponents(components: [String]) -> String {
        return NSString.path(withComponents: components)
    }
    
    func stringWithPathRelativeTo(anchorPath: String) -> String {
        let pathComponents = self.pathComponents
        let anchorComponents = anchorPath.pathComponents
        
        var componentsInCommon = 0
        for (c1, c2) in zip(pathComponents, anchorComponents) {
            if c1 != c2 {
                break
            }
            componentsInCommon += 1
        }
        
        let numberOfParentComponents = anchorComponents.count - componentsInCommon
        let numberOfPathComponents = pathComponents.count - componentsInCommon
        
        var relativeComponents = [String]()
        relativeComponents.reserveCapacity(numberOfParentComponents + numberOfPathComponents)
        for _ in 0..<numberOfParentComponents {
            relativeComponents.append("..")
        }
        relativeComponents.append(contentsOf: pathComponents[componentsInCommon..<pathComponents.count])
        
        return NSString.path(withComponents: relativeComponents)
    }
}
