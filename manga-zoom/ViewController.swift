//
//  ViewController.swift
//  manga-zoom
//
//  Created by Kentaro Matsumae on 2017/09/06.
//  Copyright © 2017年 Kentaro Matsumae. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    var handler: VNImageRequestHandler?
    
    let images = (1...100).map { String(format: "%03d", $0) }
    var index = 0
    
    @IBOutlet weak var overlayView: OverlayView!
    @IBOutlet weak var imageView: UIImageView!
    
    var currentImage: UIImage? {
        let name = images[index]
        return UIImage(named: name)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageView.image = currentImage
        process()
    }
    
    @IBAction func buttonDidTap(_ sender: Any) {
        if index < images.count - 1 {
            index += 1
        } else {
            index = 0
        }
        imageView.image = currentImage
        process()
    }

    func process() {
        overlayView.boxes = []
        overlayView.chBoxes = []
        
        let req = VNDetectTextRectanglesRequest { (req, err) in
            if let res = req.results as? [VNTextObservation] {
                for ob in res {
                    let boxes = ob.boundingBox.scaledForOverlay(to: self.overlayView.frame.size)
                    self.overlayView.boxes.append(boxes)
                    
                    if let chars = ob.characterBoxes {
                        for chob in chars {
                            let chbox = chob.boundingBox.scaledForOverlay(to: self.overlayView.frame.size)
                            self.overlayView.chBoxes.append(chbox)
                        }
                    }
                }
                self.overlayView.setNeedsDisplay()
            }
        }
        req.reportCharacterBoxes = true
        handler = VNImageRequestHandler(cgImage: currentImage!.cgImage!)
        do {
            try handler?.perform([req])
        } catch {
            print(error)
        }
    }
}

class OverlayView: UIView {
    
    var boxes:[CGRect] = []
    var chBoxes:[CGRect] = []

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        boxes.forEach { (box) in
            context?.setStrokeColor(UIColor.red.cgColor)
            context?.setLineWidth(2)
            context?.stroke(box)
        }
        chBoxes.forEach { (box) in
            context?.setStrokeColor(UIColor.blue.cgColor)
            context?.setLineWidth(2)
            context?.stroke(box)
        }
    }
}

extension CGRect {
    func scaledForOverlay(to size: CGSize) -> CGRect {
        return CGRect(
            x: self.origin.x * size.width,
            y: (1.0 - self.origin.y - self.size.height) * size.height,
            width: (self.size.width * size.width),
            height: (self.size.height * size.height)
        )
    }
    
    func scaledForCropping(to size: CGSize) -> CGRect {
        return CGRect(
            x: self.origin.x * size.width,
            y: self.origin.y * size.height,
            width: (self.size.width * size.width),
            height: (self.size.height * size.height)
        )
    }
}
