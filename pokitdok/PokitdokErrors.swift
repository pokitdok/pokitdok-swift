//
//  PokitdokErrors.swift
//  pokitdok
//
// Copyright (C) 2016, All Rights Reserved, PokitDok, Inc.
// https://www.pokitdok.com
//
// Please see the License.txt file for more information.
// All other rights reserved.
//

public enum DataConversionError: Error {
    /*
     Custom request error handling that tracks failures to convert data formats
     */
    case FromJSON(String)
    case ToJSON(String)
    case FileEncoding(String)
}

public enum FailedToFetchTokenError : Error {
    /*
     Custom error handling to track client requests that fail to fetch an access token
     */
    case CouldNotAuthenticate(String)
}
