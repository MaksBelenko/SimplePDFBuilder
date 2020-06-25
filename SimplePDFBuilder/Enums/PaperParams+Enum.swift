//
//  PaperParams+Ext.swift
//  SimplePDFBuilder
//
//  Created by MaksBelenko on 25/06/2020.
//
//  MIT License
//  Copyright (c) 2020 MaksBelenko
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


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
