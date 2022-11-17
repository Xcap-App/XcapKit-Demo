//
//  CirclrRenderer.swift
//  XcapViewApp
//
//  Created by scchn on 2022/11/7.
//

import Foundation
import CoreGraphics

import XcapKit

class CircleRenderer: ObjectRenderer, Editable {
    
    private var circle: Circle?
    
    override var layoutAction: ObjectRenderer.LayoutAction {
        layout.first?.count != 3 ? .push(finishable: false) : .finish
    }
    
    override func layoutDidUpdate() {
        guard let items = layout.first, items.count == 3 else {
            return
        }
        circle = Circle(items[0], items[1], items[2])
    }
    
    override func makeMainGraphics() -> [Drawable] {
        guard let circle = circle else {
            return []
        }
        
        let circleRenderer = PathGraphicsRenderer(method: .stroke(lineWidth: lineWidth), color: strokeColor) { path in
            path.addCircle(circle)
        }
        
        return [circleRenderer]
    }
    
    override func selectionTest(rect: CGRect) -> Bool {
        guard let circle = circle else {
            return false
        }
        return SelectionUtil(rect).selects(circle)
    }
    
}
