//
//  AdaptiveFontSize.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 20.08.2026.
//

import Foundation
import UIKit

struct AdaptiveFontSize {
    
    private static var screenSize: CGSize {
        UIScreen.main.bounds.size
    }
    
    private static var screenDiagonal: CGFloat {
        sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2))
    }
    
    private static let referenceDiagonal: CGFloat = 936.18
    
    private static func scale(_ baseSize: CGFloat) -> CGFloat {
        let scalingFactor = screenDiagonal / referenceDiagonal
        return baseSize * scalingFactor
    }
    
    static var adaptive10: CGFloat { scale(10) }
    static var adaptive11: CGFloat { scale(11) }
    static var adaptive12: CGFloat { scale(12) }
    static var adaptive13: CGFloat { scale(13) }
    static var adaptive14: CGFloat { scale(14) }
    static var adaptive15: CGFloat { scale(15) }
    static var adaptive16: CGFloat { scale(16) }
    static var adaptive17: CGFloat { scale(17) }
    static var adaptive18: CGFloat { scale(18) }
    static var adaptive19: CGFloat { scale(19) }
    static var adaptive20: CGFloat { scale(20) }
    static var adaptive21: CGFloat { scale(21) }
    static var adaptive22: CGFloat { scale(22) }
    static var adaptive23: CGFloat { scale(23) }
    static var adaptive24: CGFloat { scale(24) }
    static var adaptive25: CGFloat { scale(25) }
    static var adaptive26: CGFloat { scale(26) }
    static var adaptive27: CGFloat { scale(27) }
    static var adaptive28: CGFloat { scale(28) }
    static var adaptive29: CGFloat { scale(29) }
    static var adaptive30: CGFloat { scale(30) }
    static var adaptive31: CGFloat { scale(31) }
    static var adaptive32: CGFloat { scale(32) }
    static var adaptive33: CGFloat { scale(33) }
    static var adaptive34: CGFloat { scale(34) }
    static var adaptive35: CGFloat { scale(35) }
    static var adaptive36: CGFloat { scale(36) }
    static var adaptive37: CGFloat { scale(37) }
    static var adaptive38: CGFloat { scale(38) }
    static var adaptive39: CGFloat { scale(39) }
    static var adaptive40: CGFloat { scale(40) }
    
    static func adaptive(_ size: CGFloat) -> CGFloat {
        scale(size)
    }
}

