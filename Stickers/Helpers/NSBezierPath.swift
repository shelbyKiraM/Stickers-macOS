//
//  NSBezierPath.swift
//  Stickers
//
//  Created by Timothy Park on 4/21/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import Cocoa

extension NSBezierPath {

		var cgPath: CGPath {
				let path = CGMutablePath()
				var points = [CGPoint](repeating: .zero, count: 3)

				for i in 0 ..< elementCount {
						let type = element(at: i, associatedPoints: &points)

						switch type {
						case .moveTo:
								path.move(to: points[0])
						case .lineTo:
								path.addLine(to: points[0])
						case .curveTo:
								// Treat as cubic (common in older SDKs)
								path.addCurve(to: points[2], control1: points[0], control2: points[1])
						case .cubicCurveTo:
								path.addCurve(to: points[2], control1: points[0], control2: points[1])
						case .quadraticCurveTo:
								// Quadratic: points[0]=control, points[1]=end
								path.addQuadCurve(to: points[1], control: points[0])
						case .closePath:
								path.closeSubpath()
						@unknown default:
								assertionFailure("Unhandled NSBezierPath.ElementType")
						}
				}
				return path
		}
	
}
