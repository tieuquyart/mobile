//
//  TextFieldRestrictor.swift
//  Fleet
//
//  Created by forkon on 2020/3/19.
//  Copyright © 2020 waylens. All rights reserved.
//

typealias TextFieldRestrictor = (String) -> (String)

private func uppercaseAlphanumericRestrictor(_ input: String) -> String {
    return String(input.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) }).uppercased()
}

private func decimalDigitRestrictor(_ input: String) -> String {
    return String(input.unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) })
}

private func numberOfCharactersLimitRestrictor(limit: Int) -> TextFieldRestrictor {
    func restrictor(_ input: String) -> String {
        let from = input.startIndex

        if let to = input.index(from, offsetBy: limit, limitedBy: input.endIndex) {
            return String(input[input.startIndex..<to])
        }
        else {
            return input
        }
    }

    return restrictor
}

private func numericalRangeRestrictor(max: Double) -> TextFieldRestrictor {
    func restrictor(_ input: String) -> String {
        if var range = Double(input) {
            if range > max {
                var inputCopy = input

                while range > max {
                    _ = inputCopy.popLast()

                    if inputCopy.last == "." {
                        _ = inputCopy.popLast()
                    }

                    range = Double(inputCopy) ?? 0
                }

                return inputCopy
            }
            else {
                return input
            }
        }
        else {
            return "0"
        }
    }

    return restrictor
}

private func nonWhitespacesRestrictor(_ input: String) -> String {
    return String(input.unicodeScalars.filter { !CharacterSet.whitespaces.contains($0) })
}

class TextFieldRestrictorFactory {
    static func makeUppercaseAlphanumericRestrictor() -> TextFieldRestrictor {
        return uppercaseAlphanumericRestrictor
    }

    static func makeDecimalDigitRestrictor() -> TextFieldRestrictor {
        return decimalDigitRestrictor
    }

    static func makeNumericalRangeRestrictor(max: Double) -> TextFieldRestrictor {
        return numericalRangeRestrictor(max: max)
    }

    static func makeNumberOfCharactersLimitRestrictor(limit: Int) -> TextFieldRestrictor {
        return numberOfCharactersLimitRestrictor(limit: limit)
    }

    static func makeNonWhitespacesRestrictor() -> TextFieldRestrictor {
        return nonWhitespacesRestrictor
    }
}

extension UITextField {
    private struct AssociatedKeys {
        static var restrictor: UInt8 = 0
    }

    var restrictor: TextFieldRestrictor? {
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.restrictor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            if newValue != nil {
                addTarget(self, action: #selector(editingDidChange), for: UIControl.Event.editingChanged)
            } else {
                removeTarget(self, action: #selector(editingDidChange), for: UIControl.Event.editingChanged)
            }
        }
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.restrictor) as? TextFieldRestrictor
        }
    }

    @objc private func editingDidChange() {
        if let text = text, !text.isEmpty {
            self.text = restrictor?(text)
        }
    }
}
