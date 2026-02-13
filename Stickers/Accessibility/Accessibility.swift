//
//  Accessibility.swift
//  Stickers
//
//  Created by Timothy Park on 8/19/20.
//  Copyright © 2020 Timothy Park. All rights reserved.
//

import AppKit
import ApplicationServices

// https://github.com/jtbandes/Mojo/blob/6bf35ebe626896ec0b721985736b1c4683cfe44f/Source/Accessibility.swift
enum AXProcess {
    static func isTrusted(prompt: Bool) -> Bool {
        let opts: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): prompt]
        return AXIsProcessTrustedWithOptions(opts)
    }
}

extension AXUIElement {
    
    static let systemWide = AXUIElementCreateSystemWide()
    
    private func get<T>(_ attribute: String, as _: T.Type) -> T? {
        var result: CFTypeRef?
        let err = AXUIElementCopyAttributeValue(self, attribute as CFString, &result)
        if err != .success {
            print("error getting \(self)[\(attribute)]: \(err.rawValue)")
        }
        return result as? T
    }
    
    private func get<T>(_ attribute: String, _ parameter: CFTypeRef, as: T.Type) -> T? {
        var result: CFTypeRef?
        let err = AXUIElementCopyParameterizedAttributeValue(self, attribute as CFString, parameter, &result)
        if err != .success {
            print("error getting \(self)[\(attribute)(\(parameter))]: \(err.rawValue)")
        }
        return result as? T
    }
    
    var focusedUIElement: AXUIElement? {
        return get(kAXFocusedUIElementAttribute, as: AXUIElement.self)
    }
    
    var processID: pid_t? {
        var pid: pid_t = 0
        return AXUIElementGetPid(self, &pid) == .success ? pid : nil
    }
    
    var selectedTextRange: CFRange? {
        return get(kAXSelectedTextRangeAttribute, as: AXValue.self)?.asRange
    }
    
    var value: String? {
        return get(kAXValueAttribute, as: CFString.self) as String?
    }
    
    func bounds(for range: CFRange) -> CGRect? {
        return get(kAXBoundsForRangeParameterizedAttribute,
                   AXValue.range(range),
                   as: AXValue.self)?.asRect
            .flatMap(NSScreen.convertFromQuartz)
    }
    
    var cursorBounds: CGRect? {
        if let selection = self.selectedTextRange, selection.length == 0 {
            // Getting the bounds for an empty range works in TextMate,
            // but not many other apps.
            // FIXME: can we get the correct bounds when RTL text is involved?
            let queryRange =
                selection.location > 0
                    ? CFRange(location: selection.location - 1, length: 1)
                    : selection
            return bounds(for: queryRange)
        }
        return nil
    }
}

extension AXValue {

		var asPoint: CGPoint? {
				var v = CGPoint.zero
				return AXValueGetValue(self, .cgPoint, &v) ? v : nil
		}
		var asSize: CGSize? {
				var v = CGSize.zero
				return AXValueGetValue(self, .cgSize, &v) ? v : nil
		}
		var asRect: CGRect? {
				var v = CGRect.zero
				return AXValueGetValue(self, .cgRect, &v) ? v : nil
		}
		var asRange: CFRange? {
				var v = CFRange()
				return AXValueGetValue(self, .cfRange, &v) ? v : nil
		}
		var asError: AXError? {
				var v = AXError.success
				return AXValueGetValue(self, .axError, &v) ? v : nil
		}
		static func point(_ v: CGPoint) -> AXValue {
				var v = v
				return AXValueCreate(.cgPoint, &v)!
		}
		static func size(_ v: CGSize) -> AXValue {
				var v = v
				return AXValueCreate(.cgSize, &v)!
		}
		static func rect(_ v: CGRect) -> AXValue {
				var v = v
				return AXValueCreate(.cgRect, &v)!
		}
		static func range(_ v: CFRange) -> AXValue {
				var v = v
				return AXValueCreate(.cfRange, &v)!
		}
		static func error(_ v: AXError) -> AXValue {
				var v = v
				return AXValueCreate(.axError, &v)!
		}
}
