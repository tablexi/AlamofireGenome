//
//  CustomErrorConvertible.swift
//  AlamofireGenome
//
//  Created by Daniel Hodos on 1/13/16.
//  Copyright © 2016 Table XI. All rights reserved.
//

import Foundation
import Alamofire

// Currently, ErrorTypes are castable to NSError, but lose their associated
// objects (see: http://stackoverflow.com/q/31422005). So we extend the Genome
// errors to be able to return an NSError that has the associated value as the
// failure reason.

/// A protocol that says that this type can produce an NSError with a custom
/// failure reason.
protocol CustomErrorConvertible {
  var failureReason: String { get }
  var error: NSError { get }
}

extension CustomErrorConvertible {
  var error: NSError {
    let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
    // Taken from https://github.com/Alamofire/Alamofire/blob/3.0.0/Source/Error.swift
    let error = NSError(domain: "com.alamofire.error", code: -6006, userInfo: userInfo)
    return error
  }
}
