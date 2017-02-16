//
//  JDGDraginImageView.swift
//  JDGImageToolKit
//
//  Created by JDG on 2017/1/4.
//  Copyright © 2017年 JDG. All rights reserved.
//

import Cocoa

protocol JDGDraginImageViewDelegate : class {
    func draginImageView(_ view : JDGDraginImageView , didAcceptFileNames names: [String])
}

class JDGDraginImageView: NSImageView {

    weak var delegate : JDGDraginImageViewDelegate?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        register(forDraggedTypes: [NSFilenamesPboardType])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if self.delegate != nil ,let t = sender.draggingPasteboard().types?.contains(NSFilenamesPboardType) , t {
            return .copy
        } else {
            return []
        }
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return draggingEntered(sender)
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pBoard = sender.draggingPasteboard()
        if let types = pBoard.types, types.contains(NSFilenamesPboardType) ,let fileNames = pBoard.propertyList(forType: NSFilenamesPboardType) as? [String] {
            delegate?.draginImageView(self, didAcceptFileNames: fileNames)
            return true
        }
        return false
    }
    
}
