//
//  ViewController.swift
//  XcapKit-Demo-iOS
//
//  Created by scchn on 2022/11/10.
//

import UIKit

import XcapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var removeBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var lineSegmentButton: UIButton!
    @IBOutlet weak var triangleButton: UIButton!
    @IBOutlet weak var circleButton: UIButton!
    @IBOutlet weak var rectangleButton: UIButton!
    @IBOutlet weak var pencilButton: UIButton!
    @IBOutlet weak var xcapView: XcapView!
    @IBOutlet weak var rotationButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
    
    var objectObservation: NSKeyValueObservation?
    var selectionObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotification()
        setupXcapView()
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        xcapView.contentSize = xcapView.bounds.size
        
        updateUI()
    }
    
    func setupXcapView() {
        xcapView.selectionRange = 12
        xcapView.delegate = self
        
        objectObservation = xcapView.observe(\.currentObject, options: [.initial, .new]) { [weak self] xcapView, _ in
            self?.updateUI()
        }
        
        selectionObservation = xcapView.observe(\.selectedObjects, options: [.initial, .new]) { [weak self] xcapView, _ in
            guard let self = self else {
                return
            }
            self.removeBarButtonItem.isEnabled = !xcapView.selectedObjects.isEmpty
        }
    }
    
    func setupNotification() {
        let center = NotificationCenter.default
        
        center.addObserver(forName: .NSUndoManagerDidUndoChange, object: nil, queue: .main) { [weak self] notification in
            self?.updateUI()
        }
        center.addObserver(forName: .NSUndoManagerDidRedoChange, object: nil, queue: .main) { [weak self] notification in
            self?.updateUI()
        }
        center.addObserver(forName: .NSUndoManagerDidCloseUndoGroup, object: nil, queue: .main) { [weak self] notification in
            self?.updateUI()
        }
    }
    
    func updateUI() {
        removeBarButtonItem.isEnabled = !xcapView.selectedObjects.isEmpty
        
        let types: [ObjectRenderer.Type] = [LineSegmentRenderer.self, TriangleRenderer.self, CircleRenderer.self, RectangleRenderer.self, PencilRenderer.self]
        let buttons: [UIButton] = [lineSegmentButton, triangleButton, circleButton, rectangleButton, pencilButton]
        
        for (index, rendererType) in types.enumerated() {
            if let object = xcapView.currentObject {
                let isSelected = type(of: object) == rendererType
                buttons[index].configuration?.background.backgroundColor = isSelected ? .systemBlue : .lightGray
            } else {
                buttons[index].configuration?.background.backgroundColor = .systemBlue
            }
        }
        
        let rotatorOn = xcapView.plugins.contains {
            $0 is RotatorPlugin
        }
        let rotationButtonImage = UIImage(systemName: rotatorOn ? "checkmark.circle.fill" : "circle.fill")
        
        rotationButton.setImage(rotationButtonImage, for: .normal)
        undoButton.isEnabled = undoManager?.canUndo ?? false
        redoButton.isEnabled = undoManager?.canRedo ?? false
    }
    
    @IBAction func finishSession(_ sender: Any) {
        xcapView.finishDrawingSession()
        xcapView.deselectAllObjects()
    }
    
    @IBAction func removeSelectedObjects(_ sender: Any) {
        xcapView.removeSelectedObjects()
    }
    
    @IBAction func startLineSession(_ sender: Any) {
        xcapView.startDrawingSession(ofType: LineSegmentRenderer.self)
    }
    
    @IBAction func startTriangleSession(_ sender: Any) {
        xcapView.startDrawingSession(ofType: TriangleRenderer.self)
    }
    
    @IBAction func startRectangleSession(_ sender: Any) {
        xcapView.startDrawingSession(ofType: RectangleRenderer.self)
    }
    
    @IBAction func startCircleSession(_ sender: Any) {
        xcapView.startDrawingSession(ofType: CircleRenderer.self)
    }
    
    @IBAction func startPencilSession(_ sender: Any) {
        xcapView.startDrawingSession(ofType: PencilRenderer.self)
    }
    
    @IBAction func undoButtonAction(_ sender: Any) {
        undoManager?.undo()
    }
    
    @IBAction func redoButtonAction(_ sender: Any) {
        undoManager?.redo()
    }
    
    @IBAction func rotationButtonAction(_ sender: Any) {
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
    
}
