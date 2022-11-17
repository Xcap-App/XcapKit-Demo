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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        xcapView.contentSize = CGSize(width: 1080, height: 720)
        xcapView.delegate = self
        
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
        rotationCheckbox.state = xcapView.plugins.contains { $0 is RotatorPlugin } ? .on : .off
        
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
        let rotatorOn = xcapView.plugins.contains {
            $0 is RotatorPlugin
        }
        
        if rotatorOn {
            xcapView.plugins.removeAll { plugin in
                plugin is RotatorPlugin
            }
        } else {
            xcapView.plugins.append(RotatorPlugin())
        }
        
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
    
    func xcapView(_ xcapView: XcapView, didStartDrawingSessionWithObject object: ObjectRenderer) {
        print("💠 Did start drawing session : \(type(of: object)).")
    }
    
    func xcapView(_ xcapView: XcapView, didFinishDrawingSessionWithObject object: ObjectRenderer) {
        print("💠 Did finish drawing session : \(type(of: object)).")
        
        if object is Editable {
            object.setRotationCenter(.item(.zero), undoMode: .disable)
        }
    }
    
    func xcapViewDidCancelDrawingSession(_ xcapView: XcapView) {
        print("⚠️ Did cancel drawing session.")
    }
    
    func xcapView(_ xcapView: XcapView, didSelectObjects objects: [ObjectRenderer]) {
        print("💠 Selected \(objects.map({ type(of: $0) })).")
    }
    
    func xcapView(_ xcapView: XcapView, didDeselectObjects objects: [ObjectRenderer]) {
        print("💠 Deselected \(objects.map({ type(of: $0) })).")
    }
    
    func xcapView(_ xcapView: XcapView, didEditObject object: ObjectRenderer, at position: ObjectLayout.Position) {
        print("💠 Edited \(type(of: object)) at \(position).")
    }
    
    func xcapView(_ xcapView: XcapView, didMoveObjects objects: [ObjectRenderer]) {
        print("💠 Moved \(objects.map({ type(of: $0) })).")
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
