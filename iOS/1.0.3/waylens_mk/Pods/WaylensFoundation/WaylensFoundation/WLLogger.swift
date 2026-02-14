//
//  WLLogger.swift
//  Acht
//
//  Created by Chester Shen on 8/14/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
import CocoaLumberjack

public struct Log {
    public static func setup() {
        DDLog.add(DDTTYLogger.sharedInstance!, with:.debug)
        WLLogUtil.redirectNSlogToDocumentFolder()
    }

    public static func setupForDebug() {
        DDLog.add(DDTTYLogger.sharedInstance!, with:.verbose)
        WLLogUtil.redirectNSlogToDocumentFolder()
    }

    public static func verbose(_ message: String) {
        DDLogVerbose(message)
    }

    public static func debug(_ message: String) {
        DDLogDebug(message)
    }

    public static func info(_ message: String) {
        DDLogInfo(message)
    }

    public static func warn(_ message: String) {
        DDLogWarn(message)
    }

    public static func error(_ message: String) {
        DDLogError(message)
    }
}
