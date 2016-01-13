//
//  MappingError.swift
//  AlamofireGenome
//
//  Created by Daniel Hodos on 1/13/16.
//  Copyright © 2016 Table XI. All rights reserved.
//

import Foundation
import Genome

extension Genome.MappingError: CustomErrorConvertible {
  var failureReason: String {
    switch self {
    case .UnableToMap(let value): return "\(self): \(value)"
    case .UnexpectedOperationType(let value): return "\(self) \(value)"
    }
  }
}