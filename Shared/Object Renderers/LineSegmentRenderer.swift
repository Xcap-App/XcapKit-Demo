//
//  LineSegmentRenderer.swift
//  XcapViewApp
//
//  Created by scchn on 2022/11/4.
//

import Foundation

import XcapKit

class LineSegmentRenderer: ObjectRenderer, Editable {
    
    override var layoutAction: ObjectRenderer.LayoutAction {
        .singleSection(withNumberOfItems: 2, for: layout)
    }
    
    override var preliminaryGraphicsDrawingStrategy: ObjectRenderer.DrawingStrategy {
        []
    }
    
}
