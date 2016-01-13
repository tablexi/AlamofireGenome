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