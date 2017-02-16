//
//  MainViewController.swift
//  JDGImageToolKit
//
//  Created by JDG on 2017/1/4.
//  Copyright © 2017年 JDG. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController
, JDGDraginImageViewDelegate {

    @IBOutlet weak var imageView: JDGDraginImageView!
    
    private var iconImportPath : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        imageView.delegate = self
    }
    
    func draginImageView(_ view: JDGDraginImageView, didAcceptFileNames names: [String]) {
        if names.count == 1 , let n = names.first {
            iconImportPath = n
            let fm = FileManager.default
            if fm.fileExists(atPath: iconImportPath) {
                let image = NSImage(contentsOfFile: iconImportPath)
                imageView.image = image;
            }
        }
    }
    
    @IBAction func pressExport(_ sender: Any) {
        let oPanel = NSOpenPanel()
        oPanel.canChooseFiles = false
        oPanel.canCreateDirectories = true
        oPanel.canChooseDirectories = true
        oPanel.allowsMultipleSelection = false
        
        if let img = imageView.image , oPanel.runModal() == NSModalResponseOK {
            if let url = oPanel.urls.first {
                let fm = FileManager.default
                if fm.fileExists(atPath: url.path) {
                    let widthArray : [CGFloat] = [20,29,40,50,57,60,72,76,83.5]
                    let sizeArray = widthArray.map({ (v) -> CGSize in
                        return CGSize(width: v, height: v)
                    })
                    JDGImageCenter.shared.process(image: img, toPath: url.path, withFileName: "icon", withSizeArray: sizeArray)
                }
            }
        }
    }
    
    private var pngFileUrls = [URL]()
    @IBAction func selectPNGFiles(_ sender: Any) {
        let oPanel = NSOpenPanel()
        oPanel.canChooseFiles = true
        oPanel.canCreateDirectories = false
        oPanel.canChooseDirectories = false
        oPanel.allowsMultipleSelection = true
        
        if oPanel.runModal() == NSModalResponseOK {
            pngFileUrls.append(contentsOf: oPanel.urls)
        }
    }
    
    @IBAction func startProcessPNGFile(_ sender: Any) {
        let oPanel = NSOpenPanel()
        oPanel.canChooseFiles = false
        oPanel.canCreateDirectories = true
        oPanel.canChooseDirectories = true
        oPanel.allowsMultipleSelection = false
        
        if pngFileUrls.count > 0 && oPanel.runModal() == NSModalResponseOK {
            if let url = oPanel.urls.first {
                let fm = FileManager.default
                if fm.fileExists(atPath: url.path) {
                    JDGImageCenter.shared.process(imageURLs: pngFileUrls, toPath: url.path)
                }
            }
        }
    }
}
