//
//  AlamofireGenome.swift
//  PechaKucha
//
//  Created by Daniel Hodos on 11/5/15.
//  Copyright © 2015 Table XI. All rights reserved.
//

import Foundation
import Alamofire
import Genome

// MARK: Genome Extensions for better error messaging

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
    return Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
  }
}

extension Genome.SequenceError: CustomErrorConvertible {
  var failureReason: String {
    switch self {
    case .FoundNil(let value): return "\(self): \(value)"
    case .UnexpectedValue(let value): return "\(self): \(value)"
    }
  }
}

extension Genome.MappingError: CustomErrorConvertible {
  var failureReason: String {
    switch self {
    case .UnableToMap(let value): return "\(self): \(value)"
    case .UnexpectedOperationType(let value): return "\(self) \(value)"
    }
  }
}

extension Genome.TransformationError: CustomErrorConvertible {
  var failureReason: String {
    switch self {
    case .UnexpectedInputType(let value): return "\(self) \(value)"
    }
  }
}

// MARK: Genome Serialization

extension Request {

  public static func GenomeSerializer<T: MappableObject>(keyPath: String?) -> ResponseSerializer<T, NSError> {
    return ResponseSerializer { request, response, data, error in
      guard error == nil else { return .Failure(error!) }

      let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
      let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
      guard let value = result.value else { return .Failure(result.error!) }

      do {
        let json = try toJson(JSON.self, value: value, keyPath: keyPath)
        let parsedObject = try T.mappedInstance(json)
        return .Success(parsedObject)
      } catch {
        if let error = error as? CustomErrorConvertible {
          return .Failure(error.error)
        }
        return .Failure(error as NSError)
      }
    }
  }

  enum AlamofireGenomeError: ErrorType {
    case JSONError
  }

  private static func toJson<T>(type: T.Type, value: AnyObject, keyPath: String?) throws -> T {
    let JSONToMap: T?

    if let keyPath = keyPath {
      JSONToMap = value[keyPath] as? T
    } else {
      JSONToMap = value as? T
    }

    if let json = JSONToMap {
      return json
    } else {
      throw AlamofireGenomeError.JSONError
    }
  }

  public func responseObject<T: MappableObject>(completionHandler: Response<T, NSError> -> Void) -> Self {
    return responseObject(nil, keyPath: nil, completionHandler: completionHandler)
  }

  public func responseObject<T: MappableObject>(keyPath: String, completionHandler: Response<T, NSError> -> Void) -> Self {
    return responseObject(nil, keyPath: keyPath, completionHandler: completionHandler)
  }

  public func responseObject<T: MappableObject>(queue: dispatch_queue_t?, keyPath: String?, completionHandler: Response<T, NSError> -> Void) -> Self {
    return response(queue: queue, responseSerializer: Request.GenomeSerializer(keyPath), completionHandler: completionHandler)
  }

  public static func GenomeSerializer<T: MappableObject>(keyPath: String?) -> ResponseSerializer<[T], NSError> {
    return ResponseSerializer { request, response, data, error in
      guard error == nil else { return .Failure(error!) }

      let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
      let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
      guard let value = result.value else { return .Failure(result.error!) }

      do {
        let json = try toJson([JSON].self, value: value, keyPath: keyPath)
        let parsedArray = try [T].mappedInstance(json)
        return .Success(parsedArray)
      } catch {
        return .Failure(error as NSError)
      }
    }
  }

  public func responseArray<T: MappableObject>(completionHandler: Response<[T], NSError> -> Void) -> Self {
    return responseArray(nil, keyPath: nil, completionHandler: completionHandler)
  }

  public func responseArray<T: MappableObject>(keyPath: String, completionHandler: Response<[T], NSError> -> Void) -> Self {
    return responseArray(nil, keyPath: keyPath, completionHandler: completionHandler)
  }

  public func responseArray<T: MappableObject>(queue: dispatch_queue_t?, keyPath: String?, completionHandler: Response<[T], NSError> -> Void) -> Self {
    return response(queue: queue, responseSerializer: Request.GenomeSerializer(keyPath), completionHandler: completionHandler)
  }

}