//
//  PokitdokResponse.swift
//  pokitdok
//
// Copyright (C) 2016, All Rights Reserved, PokitDok, Inc.
// https://www.pokitdok.com
//
// Please see the License.txt file for more information.
// All other rights reserved.
//

public struct PokitdokResponse {
    /*
     Struct to hold response information
     :VAR success: Bool? type true or false success of the request
     :VAR response: URLResponse? type response object from server
     :VAR data: Data? type data of the response
     :VAR error: Error? type errors from server
     :VAR json: [String:Any]? type json data translated from response
     :VAR message: String? type conveying messages about response ex(TOKEN_EXPIRED)
     */
    var success: Bool? = false
    var response: URLResponse? = nil
    var data: Data? = nil
    var error: Error? = nil
    var json: Dictionary<String, Any>? = nil
    var message: String? = nil
}
