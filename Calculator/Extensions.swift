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

extension Array {
    func deriveFirstRes<T,A>(f: @escaping (T) -> A?) -> A? {
        return self
            .map { ($0 as? T).flatMap { f($0) } }
            .reduce(nil) { (res: A?, arg:A?) -> A? in
                return res ?? arg
        }
    }
}

extension Array where Iterator.Element == String  {
    func joinedWithNilEscaping(separator: String = "") -> String? {
        return self.reduce(nil) { (acc: String?, string: String) -> String? in
            if let acc = acc {
                return acc + separator + string
            }
            
            return string
        }
    }
}
