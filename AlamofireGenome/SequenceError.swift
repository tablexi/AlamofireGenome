//
//  GenomeErrors.swift
//  AlamofireGenome
//
//  Created by Daniel Hodos on 1/13/16.
//  Copyright © 2016 Table XI. All rights reserved.
//

import Foundation
import Genome

extension Genome.NodeError: CustomErrorConvertible {
  var failureReason: String {
    switch self {
    case .unableToConvert(let value): return "\(self): \(value)"
    }
  }
}
