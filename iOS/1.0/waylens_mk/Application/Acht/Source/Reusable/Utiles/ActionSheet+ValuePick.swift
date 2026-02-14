//
//  ActionSheet+ValuePick.swift
//  Acht
//
//  Created by forkon on 2019/2/20.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showPicker(withValues values: [String], message: String? = nil, didPickHandler pickHandler: @escaping (Int) -> ()) {
        let sheet = UIAlertController(title: nil, message: message, preferredStyle: .actionSheetOrAlertOnPad)
        
        for (i, value) in values.enumerated() {
            let action = UIAlertAction(title: value, style: .default, handler: { (alertAction) in
                pickHandler(i)
            })
            sheet.addAction(action)
        }
        
        let cancelActon = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        sheet.addAction(cancelActon)
        
        present(sheet, animated: true, completion: nil)
    }
    
}
