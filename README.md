# Pokitdok Platform API Client for Swift

Built in Swift 3 to make development using Pokitdok APIs easier and more convenient.

## Resources
* [Read the PokitDok API docs][apidocs]
* [View Source on GitHub][code]
* [Report Issues on GitHub][issues]

[apidocs]: https://platform.pokitdok.com/documentation/v4#/
[code]: https://github.com/pokitdok/pokitdok-swift
[issues]: https://github.com/pokitdok/pokitdok-swift/issues

## Install

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

## Use

### Calling Eligibility

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
        
let elig_response = try client.eligibility(eligibilityRequest: elig_args)
```
