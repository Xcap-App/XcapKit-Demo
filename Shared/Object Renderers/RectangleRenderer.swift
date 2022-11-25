//
//  RectangleRenderer.swift
//  XcapKit-Demo
//
//  Created by scchn on 2022/11/12.
//

import Foundation

import XcapKit

class RectangleRenderer: ObjectRenderer, Editable {
    
    private let itemOrder: [Int] = [0, 1, 2, 3, 7, 4, 5, 6]
    
    private var corners: [CGPoint]? {
        guard canFinish() || isFinished, let points = self.layout.first else {
            return nil
        }
        return itemOrder.map { index in
            points[index]
        }
    }
    
    override var layoutAction: ObjectRenderer.LayoutAction {
        .singleSection(withNumberOfItems: 8, for: layout)
    }
    
    override var preliminaryGraphicsDrawingStrategy: ObjectRenderer.DrawingStrategy {
        []
    }
    
    override func push(_ point: CGPoint) {
        guard let first = layout.first, first.count == 1, let origin = first.first else {
            super.push(point)
            return
        }
        
        let line = Line(start: origin, end: point)
        let dx = line.dx
        let dy = line.dy
        
        super.push(origin.applying(.init(translationX: dx / 2, y: 0)))
        super.push(origin.applying(.init(translationX: dx,     y: 0)))
        super.push(origin.applying(.init(translationX: dx,     y: dy / 2)))
        super.push(origin.applying(.init(translationX: dx / 2, y: dy)))
        super.push(origin.applying(.init(translationX: 0,      y: dy)))
        super.push(origin.applying(.init(translationX: 0,      y: dy / 2)))
        super.push(point)
    }
    
    override func makeMainGraphics() -> [Drawable] {
        guard let corners = corners else {
            return []
        }
        let renderer = PathGraphicsRenderer(method: .stroke(lineWidth: lineWidth), color: strokeColor) { path in
            path.addLines(between: corners)
            path.closeSubpath()
        }
        return [renderer]
    }
    
    override func selectionTest(rect: CGRect) -> Bool {
        guard let items = layout.first, isFinished else {
            return false
        }
        let points = itemOrder.map { items[$0] }
        return SelectionUtil(rect).selects(linesBetween: points, isClosed: true)
    }
    
    override var itemBindings: [ObjectLayout.Position : [ObjectRenderer.ItemBinding]] {
        return [
            .init(item: itemOrder[0], section: 0): [
                .init(position: ObjectLayout.Position(item: itemOrder[7], section: 0), offset: CGPoint(x: 1, y: 0.5)),
                .init(position: ObjectLayout.Position(item: itemOrder[6], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[1], section: 0), offset: CGPoint(x: 0.5, y: 1)),
                .init(position: ObjectLayout.Position(item: itemOrder[5], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[2], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(position: ObjectLayout.Position(item: itemOrder[3], section: 0), offset: CGPoint(x: 0, y: 0.5)),
            ],
            .init(item: itemOrder[2], section: 0): [
                .init(position: ObjectLayout.Position(item: itemOrder[3], section: 0), offset: CGPoint(x: 1, y: 0.5)),
                .init(position: ObjectLayout.Position(item: itemOrder[4], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[1], section: 0), offset: CGPoint(x: 0.5, y: 1)),
                .init(position: ObjectLayout.Position(item: itemOrder[5], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[0], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(position: ObjectLayout.Position(item: itemOrder[7], section: 0), offset: CGPoint(x: 0, y: 0.5)),
            ],
            .init(item: itemOrder[4], section: 0): [
                .init(position: ObjectLayout.Position(item: itemOrder[3], section: 0), offset: CGPoint(x: 1, y: 0.5)),
                .init(position: ObjectLayout.Position(item: itemOrder[2], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[5], section: 0), offset: CGPoint(x: 0.5, y: 1)),
                .init(position: ObjectLayout.Position(item: itemOrder[1], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[6], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(position: ObjectLayout.Position(item: itemOrder[7], section: 0), offset: CGPoint(x: 0, y: 0.5)),
            ],
            .init(item: itemOrder[6], section: 0): [
                .init(position: ObjectLayout.Position(item: itemOrder[7], section: 0), offset: CGPoint(x: 1, y: 0.5)),
                .init(position: ObjectLayout.Position(item: itemOrder[0], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[5], section: 0), offset: CGPoint(x: 0.5, y: 1)),
                .init(position: ObjectLayout.Position(item: itemOrder[1], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[4], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(position: ObjectLayout.Position(item: itemOrder[3], section: 0), offset: CGPoint(x: 0, y: 0.5)),
            ],
            .init(item: itemOrder[3], section: 0): [
                .init(position: ObjectLayout.Position(item: itemOrder[4], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[2], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[1], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[5], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[3], section: 0), offset: CGPoint(x: 0, y: -1)),
            ],
            .init(item: itemOrder[7], section: 0): [
                .init(position: ObjectLayout.Position(item: itemOrder[0], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[6], section: 0), offset: CGPoint(x: 1, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[1], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[5], section: 0), offset: CGPoint(x: 0.5, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[7], section: 0), offset: CGPoint(x: 0, y: -1)),
            ],
            .init(item: itemOrder[1], section: 0): [
                .init(position: ObjectLayout.Position(item: itemOrder[1], section: 0), offset: CGPoint(x: -1, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[0], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(position: ObjectLayout.Position(item: itemOrder[2], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(position: ObjectLayout.Position(item: itemOrder[7], section: 0), offset: CGPoint(x: 0, y: 0.5)),
                .init(position: ObjectLayout.Position(item: itemOrder[3], section: 0), offset: CGPoint(x: 0, y: 0.5)),
            ],
            .init(item: itemOrder[5], section: 0): [
                .init(position: ObjectLayout.Position(item: itemOrder[5], section: 0), offset: CGPoint(x: -1, y: 0)),
                .init(position: ObjectLayout.Position(item: itemOrder[4], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(position: ObjectLayout.Position(item: itemOrder[6], section: 0), offset: CGPoint(x: 0, y: 1)),
                .init(position: ObjectLayout.Position(item: itemOrder[3], section: 0), offset: CGPoint(x: 0, y: 0.5)),
                .init(position: ObjectLayout.Position(item: itemOrder[7], section: 0), offset: CGPoint(x: 0, y: 0.5)),
            ],
        ]
    }
    
}
