//
//  AlamofireGenomeSpec.swift
//  PechaKucha
//
//  Created by Daniel Hodos on 11/6/15.
//  Copyright © 2015 Table XI. All rights reserved.
//

import Quick
import Nimble

import AlamofireGenome
import Alamofire
import Genome

struct Animal: StandardMappable {
  var name: String
  var starRating: Int

  init(map: Map) throws {
    try name = <~map["name"]
    try starRating = <~map["star_rating"]
  }

  func sequence(map: Map) throws {
  }
}

class AlamofireGenomeSpec: QuickSpec {
  override func spec() {

    describe("responseObject") {
      it("returns an existing error") {
        let error = Error.errorWithCode(Error.Code.StatusCodeValidationFailed, failureReason: "Server returned 500")
        let serializer: ResponseSerializer<Animal, NSError> = Request.GenomeSerializer(nil)

        let result = serializer.serializeResponse(nil, nil, nil, error)
        expect(result.error).to(equal(error))
      }

      it("returns an error when JSON is empty") {
        let serializer: ResponseSerializer<Animal, NSError> = Request.GenomeSerializer(nil)

        let result = serializer.serializeResponse(nil, nil, NSData(), nil)
        expect(result.error?.localizedFailureReason).to(match("Input data was nil"))
      }

      it("returns an error when JSON is invalid") {
        let serializer: ResponseSerializer<Animal, NSError> = Request.GenomeSerializer(nil)

        let data = "{ no_dice: ".dataUsingEncoding(NSUTF8StringEncoding)
        let result = serializer.serializeResponse(nil, nil, data, nil)
        expect(result.error?.localizedFailureReason).to(match("not in the correct format"))
      }

      it("returns an error when JSON can't be mapped") {
        let serializer: ResponseSerializer<Animal, NSError> = Request.GenomeSerializer(nil)

        let data = "{ \"vehicle\": \"train\" }".dataUsingEncoding(NSUTF8StringEncoding)
        let result = serializer.serializeResponse(nil, nil, data, nil)
        expect(result.error?.localizedDescription).to(match("FoundNil"))
      }

      it("returns an error when JSON has the wrong types") {
        let serializer: ResponseSerializer<Animal, NSError> = Request.GenomeSerializer(nil)

        let data = "{ \"name\": \"platypus\", \"star_rating\": \"a million\" }".dataUsingEncoding(NSUTF8StringEncoding)
        let result = serializer.serializeResponse(nil, nil, data, nil)
        expect(result.error?.localizedDescription).to(match("UnexpectedValue"))
      }

      it("returns an object when mapping succeeds") {
        let serializer: ResponseSerializer<Animal, NSError> = Request.GenomeSerializer(nil)

        let data = "{ \"name\": \"platypus\", \"star_rating\": 5 }".dataUsingEncoding(NSUTF8StringEncoding)
        let result = serializer.serializeResponse(nil, nil, data, nil)
        expect(result.value?.name).to(equal("platypus"))
      }
    }

    describe("responseArray") {
      it("returns an array when mapping succeeds") {
        let serializer: ResponseSerializer<[Animal], NSError> = Request.GenomeSerializer(nil)

        let data = "[{ \"name\": \"platypus\", \"star_rating\": 5 }, { \"name\": \"polar_bear\", \"star_rating\": 4 }]".dataUsingEncoding(NSUTF8StringEncoding)
        let result = serializer.serializeResponse(nil, nil, data, nil)
        expect(result.value?.count).to(equal(2))
      }

      it("returns an error when JSON is empty") {
        let serializer: ResponseSerializer<[Animal], NSError> = Request.GenomeSerializer(nil)

        let result = serializer.serializeResponse(nil, nil, NSData(), nil)
        expect(result.error?.localizedDescription).to(match("Input data was nil"))
      }

      it("returns an error when JSON can't be mapped") {
        let serializer: ResponseSerializer<[Animal], NSError> = Request.GenomeSerializer(nil)

        let data = "[{ \"vehicle\": \"train\" }]".dataUsingEncoding(NSUTF8StringEncoding)

        let result = serializer.serializeResponse(nil, nil, data, nil)
        expect(result.error?.localizedDescription).to(match("FoundNil"))
      }

      it("allows for specifying keypath") {
        let serializer: ResponseSerializer<[Animal], NSError> = Request.GenomeSerializer("animals")

        let data = "{ \"animals\": [{ \"name\": \"platypus\", \"star_rating\": 5 }, { \"name\": \"polar_bear\", \"star_rating\": 4 }] }".dataUsingEncoding(NSUTF8StringEncoding)
        let result = serializer.serializeResponse(nil, nil, data, nil)
        expect(result.value?.count).to(equal(2))
      }
    }
  }

}