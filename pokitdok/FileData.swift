//
//  FileData.swift
//  pokitdok
//
// Copyright (C) 2016, All Rights Reserved, PokitDok, Inc.
// https://www.pokitdok.com
//
// Please see the License.txt file for more information.
// All other rights reserved.
//

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
