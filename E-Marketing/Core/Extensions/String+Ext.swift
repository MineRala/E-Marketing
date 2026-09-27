//
//  String+Localized.swift
//  E-Marketing
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: "")
    }
}
