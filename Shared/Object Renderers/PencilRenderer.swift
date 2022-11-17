//
//  PencilRenderer.swift
//  XcapViewApp
//
//  Created by scchn on 2022/11/7.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

import XcapKit

class PencilRenderer: ObjectRenderer {
    
    override var layoutAction: ObjectRenderer.LayoutAction {
        layout.isEmpty ? .push(finishable: false) : .continuousPushThenFinish
    }
    
    override var preliminaryGraphicsDrawingStrategy: ObjectRenderer.DrawingStrategy {
        []
    }
    
    override func makeMainGraphics() -> [Drawable] {
        let renderer = PathGraphicsRenderer(method: .stroke(lineWidth: lineWidth), color: strokeColor) { path in
            for points in layout {
                let subpath = CGMutablePath()
                
                for (index, point) in points.enumerated() where points.count > 1 {
                    var previousPreviousPoint = points.first!
                    var previousPoint = points.first!
                    let currentPoint = point
                    
                    if index >= 3 {
                        previousPreviousPoint = points[index - 2]
                    }
                    
                    if index >= 2 {
                        previousPoint = points[index - 1]
                    }
                    
                    let mid1 = previousPoint.mid(with: previousPreviousPoint)
                    let mid2 = currentPoint.mid(with: previousPoint)
                    
                    subpath.move(to: mid1)
                    subpath.addQuadCurve(to: mid2, control: previousPoint)
                }
                
                path.addPath(subpath)
            }
        }
        
        return [renderer]
    }
    
}
