//
//  Localized.swift
//  SwiftUI-App-Boilerplate
//
//  Created by Arek on 03/11/2022.
//  Copyright © 2022 Nifty Orchard. All rights reserved.
//

import Foundation

public func localized(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

public func localized(format key: String, arguments: [String]) -> String {
    String(format: localized(key), arguments: arguments)
}

public func localized(format key: String, arguments: [LosslessStringConvertible]) -> String {
    String(
        format: localized(key),
        arguments: arguments.map { String($0) }
    )
}
