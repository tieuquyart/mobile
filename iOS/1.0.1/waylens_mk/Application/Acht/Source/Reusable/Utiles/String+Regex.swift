//
//  String+Regex.swift
//  Acht
//
//  Created by Chester Shen on 11/2/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation

extension String {

    func isValidPassword() -> Bool {
        let len = self.count
        guard len <= 64, len >= 8 else { return false }
        
        let letterRegex = ".*[a-zA-Z]+.*"
        let letterTest = NSPredicate(format:"SELF MATCHES %@", letterRegex)
        guard letterTest.evaluate(with: self) else { return false }
        
        let digitRegex = ".*[0-9]+.*"
        let digitTest = NSPredicate(format:"SELF MATCHES %@", digitRegex)
        guard digitTest.evaluate(with: self) else { return false }
        
        return true
    }
    
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let test = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard test.evaluate(with: self) else { return false }
        
        return true
    }
    
    func isValidUsername() -> Bool {
        let usernameRegex = "[a-z0-9A-Z_\\.-]+"
        let test = NSPredicate(format:"SELF MATCHES %@", usernameRegex)
        guard test.evaluate(with: self) else { return false }
        return true
    }

    func isValidURL() -> Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: self)
        return result
    }
    
//    func truncate(_ maxLen:Int = 200) -> String {
//        if self.count > maxLen {
//            let half = maxLen / 2
//            return self[...half] + "\n...\n" + self[(self.count - half)...]
//        } else {
//            return self
//        }
//    }
}

