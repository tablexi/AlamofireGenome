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

  private static func parse<T, U>(type: U.Type, keyPath: String?, request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?, callback: U throws -> T) -> Result<T, NSError> {
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

  public static func GenomeSerializer<T: MappableObject>(keyPath: String?) -> ResponseSerializer<T, NSError> {
    return ResponseSerializer { request, response, data, error in
      let parseResult = parse(JSON.self, keyPath: keyPath, request: request, response: response, data: data, error: error) { json -> T in
        let parsedObject = try T.mappedInstance(json)
        return parsedObject
      }
      return parseResult
    }
  }

  public static func GenomeSerializer<T: MappableObject>(keyPath: String?) -> ResponseSerializer<[T], NSError> {
    return ResponseSerializer { request, response, data, error in
      let parseResult = parse([JSON].self, keyPath: keyPath, request: request, response: response, data: data, error: error) { json -> [T] in
        let parsedArray = try [T].mappedInstance(json)
        return parsedArray
      }
      return parseResult
    }
  }

  enum AlamofireGenomeError: ErrorType {
    case JSONError
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