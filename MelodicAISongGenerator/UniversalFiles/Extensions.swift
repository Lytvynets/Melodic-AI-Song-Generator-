//
//  Extensions.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 20.08.2026.
//

import Foundation
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
