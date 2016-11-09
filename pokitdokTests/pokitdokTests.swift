//
//  pokitdokTests.swift
//  pokitdokTests
//
// Copyright (C) 2016, All Rights Reserved, PokitDok, Inc.
// https://www.pokitdok.com
//
// Please see the License.txt file for more information.
// All other rights reserved.
//

import XCTest
@testable import pokitdok

class pokitdokTests: XCTestCase {
    
    func testInitPokitdok() throws {
        /*
         Test init of Pokitdok class, make sure everything is unpacked correctly
         */
        let client_id = "<client_id>"
        let client_secret = "<client_secret>"
        let base = "http://localhost:5002"
        let version = "v4"
        let token = "12345"
        let redirect = "http://nowhere"
        let scope = "myScope"
        let tokenCallback = "callback"
        let code = "007"
        let client = try Pokitdok(clientId: client_id, clientSecret: client_secret, basePath: base, version: version, redirectUri: redirect, scope: scope, autoRefresh: true, tokenRefreshCallback: tokenCallback, code: code, token: token)
        XCTAssert(client.username == client_id)
        XCTAssert(client.password == client_secret)
        XCTAssert(client.urlBase == base+"/api/"+version)
        XCTAssert(client.tokenUrl == base+"/oauth2/token")
        XCTAssert(client.authUrl == base+"/oauth2/authorize")
        XCTAssert(client.redirectURI == redirect)
        XCTAssert(client.desiredScope == scope)
        XCTAssert(client.autoRefreshToken == true)
        XCTAssert(client.tokenCallback == tokenCallback)
        XCTAssert(client.authCode == code)
        XCTAssert(client.accessToken == token)
    }
    
    func testPokitdokResponse() {
        /*
         Test default values of PokitdokResponse struct
         */
        let resp = PokitdokResponse()
        XCTAssert(resp.success == false)
        XCTAssert(resp.response == nil)
        XCTAssert(resp.data == nil)
        XCTAssert(resp.error == nil)
        XCTAssert(resp.json == nil)
        XCTAssert(resp.message == nil)
    }
    
    func testFileData() {
        /*
         Test FileData struct functionality
         */
        let file = FileData(path: "/path/to/file.json", contentType: "application/json")
        XCTAssert(file.path == "/path/to/file.json")
        XCTAssert(file.contentType == "application/json")
    }
    
    func testPokitdokRequestHeader() throws {
        /*
         Test setHeader/getHeader method of PokitdokRequest class
         */
        let request = try PokitdokRequest(path: "http://www.apple.com")
        request.setHeader(key: "Content-Type", value: "application/json")
        XCTAssert(request.getHeader(key: "Content-Type") == "application/json")
    }
    
    func testPokitdokRequestPath() throws {
        /*
         Test setPath/getPath method of PokitdokRequest class
         */
        let request = try PokitdokRequest(path: "http://www.apple.com")
        request.setPath(path: "http://www.google.com")
        XCTAssert(request.getPath() == "http://www.google.com")
    }
    
    func testGetPokitdokRequestWithParams() throws {
        /*
         Test a GET method PokitdokRequest class with params
         with contentType application/json
         */
        let path = "http://www.apple.com"
        let headers = ["Content-Type": "application/json"]
        let params = ["trading_partner_id": "MOCKPAYER"]
        let request = try PokitdokRequest(path: path, method: "GET", headers: headers, params: params)
        XCTAssert(request.getMethod()! == "GET")
        XCTAssert(request.getHeader(key: "Content-Type") == "application/json")
        XCTAssert(request.getPath() == "http://www.apple.com?trading_partner_id=MOCKPAYER")
    }
    
    func testPostPokitdokRequestWithParams() throws {
        /*
         Test a POST method PokitdokRequest class with params
         with contentType application/json
         */
        let path = "http://www.apple.com"
        let headers = ["Content-Type": "application/json"]
        let params = ["trading_partner_id": "MOCKPAYER"]
        let request = try PokitdokRequest(path: path, method: "POST", headers: headers, params: params)
        XCTAssert(request.getMethod()! == "POST")
        XCTAssert(request.getHeader(key: "Content-Type") == "application/json")
        XCTAssert(request.getBody()! == "{\"trading_partner_id\":\"MOCKPAYER\"}".data(using: .utf8))
    }
    
    func testPostUrlEncodedPokitdokRequestWithParams() throws {
        /*
         Test a POST method PokitdokRequest class with params
         with contentType application/x-www-form-urlencoded
         */
        let path = "http://www.apple.com"
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
        let params = ["trading_partner_id": "MOCKPAYER"]
        let request = try PokitdokRequest(path: path, method: "POST", headers: headers, params: params)
        XCTAssert(request.getMethod()! == "POST")
        XCTAssert(request.getHeader(key: "Content-Type") == "application/x-www-form-urlencoded")
        XCTAssert(request.getBody() == "trading_partner_id=MOCKPAYER".data(using: .utf8))
    }
    
}
