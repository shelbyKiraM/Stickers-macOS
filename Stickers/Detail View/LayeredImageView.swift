//
//  LayeredImageView.swift
//  Stickers
//
//  Created by Timothy Park on 8/3/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import AppKit
import QuartzCore
import ImageIO

// https://github.com/seido/testCollectionViewPerformance/blob/master/testCollectionViewPerformance/LayerdImageView.swift
class LayeredImageView: NSView {
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		wantsLayer = true
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		wantsLayer = true
	}
	
	var imageLayer: CALayer? = nil
	
	var imagePath: String? {
		didSet {
			if oldValue != self.imagePath {
				self.layer?.sublayers?.removeAll()
			}
			let adjustedBounds = self.bounds.insetBy(dx: 10, dy: 10)
			let w = adjustedBounds.width
			let h = adjustedBounds.height
			let path = self.imagePath
			let l = CALayer()
			let scale = (self.window?.screen ?? NSScreen.main)?.backingScaleFactor ?? 1.0
			
			DispatchQueue(label: "LayeredImageView.image", attributes: .concurrent).async { [weak self] in
				guard let self else { return }
				guard self.imagePath == path, let path else { return }
				
				let image = self.reseizeImage(path: path, width: Int(w), height: Int(h), scale: scale)
				
				DispatchQueue.main.async { [weak self] in
					guard let self else { return }
					guard self.imagePath == path else { return }
					l.contents = image
					l.contentsGravity = .resizeAspect
					self.imageLayer = l
					
					self.layer?.sublayers?.removeAll()
					if let bounds = self.layer?.bounds.insetBy(dx: 3, dy: 3) {
						l.frame = bounds
					}
					
					self.layer?.addSublayer(l)
					self.layer?.masksToBounds = true
					self.layer?.cornerRadius = 6
				}
			}
		}
	}
	
	override func layout() {
		super.layout()
		CATransaction.begin()
		CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
		self.imageLayer?.frame = self.layer?.bounds ?? .zero
		CATransaction.commit()
	}
	
	func reseizeImage(path: String, width: Int, height: Int, scale: CGFloat) -> CGImage? {
		let w = Int(CGFloat(width) * scale)
		let h = Int(CGFloat(height) * scale)
		
		let url = NSURL(fileURLWithPath: path)
		guard let org = CGImageSourceCreateWithURL(url, nil) else { return nil }
		
		let opts: [CFString: Any] = [
			kCGImageSourceCreateThumbnailWithTransform: true,
			kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
			kCGImageSourceThumbnailMaxPixelSize: NSNumber(value: Swift.max(w, h))
		]
		return CGImageSourceCreateThumbnailAtIndex(org, 0, opts as CFDictionary)
	}
	
	// override func hitTest(_ point: NSPoint) -> NSView? {
	//     var view = super.hitTest(point)
	//     if view == self {
	//         repeat {
	//             view = view!.superview
	//         } while view != nil && !(view is NSCollectionView)
	//     }
	//     return view;
	// }
	
}
