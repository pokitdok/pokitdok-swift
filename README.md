# Pokitdok Platform API Client for Swift

Built in Swift 3 to make development using Pokitdok APIs easier and more convenient.

## Resources
* [Read the PokitDok API docs][apidocs]
* [View Source on GitHub][code]
* [Report Issues on GitHub][issues]

[apidocs]: https://platform.pokitdok.com/documentation/v4#/
[code]: https://github.com/pokitdok/pokitdok-swift
[issues]: https://github.com/pokitdok/pokitdok-swift/issues

## Installation

### CocoaPods Install

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```
- To integrate Pokitdok into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.1'
use_frameworks!

target '<Your Target Name>' do
    pod 'pokitdok', '~> 0.1.1'
end
```
- Finally, run the following command:

```bash
$ pod install
```

- Open the .xcworkspace file, and continue to develop using our awesome client! Note: after pod install, you must use the the .xcworkspace file instead of the .xcodeproj file.

### Manual Install

- In a terminal, cd to your project directory, and initialize your project as a git repository (if you have not already):

  ```bash
$ git init
```

- Add Pokitdok as a git submodule:

  ```bash
$ git submodule add https://github.com/pokitdok/pokitdok-swift.git
```

- Open the new `pokitdok-swift` folder to drag the `pokitdok.xcodeproj` into the Project Navigator of your application's Xcode project, and place it somewhere under your blue Xcode project icon.

- Select the `pokitdok.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.

- Next, select your application project in the Project Navigator (blue project icon), navigate to the "General" panel, and find the "Embedded Binaries" section.

- Click on the `+` button under the "Embedded Binaries" section.

- Select the top `pokitdok.framework` and add it.

## Quick Start
```swift
import pokitdok

let client_id = "<your-client-id>"
let client_secret = "<your-client-secret>"
let client = try Pokitdok(clientId: client_id, clientSecret: client_secret)

let elig_args = [
    "member": [
        "birth_date" : "1970-01-25",
        "first_name" : "Jane",
        "last_name" : "Doe",
        "id": "W000000000"
    ],
    "provider": [
        "first_name" : "JEROME",
        "last_name" : "AYA-AY",
        "npi" : "1467560003"
    ],
    "trading_partner_id": "MOCKPAYER"
] as [String : Any]
        
let elig_response = try client.eligibility(params: elig_args)
```
## Making Requests

The client offers a few options for making API requests. High level functions are available for each of the APIs for convenience. If your application would prefer to interact with the APIs at a lower level, you may elect to use the general purpose request method or one of the http method aliases built around it.

```swift
// A low level "request" method is available
let act_response = try client.request(path: "/activities", method: "GET")

let elig_args = [
    "member": [
        "birth_date" : "1970-01-25",
        "first_name" : "Jane",
        "last_name" : "Doe",
        "id": "W000000000"
    ],
    "provider": [
        "first_name" : "JEROME",
        "last_name" : "AYA-AY",
        "npi" : "1467560003"
    ],
    "trading_partner_id": "MOCKPAYER"
] as [String : Any]
let elig_response = try client.request(path: "/eligibility/", method: "POST", params: elig_args)

// Convenience methods are available for the commonly used http methods built around the request method
let act_response = try client.get(path: "/activities")

let elig_args = [
    "member": [
        "birth_date" : "1970-01-25",
        "first_name" : "Jane",
        "last_name" : "Doe",
        "id": "W000000000"
    ],
    "provider": [
        "first_name" : "JEROME",
        "last_name" : "AYA-AY",
        "npi" : "1467560003"
    ],
    "trading_partner_id": "MOCKPAYER"
] as [String : Any]
let elig_response = try client.post(path: "/eligibility/", params: elig_args)

// Higher level functions are also available to access the APIs
let act_response = try client.activities()

let elig_args = [
    "member": [
        "birth_date" : "1970-01-25",
        "first_name" : "Jane",
        "last_name" : "Doe",
        "id": "W000000000"
    ],
    "provider": [
        "first_name" : "JEROME",
        "last_name" : "AYA-AY",
        "npi" : "1467560003"
    ],
    "trading_partner_id": "MOCKPAYER"
] as [String : Any]
let elig_response = try client.eligibility(params: elig_args)
```
## Authentication
Access to PokitDok APIs is controlled via OAuth2. Most APIs are accessible with an access token acquired via a client credentials grant type, you simply supply your app credentials and you're ready to go:
```swift
import pokitdok

let client_id = "<your-client-id>"
let client_secret = "<your-client-secret>"
let client = try Pokitdok(clientId: client_id, clientSecret: client_secret)
```
*Sidenote*: It is highly recommended that you do not release an iOS app with your Client ID and Client Secret strings baked into the app, as they may be vulnerable to exposure there. A suitable alternative would be to utilize an external identity service that authenticates your users and requests an access token that can then be returned to your app to utilize.

## Updating the Client
If you find a bug or problem with the client, please submit an issue or feel free to create a pull request and we will help to process that request as soon as possible. 

### For Internal Use
After changes have been merged in, please follow the following steps to redeploy the client out to our cocoapods release.
- Tag your changes with the appropriate sequential tag number.
-  Update the `pokitdok.podspec` file and the README.md instructions with the new version_number
-  Merge and Push your new tags into the master branch.
-  Run `pod trunk push pokitdok.podspec` from your terminal, while navigated to the project, to release the new version
