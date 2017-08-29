//
//  Extensions.swift
//  Calculator
//
//  Created by Gavrysh on 8/13/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import Foundation

extension Optional {
    func `do`(execute: (Wrapped) -> ()) {
        self.map(execute)
    }
}

extension NumberFormatter {
    static var prettyFormat: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        
        return formatter
    }
}

extension Double {
    var prettyDescString: String {
        let formatter = NumberFormatter.prettyFormat
        formatter.maximumFractionDigits = self.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 6
        
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
    
    var prettyDisplayString: String {
        let formatter = NumberFormatter.prettyFormat
        formatter.maximumFractionDigits = 20;
        
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
    
    var stringWithoutInsignificantFractionDigits: String {
        let formatter = NumberFormatter()
        var string: String;
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            formatter.maximumFractionDigits = 0
            string = formatter.string(from: NSNumber(value: self)) ?? ""
        } else {
            string = String(self)
        }
        
        return string
    }
}

extension String {
    var prettyDoubleInString: String {
        let components = self.components(separatedBy: ".")
        let firstPart = components[0]
        let reversedCharacters = firstPart.characters.reversed()
        var prettyDouble = ""
        for (n, c) in reversedCharacters.enumerated() {
            prettyDouble = String(c) + prettyDouble
            if (n + 1) % 3 == 0 && n != reversedCharacters.count - 1  {
                prettyDouble = "," + prettyDouble
            }
        }
        
        if (components.count == 2) {
            prettyDouble = "\(prettyDouble).\(components[1])"
        }
        
        return prettyDouble
    }
    
    var prettyDouble: Double {
        let formatter = NumberFormatter.prettyFormat
        
        var formattedDouble: Double = 0
        formatter.number(from: self).do { formattedDouble = $0.doubleValue }
        
        return formattedDouble
    }
}


func encode<T>(_ value: T) -> NSData {
    var value = value
    
    return withUnsafePointer(to: &value) { p in
        NSData(bytes: p, length: MemoryLayout.size(ofValue: value))
    }
}

func decode<T>(_ data: NSData) -> T {
    let pointer = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T.Type>.size)
    data.getBytes(pointer)
    
    return pointer.move()
}

enum Result<T> {
    case Success(T)
    case Failure
}


// Example:
/*

var res: Result<String> = .Success("yeah")

var data = encode(res)

var decoded: Result<String> = decode(data)

switch decoded {
case .Failure:
    "failure"
case .Success(let v):
    "success: \(v)" // => "success: yeah"
}
 */
