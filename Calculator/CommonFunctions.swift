//
//  CommonFunctions.swift
//  Calculator
//
//  Created by Gavrysh on 8/13/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import Foundation

func lift<A, B>(_ value: (A?, B?)) -> (A, B)? {
    return value.0.flatMap { lhs in
        value.1.flatMap { (lhs, $0) }
    }
}

func lift<A, B, C>(_ value: (A?, B?, C?)) -> (A, B, C)? {
    return value.0.flatMap { lhs in
        value.1.flatMap { mhs in
            value.2.flatMap { (lhs, mhs, $0) }
        }
    }
}
