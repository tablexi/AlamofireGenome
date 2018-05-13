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

extension Request {

  // MARK: Parsing

  enum AlamofireGenomeError: Error {
    case JSONError
  }

  /// Parses the JSON and maps it using Genome.
  ///
  /// Generics:
  ///   - T: `MappableObject` or `Array<MappableObject>`
  ///   - U: `JSON` or `Array<JSON>`
  private static func parse<T, U>(keyPath: String?, callback: @escaping (U) throws -> T) -> ResponseSerializer<T, NSError> {
    return ResponseSerializer { request, response, data, error in
      guard error == nil else { return .Failure(error!) }

      let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
      let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
      guard let value = result.value else { return .Failure(result.error!) }

      let JSONToMap: U?
      if let keyPath = keyPath {
        JSONToMap = value[keyPath] as? U
      } else {
        JSONToMap = value as? U
      }

      guard let json = JSONToMap else {
        return .Failure(AlamofireGenomeError.JSONError as NSError)
      }

      do {
        let result = try callback(json)
        return .Success(result)
      } catch {
        if let error = error as? CustomErrorConvertible {
          return .Failure(error.error)
        }
        return .Failure(error as NSError)
      }
    }
  }

  // MARK: Serialization

  /// Creates a response serializer that returns a Genome `MappableObject`
  /// constructed from the response data.
  ///
  /// Parameters:
  ///   - keyPath: The root key of the JSON
  ///
  /// Returns: A Genome `ResponseSerializer`
  public static func GenomeSerializer<T: MappableObject>(keyPath: String?) -> ResponseSerializer<T, NSError> {
    return parse(keyPath) { try T.mappedInstance($0) }
  }

  /// Creates a response serializer that returns an array of Genome 
  /// `MappableObject` constructed from the response data.
  ///
  /// Parameters:
  ///   - keyPath: The root key of the JSON
  ///
  /// Returns: A Genome `ResponseSerializer`
  public static func GenomeSerializer<T: MappableObject>(keyPath: String?) -> ResponseSerializer<[T], NSError> {
    return parse(keyPath) { try [T].mappedInstance($0) }
  }

  // MARK: Object

  /// Adds a handler to be called once a request has finished to map the 
  /// returned JSON to a Genome `MappableObject`
  ///
  /// Parameters:
  ///   - completionHandler: Closure to be executed once the execution has
  ///                        finished
  ///
  /// Returns: The request
  public func responseObject<T: MappableObject>(completionHandler: Response<T, NSError> -> Void) -> Self {
    return responseObject(nil, keyPath: nil, completionHandler: completionHandler)
  }

  /// Adds a handler to be called once a request has finished to map the
  /// returned JSON to a Genome `MappableObject`
  ///
  /// Parameters:
  ///   - keyPath: The root key of the JSON
  ///   - completionHandler: Closure to be executed once the execution has
  ///                        finished
  ///
  /// Returns: The request
  public func responseObject<T: MappableObject>(keyPath: String, completionHandler: Response<T, NSError> -> Void) -> Self {
    return responseObject(nil, keyPath: keyPath, completionHandler: completionHandler)
  }

  /// Adds a handler to be called once a request has finished to map the
  /// returned JSON to a Genome `MappableObject`
  ///
  /// Parameters:
  ///   - queue: The queue on which the completion handler is dispatched
  ///   - keyPath: The root key of the JSON
  ///   - completionHandler: Closure to be executed once the execution has
  ///                        finished
  ///
  /// Returns: The request
  public func responseObject<T: MappableObject>(queue: dispatch_queue_t?, keyPath: String?, completionHandler: Response<T, NSError> -> Void) -> Self {
    return response(queue: queue, responseSerializer: Request.GenomeSerializer(keyPath), completionHandler: completionHandler)
  }

  // MARK: Array

  /// Adds a handler to be called once a request has finished to map the
  /// returned JSON to an array of Genome `MappableObject`
  ///
  /// Parameters:
  ///   - completionHandler: Closure to be executed once the execution has
  ///                        finished
  ///
  /// Returns: The request
  public func responseArray<T: MappableObject>(completionHandler: Response<[T], NSError> -> Void) -> Self {
    return responseArray(nil, keyPath: nil, completionHandler: completionHandler)
  }

  /// Adds a handler to be called once a request has finished to map the
  /// returned JSON to an array of Genome `MappableObject`
  ///
  /// Parameters:
  ///   - keyPath: The root key of the JSON
  ///   - completionHandler: Closure to be executed once the execution has
  ///                        finished
  ///
  /// Returns: The request
  public func responseArray<T: MappableObject>(keyPath: String, completionHandler: Response<[T], NSError> -> Void) -> Self {
    return responseArray(nil, keyPath: keyPath, completionHandler: completionHandler)
  }

  /// Adds a handler to be called once a request has finished to map the
  /// returned JSON to an array of Genome `MappableObject`
  ///
  /// Parameters:
  ///   - queue: The queue on which the completion handler is dispatched
  ///   - keyPath: The root key of the JSON
  ///   - completionHandler: Closure to be executed once the execution has
  ///                        finished
  ///
  /// Returns: The request
  public func responseArray<T: MappableObject>(queue: dispatch_queue_t?, keyPath: String?, completionHandler: Response<[T], NSError> -> Void) -> Self {
    return response(queue: queue, responseSerializer: Request.GenomeSerializer(keyPath), completionHandler: completionHandler)
  }

}
