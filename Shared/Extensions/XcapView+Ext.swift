//
//  XcapView+Ext.swift
//  XcapKit-Demo
//
//  Created by scchn on 2022/11/13.
//

import Foundation

import XcapKit

extension XcapView.State: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .idle:
            return "Idle"
            
        case .onObject:
            return "On Object"
            
        case .onItem:
            return "On Item"
            
        case .editing:
            return "Editing"
            
        case .moving:
            return "Moving"
            
        case .selecting:
            return "Selecting"
            
        case .drawing:
            return "Drawing"
            
        case .plugin(let plugin):
            return plugin is RotatorPlugin ? "Rotating" : "N/A"
        }
    }
    
}
