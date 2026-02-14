//
//  String+Extensions.swift
//  Acht
//
//  Created by forkon on 2019/2/20.
//  Copyright © 2019 waylens. All rights reserved.
//

extension String: WaylensSpacable {}

public extension WaylensSpace where Base == String {

    func capitalizingFirstLetter() -> String {
     //   print("thanh base string" , self.base)
        let value = self.base.prefix(1).uppercased() + self.base.dropFirst()
     //   print("thanh base edit string" , value)
        return value
    }

    /// Turn the camel case into title case.
    /// Example: "titleCase" -> "Title Case"
    func titleCase() -> String {
        return self.base
            .replacingOccurrences(of: "([A-Z])",
                                  with: " $1",
                                  options: .regularExpression,
                                  range: self.base.range(of: self.base))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized // If input is in llamaCase
    }

    func mutableAttributed(with attributes: [NSAttributedString.Key : Any]?) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: base, attributes: attributes)
    }

    func numberInSecondsString() -> Int? {
        return Int(String(base[base.startIndex..<base.endIndex]))
    }

}

public extension String {
    
    mutating func capitalizeFirstLetter() {
        self = wl.capitalizingFirstLetter()
    }

    mutating func addHttpSchemePrefixIfNeeded() {
        if !(hasPrefix("http://") || hasPrefix("https://")) {
            self = "http://" + self
        }
    }
    
}

extension NSMutableAttributedString {
    
    public func addAttributes(_ attributes: [NSAttributedString.Key : Any], for substring: String) -> NSMutableAttributedString {
        if let range = string.range(of: substring) {
            addAttributes(attributes, range: NSRange(range, in: string))
        }
        return self
    }
    
}
