//
//  Pokitdok.swift
//  pokitdok
//
// Copyright (C) 2016, All Rights Reserved, PokitDok, Inc.
// https://www.pokitdok.com
//
// Please see the License.txt file for more information.
// All other rights reserved.
//

import Foundation

public enum FailedToFetchTokenError : Error {
    /*
        Custom error handling to track client requests
    */
    case CouldNotAuthenticate(String)
}

public class Pokitdok: NSObject {
    /*
     Pokitdok Swift client convenient to send requests to Pokitdok Platform APIs
     */
    
    let username: String
    let password: String
    let urlBase: String
    let tokenUrl: String
    let authUrl: String
    let redirectURI: String?
    let desiredScope: String?
    let autoRefreshToken: Bool
    let tokenCallback: String?
    let authCode: String?
    var accessToken: String? = nil
    
    public init(clientId: String, clientSecret: String, basePath: String = "https://platform.pokitdok.com", version: String = "v4",
         redirectUri: String? = nil, scope: String? = nil, autoRefresh: Bool = false, tokenRefreshCallback: String? = nil,
         code: String? = nil, token: String? = nil) throws {
        /*
         Initialize necessary variables
         :PARAM clientId: String type client ID for OAuth client credentials flow
         :PARAM clientSecret: String type client secret for OAuth client credentials flow
         :PARAM basePath: String type url path that other urls will be based off
         :PARAM version: String type version of api, defaulted to "v4"
         :PARAM redirectUri: String? type redirect path used to authorize via Oauth authorization grant flow
         :PARAM scope: String? type scope used to authorize via Oauth authorization grant flow
         :PARAM autoRefresh: Bool type should the client refetch access tokens automatically?
         :PARAM tokenRefreshCallback: String? type token callback used to authorize via Oauth authorization grant flow
         :PARAM code: String? type authorization code used to authorize via Oauth authorization grant flow
         :PARAM token: String? type access token used to access Pokitdok APIs
         */
        
        username = clientId
        password = clientSecret
        urlBase = basePath + "/api/" + version
        tokenUrl = basePath + "/oauth2/token"
        authUrl = basePath + "/oauth2/authorize"
        redirectURI = redirectUri
        desiredScope = scope
        autoRefreshToken = autoRefresh
        tokenCallback = tokenRefreshCallback
        authCode = code
        accessToken = token
        
        super.init()
        if accessToken == nil{
            try fetchAccessToken()
        }
    }
    
    public func fetchAccessToken() throws {
        /*
         Retrieve OAuth2 access token and set it on self.accessToken
         */
        
        let utf8str = "\(username):\(password)".data(using: String.Encoding.utf8)
        let encodedIdSecret = utf8str?.base64EncodedString(options: [])
        let headers = ["Authorization" : "Basic \(encodedIdSecret ?? "")", "Content-Type" : "application/x-www-form-urlencoded"] as Dictionary<String, String>
        let params = ["grant_type" : "client_credentials"] as Dictionary<String, Any>
        
        let tokenResponse = try PokitdokRequest(path: tokenUrl, method: "POST", headers: headers, params: params).call()
        
        if tokenResponse.success == true {
            self.accessToken = tokenResponse.json?["access_token"] as! String?
        } else {
            throw FailedToFetchTokenError.CouldNotAuthenticate("Failed to fetch access token")
        }
    }
    
    public func request(path: String, method: String = "GET", params: Dictionary<String, Any>? = nil, files: Array<FileData>? = nil) throws -> Dictionary<String, Any> {
        /*
         General method for submitting an API request
         :PARAM path: String type partial url to send request to. urlBase will be prepended to path
         :PARAM method: String type http method, defaulted to "GET"
         :PARAM params: [String:Any] type key:value params to send along with request
         :PARAM files: Array(FileData) type holding data about files to send along with request
         :RETURNS responseObject.json: [String:Any] type key:value response from server after request
         */
        
        let requestUrl = urlBase + path
        var headers = ["Content-Type": "application/json"]
        headers["Authorization"] = "Bearer \(accessToken ?? "")"
        
        let requestObject = try PokitdokRequest(path: requestUrl, method: method, headers: headers, params: params, files: files)
        var responseObject = try requestObject.call()
        
        if autoRefreshToken, responseObject.success == false, responseObject.message == "TOKEN_EXPIRED" {
            try fetchAccessToken()
            requestObject.setHeader(key: "Authorization", value: "Bearer \(accessToken ?? "")")
            responseObject = try requestObject.call()
        }
        
        return responseObject.json ?? [:]
    }
    
    public func get(path: String, params: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Convenience GET type method
         :PARAM path: String type partial url to send request to. urlBase will be prepended to path
         :PARAM params: [String:Any] type key:value params to send along with request
         :RETURNS responseObject.json: [String:Any] type key:value response from server after request
         */
        
        return try request(path: path, method: "GET", params: params)
    }
    
    public func put(path: String, params: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Convenience PUT type method
         :PARAM path: String type partial url to send request to. urlBase will be prepended to path
         :PARAM params: [String:Any] type key:value params to send along with request
         :RETURNS responseObject.json: [String:Any] type key:value response from server after request
         */
        
        return try request(path: path, method: "PUT", params: params)
    }
    
    public func post(path: String, params: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Convenience POST type method
         :PARAM path: String type partial url to send request to. urlBase will be prepended to path
         :PARAM params: [String:Any] type key:value params to send along with request
         :RETURNS responseObject.json: [String:Any] type key:value response from server after request
         */
        
        return try request(path: path, method: "POST", params: params)
    }
    
    public func delete(path: String, params: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Convenience DELETE type method
         :PARAM path: String type partial url to send request to. urlBase will be prepended to path
         :PARAM params: [String:Any] type key:value params to send along with request
         :RETURNS responseObject.json: [String:Any] type key:value response from server after request
         */
        
        return try request(path: path, method: "DELETE", params: params)
    }
    
    public func activities(activityId: String? = nil, activitiesRequest: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Fetch platform activity information
         :PARAM activityId: String type activity ID
         :PARAM activitiesRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/activities/\(activityId ?? "")"
        let method = "GET"
        
        return try request(path: path, method: method, params: activitiesRequest)
    }
    
    public func authorizations(authorizationsRequest: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Submit an authorization request
         :PARAM authorizationsRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/authorizations/"
        let method = "POST"
        
        return try request(path: path, method: method, params: authorizationsRequest)
    }
    
    public func cashPrices(cptCode: String, zipCode: String) throws -> Dictionary<String, Any> {
        /*
         Fetch cash price information
         :PARAM cptCode: String type cpt code of procedure
         :PARAM zipCode: String type zip code area to search for prices
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/prices/cash"
        let method = "GET"
        let cashPricesRequest = ["cpt_code": cptCode, "zip_code" : zipCode]
        
        return try request(path: path, method: method, params: cashPricesRequest)
    }
    
    public func ccd(ccdRequest: Dictionary<String, Any>) throws -> Dictionary<String, Any> {
        /*
         Submit a continuity of care document (CCD) request
         :PARAM ccdRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/ccd/"
        let method = "POST"
        
        return try request(path: path, method: method, params: ccdRequest)
    }
    
    public func claims(claimsRequest: Dictionary<String, Any>) throws -> Dictionary<String, Any> {
        /*
         Submit a claims request
         :PARAM claimsRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/claims/"
        let method = "POST"
        
        return try request(path: path, method: method, params: claimsRequest)
    }
    
    public func claimsStatus(claimsStatusRequest: Dictionary<String, Any>) throws -> Dictionary<String, Any> {
        /*
         Submit a claims status request
         :PARAM claimsStatusRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/claims/status"
        let method = "POST"
        
        return try request(path: path, method: method, params: claimsStatusRequest)
    }
    
    public func claimsConvert(x12ClaimsFilePath: String) throws -> Dictionary<String, Any> {
        /*
         Submit a raw X12 837 file to convert to a claims API request and map any ICD-9 codes to ICD-10
         :PARAM x12ClaimsFilePath: path to x12 claims file to be transmitted
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/claims/convert"
        let method = "POST"
        let file = FileData(path: x12ClaimsFilePath, contentType: "application/EDI-X12")
        
        return try request(path: path, method: method, files: [file])
    }
    
    public func eligibility(eligibilityRequest: Dictionary<String, Any>) throws -> Dictionary<String, Any> {
        /*
         Submit an eligibility request
         :PARAM eligibilityRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/eligibility/"
        let method = "POST"
        
        return try request(path: path, method: method, params: eligibilityRequest)
    }
    
    public func enrollment(enrollmentRequest: Dictionary<String, Any>) throws -> Dictionary<String, Any> {
        /*
         Submit a benefits enrollment/maintenance request
         :PARAM enrollmentRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/enrollment"
        let method = "POST"
        
        return try request(path: path, method: method, params: enrollmentRequest)
    }
    
    public func enrollmentSnapshot(tradingPartnerId: String, x12FilePath: String) throws -> Dictionary<String, Any> {
        /*
         Submit a X12 834 file to the platform to establish the enrollment information within it
         as the current membership enrollment snapshot for a trading partner
         :PARAM tradingPartnerId: String type id of trading partner
         :PARAM x12FilePath: path to x12 enrollment file to be transmitted
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/enrollment/snapshot"
        let method = "POST"
        let params = ["trading_partner_id": tradingPartnerId]
        let file = FileData(path: x12FilePath, contentType: "application/EDI-X12")
        
        return try request(path: path, method: method, params: params, files: [file])
    }
    
    public func enrollmentSnapshots(snapshotId: String? = nil, snapshotsRequest: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         List enrollment snapshots that are stored for the client application
         :PARAM snapshotId: String? type id of snapshot
         :PARAM snapshotsRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/enrollment/snapshot/\(snapshotId ?? "")"
        let method = "GET"
        
        return try request(path: path, method: method, params: snapshotsRequest)
    }
    
    public func enrollmentSnapshotData(snapshotId: String) throws -> Dictionary<String, Any> {
        /*
         List enrollment request objects that make up the specified enrollment snapshot
         :PARAM snapshotId: String? type id of snapshot
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/enrollment/snapshot/\(snapshotId)/data"
        let method = "GET"
        
        return try request(path: path, method: method)
    }
    
    public func icdConvert(code: String) throws -> Dictionary<String, Any> {
        /*
         Locate the appropriate diagnosis mapping for the specified ICD-9 code
         :PARAM code: String type ICD-9 code to be converted
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/icd/convert/\(code)"
        let method = "GET"
        
        return try request(path: path, method: method)
    }
    
    public func insurancePrices(cptCode: String, zipCode: String) throws -> Dictionary<String, Any> {
        /*
         Fetch insurance price information
         :PARAM cptCode: String type cpt code of procedure
         :PARAM zipCode: String type zip code area to search for prices
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/prices/insurance"
        let method = "GET"
        let insurancePricesRequest = ["cpt_code": cptCode, "zip_code" : zipCode]
        
        return try request(path: path, method: method, params: insurancePricesRequest)
    }
    
    public func mpc(code: String? = nil, name: String? = nil, description: String? = nil) throws -> Dictionary<String, Any> {
        /*
         Access clinical and consumer friendly information related to medical procedures
         :PARAM code: String? type mpc code to search on
         :PARAM name: String? type name of procedure to search on
         :PARAM description: String? type description of procedure to search on
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/mpc/\(code ?? "")"
        let method = "GET"
        var mpcRequest: [String: String] = [:]
        if let name = name { mpcRequest["name"] = name }
        if let description = description { mpcRequest["description"] = description }
        
        return try request(path: path, method: method, params: mpcRequest)
    }
    
    public func oopLoadPrice(oopLoadPriceRequest: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Load pricing data to OOP endpoint
         :PARAM oopLoadPriceRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        let path = "/oop/insurance-load-price"
        let method = "POST"
        
        return try request(path: path, method: method, params: oopLoadPriceRequest)
    }
    
    public func oopEstimate(oopEstimateRequest: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Fetch OOP estimate
         :PARAM oopEstimateRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        let path = "/oop/insurance-estimate"
        let method = "POST"
        
        return try request(path: path, method: method, params: oopEstimateRequest)
    }
    
    public func payers(payersRequest: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Fetch payer information for supported trading partners
         :PARAM payersRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/payers/"
        let method = "GET"
        
        return try request(path: path, method: method, params: payersRequest)
    }
    
    public func plans(plansRequest: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Fetch insurance plans information
         :PARAM plansRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/plans"
        let method = "GET"
        
        return try request(path: path, method: method, params: plansRequest)
    }
    
    public func providers(npi: String? = nil, providersRequest: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Search health care providers in the PokitDok directory
         :PARAM npi: String? type npi to search on
         :PARAM providersRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/providers/\(npi ?? "")"
        let method = "GET"
        
        return try request(path: path, method: method, params: providersRequest)
    }
    
    public func tradingPartners(tradingPartnerId: String? = nil) throws -> Dictionary<String, Any> {
        /*
         Search trading partners in the PokitDok Platform
         :PARAM tradingPartnerId: String? type id of trading partner to fetch
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/tradingpartners/\(tradingPartnerId ?? "")"
        let method = "GET"
        
        return try request(path: path, method: method)
    }
    
    public func referrals(referralRequest: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Submit a referral request
         :PARAM referralRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/referrals/"
        let method = "POST"
        
        return try request(path: path, method: method, params: referralRequest)
    }
    
    public func schedulers(schedulerUuid: String? = nil) throws -> Dictionary<String, Any> {
        /*
         Get information about supported scheduling systems or fetch data about a specific scheduling system
         :PARAM schedulerUuid: String? type uuid of scheduler to fetch
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/schedule/schedulers/\(schedulerUuid ?? "")"
        let method = "GET"
        
        return try request(path: path, method: method)
    }
    
    public func appointmentTypes(appointmentTypeUuid: String? = nil) throws -> Dictionary<String, Any> {
        /*
         Get information about appointment types or fetch data about a specific appointment type
         :PARAM appointmentTypeUuid: String? type uuid of appointment type to fetch
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/schedule/appointmenttypes/\(appointmentTypeUuid ?? "")"
        let method = "GET"
        
        return try request(path: path, method: method)
    }
    
    public func scheduleSlots(slotsRequest: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Submit an open slot for a provider's schedule
         :PARAM slotsRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/schedule/slots/"
        let method = "POST"
        
        return try request(path: path, method: method, params: slotsRequest)
    }
    
    public func appointments(appointmentUuid: String? = nil, appointmentsRequest: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Query for open appointment slots or retrieve information for a specific appointment
         :PARAM appointmentUuid: String? type uuid of appointment to fetch
         :PARAM appointmentsRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/schedule/appointments/\(appointmentUuid ?? "")"
        let method = "GET"
        
        return try request(path: path, method: method, params: appointmentsRequest)
    }
    
    public func bookAppointment(appointmentUuid: String, appointmentRequest: Dictionary<String, Any>) throws -> Dictionary<String, Any> {
        /*
         Book an appointment
         :PARAM appointmentUuid: String type uuid of appointment to book
         :PARAM appointmentRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/schedule/appointments/\(appointmentUuid)"
        let method = "PUT"
        
        return try request(path: path, method: method, params: appointmentRequest)
    }
    
    public func updateAppointment(appointmentUuid: String, appointmentRequest: Dictionary<String, Any>) throws -> Dictionary<String, Any> {
        /*
         Update an appointment
         :PARAM appointmentUuid: String type uuid of appointment to update
         :PARAM appointmentRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/schedule/appointments/\(appointmentUuid)"
        let method = "PUT"
        
        return try request(path: path, method: method, params: appointmentRequest)
    }
    
    public func cancelAppointment(appointmentUuid: String) throws -> Dictionary<String, Any> {
        /*
         Cancel an appointment
         :PARAM appointmentUuid: String type uuid of appointment to cancel
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/schedule/appointments/\(appointmentUuid)"
        let method = "DELETE"
        
        return try request(path: path, method: method)
    }
    
    public func createIdentity(identityRequest: Dictionary<String, Any>) throws -> Dictionary<String, Any> {
        /*
         Creates an identity resource
         :PARAM identityRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/identity/"
        let method = "POST"
        
        return try request(path: path, method: method, params: identityRequest)
    }
    
    public func updateIdentity(identityUuid: String, identityRequest: Dictionary<String, Any>) throws -> Dictionary<String, Any> {
        /*
         Updates an existing identity resource.
         :PARAM identityUuid: String type uuid of identity to update
         :PARAM identityRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/identity/\(identityUuid)"
        let method = "PUT"
        
        return try request(path: path, method: method, params: identityRequest)
    }
    
    public func identity(identityUuid: String? = nil, identityRequest: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Queries for an existing identity resource by uuid or for multiple resources using parameters.
         :PARAM identityUuid: String? type uuid of identity to fetch
         :PARAM identityRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/identity/\(identityUuid ?? "")"
        let method = "GET"
        
        return try request(path: path, method: method, params: identityRequest)
    }
    
    public func identityHistory(identityUuid: String, historicalVersion: String? = nil) throws -> Dictionary<String, Any> {
        /*
         Queries for an identity record's history.
         :PARAM identityUuid: String type uuid of identity's history to fetch
         :PARAM historicalVersion: String? type version of history
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "identity/\(identityUuid)/history/\(historicalVersion ?? "")"
        let method = "GET"
        
        return try request(path: path, method: method)
    }
    
    public func identityMatch(identityMatchData: Dictionary<String, Any>) throws -> Dictionary<String, Any> {
        /*
         Creates an identity match job.
         :PARAM identityMatchData: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/identity/match"
        let method = "POST"
        
        return try request(path: path, method: method, params: identityMatchData)
    }
    
    public func pharmacyPlans(pharmacyPlansRequest: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Search drug plan information by trading partner and various plan identifiers
         :PARAM pharmacyPlansRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/pharmacy/plans"
        let method = "GET"
        
        return try request(path: path, method: method, params: pharmacyPlansRequest)
    }
    
    public func pharmacyFormulary(pharmacyFormularyRequest: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Search drug plan formulary information to determine if a drug is covered by the specified drug plan.
         :PARAM pharmacyFormularyRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/pharmacy/formulary"
        let method = "GET"
        
        return try request(path: path, method: method, params: pharmacyFormularyRequest)
    }
    
    public func pharmacyNetwork(npi: String? = nil, pharmacyNetworkRequest: Dictionary<String, Any>? = nil) throws -> Dictionary<String, Any> {
        /*
         Search for in-network pharmacies
         :PARAM npi: String? type npi to search on
         :PARAM pharmacyNetworkRequest: [String:Any] type parameters to be sent along with request
         :RETURNS json: [String:Any] type key:value response from server after request
         */
        
        let path = "/pharmacy/network/\(npi ?? "")"
        let method = "GET"
        
        return try request(path: path, method: method, params: pharmacyNetworkRequest)
    }
    
}
