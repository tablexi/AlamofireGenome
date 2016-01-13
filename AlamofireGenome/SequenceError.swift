//
//  GenomeErrors.swift
//  AlamofireGenome
//
//  Created by Daniel Hodos on 1/13/16.
//  Copyright © 2016 Table XI. All rights reserved.
//

import Foundation
import Genome

extension Genome.SequenceError: CustomErrorConvertible {
  var failureReason: String {
    switch self {
    case .FoundNil(let value): return "\(self): \(value)"
    case .UnexpectedValue(let value): return "\(self): \(value)"
    }
  }
}