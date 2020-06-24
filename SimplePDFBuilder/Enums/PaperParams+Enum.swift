//
//  PaperParams+Ext.swift
//  SimplePDFBuilder
//
//  Created by Maksim on 22/06/2020.
//  Copyright © 2020 Maksim Belenko. All rights reserved.
//


public enum PaperSize {
    case A1, A2, A3, A4, A5, A6, A7
}


public enum PaperOrientation {
    case Portrait, Album
}


public enum PaperMargins {
    ///Inch (2.54cm) on each side
    case Normal
    ///Half inch (1.27cm) on each side
    case Narrow
    ///Inch (2.54cm) for top and bottom and 0.75 inch (or 1.91 cm) for left and right
    case Moderate
    ///Inch (2.54cm) for top and bottom and 2 inches (5.08 cm) for left and right
    case Wide
}
