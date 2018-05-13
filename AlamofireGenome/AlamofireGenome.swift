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
  private static func parse<T, U>(keyPath: String?, callback: @escaping (U) throws -> T) -> DataResponseSerializer<T> {
    return DataResponseSerializer { request, response, data, error in
      guard error == nil else { return .failure(error!) }

      let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
      let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
      guard let value = result.value else { return .failure(result.error!) }

      let JSONToMap: U?
      if let keyPath = keyPath {
        JSONToMap = value[keyPath] as? U
      } else {
        JSONToMap = value as? U
      }

      guard let json = JSONToMap else {
        return .failure(AlamofireGenomeError.JSONError as NSError)
      }

      do {
        let result = try callback(json)
        return .success(result)
      } catch {
        if let error = error as? CustomErrorConvertible {
          return .failure(error.error)
        }
        return .failure(error as NSError)
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
  /// Returns: A Genome `DataResponseSerializer`
  public static func GenomeSerializer<T: MappableObject>(keyPath: String?) -> DataResponseSerializer<T> {
    return parse(keyPath: keyPath) { try T.mappedInstance($0) }
  }

  /// Creates a response serializer that returns an array of Genome 
  /// `MappableObject` constructed from the response data.
  ///
  /// Parameters:
  ///   - keyPath: The root key of the JSON
  ///
  /// Returns: A Genome `DataResponseSerializer`
  public static func GenomeSerializer<T: MappableObject>(keyPath: String?) -> DataResponseSerializer<[T]> {
    return parse(keyPath: keyPath) { try [T].mappedInstance($0) }
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
  public func responseObject<T: MappableObject>(completionHandler: (DataResponse<T>) -> Void) -> Self {
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
  public func responseObject<T: MappableObject>(keyPath: String, completionHandler: (DataResponse<T>) -> Void) -> Self {
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
  public func responseObject<T: MappableObject>(queue: dispatch_queue_t?, keyPath: String?, completionHandler: (DataResponse<T>) -> Void) -> Self {
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
  public func responseArray<T: MappableObject>(completionHandler: (DataResponse<[T]>) -> Void) -> Self {
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
  public func responseArray<T: MappableObject>(keyPath: String, completionHandler: (DataResponse<[T]>) -> Void) -> Self {
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
  public func responseArray<T: MappableObject>(queue: dispatch_queue_t?, keyPath: String?, completionHandler: (DataResponse<[T]>) -> Void) -> Self {
    return response(queue: queue, responseSerializer: Request.GenomeSerializer(keyPath), completionHandler: completionHandler)
  }

}
