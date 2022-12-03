//
//  ViewController.swift
//  XcapKit-Demo
//
//  Created by scchn on 2022/11/10.
//

import Cocoa

import XcapKit

class ViewController: NSViewController {
    
    @IBOutlet weak var lineSegmentButton: NSButton!
    @IBOutlet weak var triangleButton: NSButton!
    @IBOutlet weak var circleButton: NSButton!
    @IBOutlet weak var rectangleButton: NSButton!
    @IBOutlet weak var pencilButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    @IBOutlet weak var rotationCheckbox: NSButton!
    @IBOutlet weak var xcapView: XcapView!
    
    var objectObservation: NSKeyValueObservation?
    var selectionObservation: NSKeyValueObservation?
    var rotatorPlugin = RotatorPlugin()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        xcapView.contentSize = CGSize(width: 1080, height: 720)
        xcapView.selectionRange = 6
        xcapView.delegate = self
        xcapView.drawingDelegate = self
        xcapView.itemSelectionMode = .rectangle
        xcapView.addPlugin(rotatorPlugin)
        
        objectObservation = xcapView.observe(\.currentObject, options: [.initial, .new]) { [weak self] xcapView, _ in
            self?.updateUI()
        }
        
        selectionObservation = xcapView.observe(\.selectedObjects, options: [.initial, .new]) { [weak self] xcapView, _ in
            self?.updateUI()
        }
        
        updateUI()
    }
    
    func updateUI() {
        removeButton.isEnabled = !xcapView.selectedObjects.isEmpty
        rotationCheckbox.state = rotatorPlugin.isEnabled ? .on : .off
        
        let types: [ObjectRenderer.Type] = [LineSegmentRenderer.self, TriangleRenderer.self, CircleRenderer.self, RectangleRenderer.self, PencilRenderer.self]
        let buttons: [NSButton] = [self.lineSegmentButton, self.triangleButton, self.circleButton, self.rectangleButton, self.pencilButton]
        
        for (index, rendererType) in types.enumerated() {
            if let object = xcapView.currentObject {
                let isSelected = type(of: object) == rendererType
                buttons[index].bezelColor = isSelected ? NSColor.controlAccentColor : nil
            } else {
                buttons[index].bezelColor = nil
            }
        }
    }
    
    override func selectAll(_ sender: Any?) {
        xcapView.selectAllObjects()
    }
    
    @IBAction func startLineSession(_ sender: Any) {
        xcapView.startDrawingSession(ofType: LineSegmentRenderer.self)
    }
    
    @IBAction func startTriangleSession(_ sender: Any) {
        xcapView.startDrawingSession(ofType: TriangleRenderer.self)
    }
    
    @IBAction func startCircleSession(_ sender: Any) {
        xcapView.startDrawingSession(ofType: CircleRenderer.self)
    }
    
    @IBAction func startRectangleSession(_ sender: Any) {
        xcapView.startDrawingSession(ofType: RectangleRenderer.self)
    }
    
    @IBAction func startPencilSession(_ sender: Any) {
        xcapView.startDrawingSession(ofType: PencilRenderer.self)
    }
    
    @IBAction func finishSession(_ sender: Any) {
        xcapView.finishDrawingSession()
        xcapView.deselectAllObjects()
    }
    
    @IBAction func removeSelectedObjects(_ sender: Any) {
        xcapView.removeSelectedObjects()
    }
    
    @IBAction func rotationCheckboxAction(_ sender: Any) {
        rotatorPlugin.isEnabled.toggle()
        
        updateUI()
    }
    
    @objc private func selectAllMenuItemAction(_ sender: Any) {
        xcapView.selectAllObjects()
    }
    
    @objc private func removeMenuItemAction(_ sender: NSMenuItem) {
        xcapView.removeSelectedObjects()
    }
    
}

extension ViewController: NSMenuItemValidation {
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case #selector(selectAllMenuItemAction(_:)):
            return !xcapView.objects.isEmpty
        default:
            return true
        }
    }
    
}

extension ViewController: XcapViewDelegate {
    
    func xcapView(_ xcapView: XcapView, didFinishDrawingSessionWithObject object: ObjectRenderer) {
        if object is Editable {
            object.setRotationCenter(.item(.zero))
        }
    }
    
    func xcapView(_ xcapView: XcapView, menuForObject object: ObjectRenderer?) -> NSMenu? {
        let menu = NSMenu()
        
        if object != nil {
            menu.addItem(withTitle: "Delete",
                         action: #selector(removeMenuItemAction(_:)),
                         keyEquivalent: "")
        } else {
            menu.addItem(withTitle: "Select All",
                         action: #selector(selectAllMenuItemAction(_:)),
                         keyEquivalent: "")
        }
        
        return menu
    }
    
}

extension ViewController: XcapViewDrawingDelegate {
    
    func xcapView(_ xcapView: XcapView, drawBoundingBox boundingBox: CGRect, highlighted: Bool, context: CGContext) {
        let boundingBox = boundingBox.insetBy(dx: -xcapView.selectionRange, dy: -xcapView.selectionRange)
        let path = CGPath(roundedRect: boundingBox, cornerWidth: 4, cornerHeight: 4, transform: nil)
        let strokeColor = NSColor.black
        let fillColor = highlighted ? NSColor.cyan.withAlphaComponent(0.1) : .white.withAlphaComponent(0.1)
        
        context.addPath(path)
        context.clip(using: .evenOdd)
        
        context.setFillColor(fillColor.cgColor)
        context.addPath(path)
        context.fillPath()
        
        context.setShadow(offset: .zero, blur: 3, color: .black)
        context.setStrokeColor(strokeColor.cgColor)
        context.addPath(path)
        context.strokePath()
    }
    
    func xcapView(_ xcapView: XcapView, drawItemAt point: CGPoint, highlighted: Bool, context: CGContext) {
        let bounds = CGRect(origin: .zero, size: xcapView.contentRect.size)
        let width = xcapView.selectionRange
        let origin = CGPoint(x: point.x - width, y: point.y - width)
        let size = CGSize(width: width * 2, height: width * 2)
        let rect = CGRect(origin: origin, size: size)
        let strokeColor = NSColor.black
        let fillColor = highlighted ? NSColor.white : .white
        
        context.setFillColor(fillColor.cgColor)
        context.addRect(rect)
        context.fillPath()
        
        context.addRect(bounds)
        context.addRect(rect.insetBy(dx: 1, dy: 1))
        context.clip(using: .evenOdd)
        
        if highlighted {
            context.setShadow(offset: .zero, blur: 3, color: .black)
        }
        
        context.setStrokeColor(strokeColor.cgColor)
        context.addRect(rect)
        context.strokePath()
    }
    
}
