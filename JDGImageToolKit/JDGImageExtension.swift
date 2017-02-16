//
//  JDGImageExtension.swift
//  JDGImageToolKit
//
//  Created by JDG on 2017/1/4.
//  Copyright © 2017年 JDG. All rights reserved.
//

import Cocoa

class JDGImageCenter {
    static let shared = JDGImageCenter()
    private init () {}
    
    private var queue = DispatchQueue(label: "JDGImageCenterQueue")
    private var group = DispatchGroup()
    private var isProcessing = false
    
    func process(imageURLs : [URL], toPath path : String) {
        for u in imageURLs {
            guard let img = NSImage(contentsOf: u) else {
                continue
            }
            process(image: img, toPath: path, withFileName: u.lastPathComponent)
        }
    }
    
    func process(image : NSImage , toPath path : String , withFileName fileName : String , withSizeArray array : [CGSize]? = nil) {
        let mainQueue = DispatchQueue.main
        mainQueue.async(group: group, execute: DispatchWorkItem(block: { 
            print("开始处理")
            self.isProcessing = true
        }))
        
        queue.async(group: group, execute: DispatchWorkItem(block: {
            print("处理中")
            let name = fileName.components(separatedBy: ".").first ?? "noName"
            if let sizeArray = array {
                for size in sizeArray {
                    let fName1x = name+"-"+"\(Int(size.width))"+".png"
                    self.save(image: image, toPath: path, forFileName: fName1x, withSize: size)
                    let fName2x = name+"-"+"\(Int(size.width))"+"@2x.png"
                    self.save(image: image, toPath: path, forFileName: fName2x, withSize: size*2)
                    let fName3x = name+"-"+"\(Int(size.width))"+"@3x.png"
                    self.save(image: image, toPath: path, forFileName: fName3x, withSize: size*3)
                }
            } else {
                //默认当3x图处理
                let size = image.size
                let fName1x = name+".png"
                self.save(image: image, toPath: path, forFileName: fName1x, withSize: size/3)
                let fName2x = name+"@2x.png"
                self.save(image: image, toPath: path, forFileName: fName2x, withSize: size*2/3)
                let fName3x = name+"@3x.png"
                self.save(image: image, toPath: path, forFileName: fName3x, withSize: size)
            }
        }))
        
        group.notify(queue: mainQueue, work: DispatchWorkItem(block: { 
            print("处理完成")
            self.isProcessing = false
        }))
    }
    
    private func save(image : NSImage ,toPath path : String, forFileName name : String ,withSize size : CGSize?) {
        var img : NSImage?
        if let s = size {
            img = image.rescalesToPixelSize(s)
        } else {
            img = image
        }
        let p = path+"/"+name
        img?.saveToPath(p, type: NSPNGFileType, properties: [:])
    }
}

extension CGSize {
    static func *(left : CGSize , right : CGFloat) -> CGSize {
        var ret : CGSize = left
        ret.width *= right
        ret.height *= right
        return ret
    }
    
    static func *(left : CGFloat , right : CGSize) -> CGSize {
        var ret : CGSize = right
        ret.width *= left
        ret.height *= left
        return ret
    }
    
    static func /(left : CGSize , right : CGFloat) -> CGSize {
        if right == 0 {
            return CGSize.zero
        }
        var ret : CGSize = left
        ret.width /= right
        ret.height /= right
        return ret
    }
}

extension NSImage {
    @discardableResult
    func saveToPath(_ path : String ,type : NSBitmapImageFileType , properties : [String: Any]) -> Bool{
        var ret = false
        self.lockFocus()
        guard let imageData = self.tiffRepresentation else {
            self.unlockFocus()
            return false
        }
        let srcImageRep = NSBitmapImageRep(data: imageData)
        guard let tempData = srcImageRep?.representation(using: type, properties: properties) else {
            self.unlockFocus()
            return false
        }
        
        do {
            let url = URL(fileURLWithPath: path)
            try tempData.write(to: url)
            ret = true
        } catch {
            ret = false
            print(error.localizedDescription)
        }
        self.unlockFocus()
        return ret
    }
    
    func rescalesToPixelSize (_ size : CGSize) -> NSImage? {
        guard let s = NSScreen.main()?.deviceDescription[NSDeviceResolution] as? NSSize else {
            print("屏幕不对")
            return nil
        }
        let isRetina = s.width>=144 && s.height>=144
        
        let targetSize = isRetina ? CGSize(width: size.width/2, height: size.height/2) : size
        let targetImage = NSImage(size: targetSize)
        targetImage.lockFocus()
        NSColor.clear.set()
        let rect = NSRect(origin: CGPoint.zero, size: targetSize)
        NSRectFill(rect)
        self.draw(in: rect)
        targetImage.unlockFocus()
        return targetImage
    }
}
