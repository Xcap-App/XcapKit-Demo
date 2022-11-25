//
//  TriangleRenderer.swift
//  XcapViewApp
//
//  Created by scchn on 2022/11/4.
//

import Foundation

import XcapKit

class TriangleRenderer: ObjectRenderer, Editable {
    
    override var layoutAction: ObjectRenderer.LayoutAction {
        .singleSection(withNumberOfItems: 3, for: layout)
    }
    
    override var preliminaryGraphicsDrawingStrategy: ObjectRenderer.DrawingStrategy {
        .unfinished
    }
    
    override func makePreliminaryGraphics() -> [Drawable] {
        guard let items = layout.first else {
            return []
        }
        
        let lineDash = PathGraphicsRenderer.LineDash(phase: 4, lengths: [4])
        let renderer = PathGraphicsRenderer(method: .stroke(lineWidth: lineWidth, lineDash: lineDash), color: strokeColor) { path in
            path.addLines(between: items)
            path.closeSubpath()
        }
        
        return [renderer]
    }
    
    override func makeMainGraphics() -> [Drawable] {
        guard let items = layout.first else {
            return []
        }
        
        let renderer = PathGraphicsRenderer(method: .stroke(lineWidth: lineWidth), color: strokeColor) { path in
            path.addLines(between: items)
            path.closeSubpath()
        }
        
        return [renderer]
    }
    
    override func selectionTest(rect: CGRect) -> Bool {
        guard let items = layout.first else {
            return false
        }
        return SelectionUtil(rect).selects(linesBetween: items, isClosed: true)
    }
    
}
