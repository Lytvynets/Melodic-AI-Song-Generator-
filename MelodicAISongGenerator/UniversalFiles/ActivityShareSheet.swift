//
//  ActivityShareSheet.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 15.08.2026.
//

import Foundation
import SwiftUI

struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
