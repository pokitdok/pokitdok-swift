//
//  PokitdokRequest.swift
//  pokitdok
//
// Copyright (C) 2016, All Rights Reserved, PokitDok, Inc.
// https://www.pokitdok.com
//
// Please see the License.txt file for more information.
// All other rights reserved.
//

import Foundation

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

public class PokitdokRequest: NSObject {
    /*
     Class to facilitate a single HTTP request and the resulting response
     Capable of packaging and transmitting all necessary parameters of the request and translating a JSON response back from the server
     
     :VAR requestObject: URLRequest type object used to hold all request transmission information
     :VAR responseObject: PokitdokResponse type object used to hold response information
     */
    
    var requestObject: URLRequest
    var responseObject: PokitdokResponse
    
    public init(path: String, method: String = "GET", headers: Dictionary<String, String>? = nil, params: Dictionary<String, Any>? = nil, files: Array<FileData>? = nil) throws {
        /*
         Initialize requestObject variables
         :PARAM path: String type url path for request
         :PARAM method: String type http method for request, defaulted to "GET"
         :PARAM headers: [String:String] type key:value headers for request
         :PARAM params: [String:Any] type key:value parameters for request
         :PARAM files: Array(FileData) type array of file information to accompany request
         */
        requestObject = URLRequest(url: NSURL(string: path)! as URL)
        responseObject = PokitdokResponse()
        super.init()
        
        requestObject.httpMethod = method
        buildRequestHeaders(headers: headers)
        try buildRequestBody(params: params, files: files)
    }
    
    public func call() throws -> PokitdokResponse {
        /*
         Send the request off and return result
         :RETURNS responseObject: PokitdokResponse type holding all the response information
         */
        let sema = DispatchSemaphore( value: 0 )
        URLSession.shared.dataTask(with: requestObject, completionHandler: { (data, response, error) -> Void in
            self.responseObject.response = response
            self.responseObject.data = data
            self.responseObject.error = error
            
            if let response = response as? HTTPURLResponse {
                if 200...299 ~= response.statusCode {
                    self.responseObject.success = true
                } else if 401 ~= response.statusCode {
                    self.responseObject.message = "TOKEN_EXPIRED"
                }
            }
            sema.signal() // signal request is complete
        }).resume()
        sema.wait() // wait for request to complete
        
        if let data = responseObject.data {
            do {
                responseObject.json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! Dictionary<String, Any>
            } catch {
                throw DataConversionError.FromJSON("Failed to parse JSON from data")
            }
        }
        
        return responseObject
    }
    
    private func buildRequestHeaders(headers: Dictionary<String, String>? = nil){
        /*
         Set the header values on the requestObject
         :PARAM headers: [String:Any] type key:value headers for the request
         */
        if let headers = headers {
            for (key, value) in headers { setHeader(key: key, value: value) }
        }
    }
    
    private func buildRequestBody(params: Dictionary<String, Any>? = nil, files: Array<FileData>? = nil) throws -> Void {
        /*
         Create the data body of the request and set it on the requestObject
         :PARAM params: [String:Any] type key:value parameters to be sent with request
         :PARAM files: Array(FileData) type array of file information to be sent with request
         */
        var body = Data()
        if let files = files {
            let boundary = "Boundary-\(UUID().uuidString)"
            setHeader(key: "Content-Type", value: "multipart/form-data; boundary=\(boundary)")
            if let params = params {
                for (key, value) in params {
                    body.append("--\(boundary)\r\n".data(using: .utf8)!)
                    body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)\r\n".data(using: .utf8)!)
                }
            }
            for file in files {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                try body.append(file.httpEncode())
            }
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        } else {
            if let params = params {
                if getMethod() == "GET" {
                    setPath(path: "\(getPath())?\(buildParamString(params: params))")
                } else {
                    let contentType = getHeader(key: "Content-Type")
                    if contentType == "application/json" {
                        do {
                            body = try! JSONSerialization.data(withJSONObject: params, options: [])
                        } catch {
                            throw DataConversionError.ToJSON("Failed to convert params to JSON")
                        }
                    } else if contentType == "application/x-www-form-urlencoded" {
                        body = buildParamString(params: params).data(using: .utf8)!
                    }
                }
            }
        }
        setBody(data: body)
    }
    
    private func buildParamString(params: Dictionary<String, Any>) -> String {
        /*
         Create a url safe parameter string based on a dictionary of key:values
         :PARAM params: [String:Any] type to be encoded to query string
         :RETURNS paramString: String type query string ex(key=val&key2=val2)
         */
        var pcs = [String]()
        for (key, value) in params {
            var valStr = ""
            if let value = value as? String {
                valStr = value
            } else if let value = value as? Dictionary<String, Any> {
                // could use some work here
                valStr = buildParamString(params: value)
            } else if let value = value as? Array<String> {
                // could use some work here
                valStr = value.joined(separator: ",")
            }
            let escapedKey = key.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            let escapedValue = valStr.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            pcs.append("\(escapedKey ?? "")=\(escapedValue ?? "")")
        }
        return pcs.joined(separator: "&")
    }
    
    public func getHeader(key: String) -> String? {
        /*
         Enables user to manipulate headers from outside the class
         return the header at the key from the requestObject
         :PARAM key: String type header name
         :RETURNS value: String? type value at header name
         */
        return requestObject.value(forHTTPHeaderField: key)
    }
    
    public func setHeader(key: String, value: String){
        /*
         Enables user to manipulate headers from outside the class
         set the header to the key: value pair
         :PARAM key: String type header name
         :PARAM value: String type header value
         */
        requestObject.setValue(value, forHTTPHeaderField: key)
    }
    
    public func getMethod() -> String? {
        /*
         getter for httpMethod of requestObject
         :RETURNS httpMethod: String? type http method
         */
        return requestObject.httpMethod
    }
    
    public func setMethod(method: String){
        /*
         setter for httpMethod of requestObject
         :PARAM method: String type http method, ex("GET", "POST", etc.)
         */
        requestObject.httpMethod = method
    }
    
    public func getPath() -> String {
        /*
         getter for url of requestObject
         :RETURNS url: String type url path of requestObject
         */
        return (requestObject.url?.absoluteString)!
    }
    
    public func setPath(path: String){
        /*
         setter for url of requestObject
         :PARAM path: String type to be wrapped by URL and passed to requestObject
         */
        requestObject.url = NSURL(string: path)! as URL
    }
    
    public func getBody() -> Data?{
        /*
         getter for httpBody of the requestObject
         :RETURNS httpBody: Data? type returned from httpBody
         */
        return requestObject.httpBody
    }
    
    public func setBody(data: Data?){
        /*
         setter for httpBody of the requestObject
         :PARAM data: Data? type to be sent into httpBody
         */
        requestObject.httpBody = data
    }
}

public struct FileData {
    /*
     struct to hold file information for transmission
     :VAR path: The file structure path to the file
     :VAR contentType: The content type to be transmitted with the file
     */
    var path: String
    var contentType: String
    
    public func httpEncode() throws -> Data{
        /*
         Encodes file into data for http transmission
         :RETURNS body: Data type filled with content headers and file data
         */
        var body = Data()
        do {
            let url = URL(fileURLWithPath: self.path)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(url.lastPathComponent)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(self.contentType)\r\n\r\n".data(using: .utf8)!)
            body.append(try Data(contentsOf: url))
            body.append("\r\n".data(using: .utf8)!)
        } catch {
            throw DataConversionError.FileEncoding("Failed to encode File for http request")
        }
        return body
    }
}

public enum DataConversionError: Error {
    /*
        Custom request error handling
    */
    case FromJSON(String)
    case ToJSON(String)
    case FileEncoding(String)
}
