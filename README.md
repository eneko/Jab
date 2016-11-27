# Jab
Jab is a Swift 3 library that does synchronous HTTP __JSON__ requests

![](https://img.shields.io/cocoapods/v/Jab.svg)
![](http://img.shields.io/badge/iOS-8.4%2B-blue.svg)
![](http://img.shields.io/badge/Swift-3.0.1-orange.svg)

Many iOS, command line or server side applications rely on getting or sending
JSON from/to some remote server on Internet or local network.

Jab is a tiny library that handles those JSON network requests for you,
including serialization of payloads (anything serializable by JSONSerialization)
and deserialization of responses.

## Simple requests without Futures, Promises or Callback blocks

```swift
let clients = try Jab().get(url: "http://example.com/clients")
```

```swift
let newClient: [String, Any] = [
    "first_name": "Jon",
    "last_name": "Doe",
    "age": 31
]
try Jab().post(url: "http://example.com/clients", payload: newClient)
```

## Sequential requests

```swift
let bob = try Jab().get(url: "http://example.com/clients/bob")
let alice = try Jab().get(url: "http://example.com/clients/alice")
let janey = try Jab().get(url: "http://example.com/clients/janey")
return [bob, alice, janey]
```

Synchronous network requests are great for many reasons:
- Simplify business logic
- Allow for natural chaining of operations
- Delegate control of UI workflows to your application UI layer.

See more working sample requests in our [Integration Tests](/Tests/IntegrationTests.swift).


## Error handling

Jab uses [Swift exception based error handling](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/ErrorHandling.html).

The following are all errors thrown by Jab if something bad happens:

```swift
public enum JabError: Error {
    case offline
    case invalidRequest
    case serialization
    case deserialization
    case noResponse
    case requestFailed(error: Error)
}
```

## Mind your application user interface

If you are using Jab in an application with a graphic user interface, make sure
to run any requests in a background thread with the proper QoS priority:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        do {
          self?.clients = try Jab().get(url: "http://example.com/clients.json")
        } catch {
          // Handle errors accordingly
          self.clients = nil
        }
        DispatchQueue.main.async {
            self?.tableView.reloadData()
        }
}
```
