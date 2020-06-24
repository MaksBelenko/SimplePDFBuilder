//
//  Enums.swift
//  PaymentsPDF
//
//  Created by Maksim on 06/04/2020.
//  Copyright © 2020 Maksim. All rights reserved.
//


import UIKit.UIFont

public enum Alignment {
    case left, centre, right
}


internal extension Alignment {
    func nsTextAlignment() -> NSTextAlignment {
        switch self {
        case .left:
            return .left
        case .centre:
            return .center
        case .right:
            return .right
        }
    }
}
