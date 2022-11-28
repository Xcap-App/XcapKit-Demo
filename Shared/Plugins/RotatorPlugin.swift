//
//  RotatorPlugin.swift
//  XcapKit-Demo
//
//  Created by scchn on 2022/11/11.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

import XcapKit

extension XcapView {
    
    fileprivate var selectedObject: ObjectRenderer? {
        selectedObjects.count == 1 ? selectedObjects.first : nil
    }
    
}

class RotatorPlugin: Plugin {
    
    private enum InitialState {
        case center(ObjectRenderer.PointDescriptor)
        case angle(ObjectRenderer.PointDescriptor, Angle)
    }
    
    #if os(macOS)
    private let rotationRange: CGFloat = 8
    #else
    private let rotationRange: CGFloat = 16
    #endif
    
    private var initialState: InitialState?
    
    override var priority: Plugin.Priority {
        .high
    }
    
    deinit {
        print("bye", self)
    }
    
    override func shouldBegin(in xcapView: XcapView, location: CGPoint) -> Bool {
        guard let object = xcapView.selectedObject,
              let rotationCenter = object.rotationCenter
        else {
            return false
        }
        
        let convertedLocation = xcapView.convertLocation(fromViewToContent: location)
        let centerPoint = object.point(with: rotationCenter)
        lazy var rotatorCircle: Circle = {
            let range = xcapView.selectionRange * xcapView.contentScaleFactors.toContent.x
            return Circle(center: centerPoint, radius: range)
        }()
        lazy var rotationCircle: Circle = {
            let range = (xcapView.selectionRange + rotationRange) * xcapView.contentScaleFactors.toContent.x
            return Circle(center: centerPoint, radius: range)
        }()
        
        if rotatorCircle.contains(convertedLocation) {
            initialState = .center(rotationCenter)
            return true
        } else if rotationCircle.contains(convertedLocation) {
            initialState = .angle(rotationCenter, object.rotationAngle)
            return true
        }
        
        initialState = nil
        
        return false
    }
    
    override func update(in xcapView: XcapView, state: Plugin.State) {
        guard let object = xcapView.selectedObject else {
            return
        }
        
        switch state {
        case .idle, .began:
            break
            
        case .moved(let location, _, _):
            guard let initialState = initialState else {
                break
            }
            
            let convertedLocation = xcapView.convertLocation(fromViewToContent: location)
            
            
            switch initialState {
            case .center:
                let convertedSelectionRange = xcapView.selectionRange * xcapView.contentScaleFactors.toContent.x
                
                if let position = findItemPosition(for: object, at: convertedLocation, range: convertedSelectionRange) {
                    object.setRotationCenter(.item(position), undoMode: .disable)
                } else {
                    object.setRotationCenter(.fixed(convertedLocation), undoMode: .disable)
                }
                
            case let .angle(initialRotationCenter, _):
                let centerPoint = object.point(with: initialRotationCenter)
                let rotation = Angle(radians: Line(start: centerPoint, end: convertedLocation).angle)
                
                object.rotate(angle: rotation, undoMode: .disable)
            }
            
        case .ended:
            guard let initialState = initialState, let undoManager = xcapView.undoManager else {
                break
            }
            
            switch initialState {
            case let .center(initialRotationCenter):
                guard object.rotationCenter != initialRotationCenter else {
                    break
                }
                registerUndoSetRotationCenter(undoManager: undoManager, object: object, rotationCenter: initialRotationCenter)
                
            case let .angle(_, initialRotationAngle):
                guard object.rotationAngle != initialRotationAngle else {
                    break
                }
                registerUndoRotate(undoManager: undoManager, object: object, rotationAngle: initialRotationAngle)
            }
        }
    }
    
    override func shouldDraw(in xcapView: XcapView, state: Plugin.State) -> Bool {
        switch xcapView.state {
        case .editing, .moving:
            return false
        default:
            return xcapView.selectedObject?.rotationCenter != nil
        }
    }
    
    override func draw(in xcapView: XcapView, state: Plugin.State, context: CGContext) {
        guard let object = xcapView.selectedObject,
              let rotationCenter = object.rotationCenter
        else {
            return
        }
        
        let transform = CGAffineTransform.identity
            .scaledBy(x: xcapView.contentScaleFactors.toView.x,
                      y: xcapView.contentScaleFactors.toView.x)
        let centerPoint = object.point(with: rotationCenter)
            .applying(transform)
        let highlighs: Bool = {
            switch state {
            case .began, .moved:
                return true
            default:
                return false
            }
        }()
        
        context.translateBy(x: xcapView.contentRect.minX, y: xcapView.contentRect.minY)
        
        // Center
        
        if case .center = initialState {
            context.setFillColor(highlighs ? PlatformColor.red.cgColor : PlatformColor.lightGray.cgColor)
        } else {
            context.setFillColor(PlatformColor.lightGray.cgColor)
        }
        
        context.setStrokeColor(PlatformColor.black.cgColor)
        context.addArc(center: centerPoint, radius: xcapView.selectionRange, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        context.drawPath(using: .fillStroke)
        
        // Rotator
        
        if case .angle = initialState {
            context.setStrokeColor(highlighs ? PlatformColor.red.cgColor : PlatformColor.black.cgColor)
        } else {
            context.setStrokeColor(PlatformColor.black.cgColor)
        }
        
        context.addArc(center: centerPoint, radius: xcapView.selectionRange + rotationRange, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        context.strokePath()
    }
    
}

extension RotatorPlugin {
    
    private func findItemPosition(for object: ObjectRenderer, at location: CGPoint, range: CGFloat) -> ObjectLayout.Position? {
        for (i, items) in object.layout.reversed().enumerated() {
            for (j, item) in items.enumerated() {
                let itemCircle = Circle(center: item, radius: range)
                
                if itemCircle.contains(location) {
                    return .init(item: j, section: i)
                }
            }
        }
        return nil
    }
    
}

extension RotatorPlugin {
    
    private func registerUndoSetRotationCenter(undoManager: UndoManager, object: ObjectRenderer, rotationCenter: ObjectRenderer.PointDescriptor) {
        undoManager.registerUndo(withTarget: self) { [weak undoManager, weak object] plugin in
            guard let object = object else {
                return
            }
            
            if let undoManager = undoManager, let rotationCenter = object.rotationCenter {
                plugin.registerUndoSetRotationCenter(undoManager: undoManager, object: object, rotationCenter: rotationCenter)
            }
            
            object.setRotationCenter(rotationCenter, undoMode: .disable)
        }
    }
    
    private func registerUndoRotate(undoManager: UndoManager, object: ObjectRenderer, rotationAngle: Angle) {
        undoManager.registerUndo(withTarget: self) { [weak undoManager, weak object] plugin in
            guard let object = object else {
                return
            }
            
            if let undoManager = undoManager {
                plugin.registerUndoRotate(undoManager: undoManager, object: object, rotationAngle: object.rotationAngle)
            }
            
            object.rotate(angle: rotationAngle, undoMode: .disable)
        }
    }
    
}
