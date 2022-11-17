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
        layout.first?.count != 2 ? .push(finishable: false) : .finish
    }
    
    override var preliminaryGraphicsDrawingStrategy: ObjectRenderer.DrawingStrategy {
        []
    }
    
}
