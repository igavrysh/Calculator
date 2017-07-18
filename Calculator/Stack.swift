//
//  Stack.swift
//  Calculator
//
//  Created by Gavrysh on 7/16/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import Foundation

struct Stack {
    private var stackValues: [Any] = []
    
    mutating func push(_ value: Any) {
        stackValues.insert(value, at: 0)
    }
    
    mutating func pop() -> Any? {
        stackValues.remove(at: 0)
        
        return stackValues.first
    }
}
