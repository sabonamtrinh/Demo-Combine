import UIKit
import Combine

var publisher0 = ["H", "e", "l", "l", "o", " ", "W", "o", "r", "l", "d", "!"].publisher

var subscription = publisher0
    .reduce(" ", +)
    .sink { value in
        print(value)
    }

// MARK: Sink

let just = Just("Hello")

let sub1 = just
    .sink(receiveCompletion: {
        print("Received completion", $0)
    }, receiveValue: {
        print("Received value", $0)
    })

let sub2 = just
    .sink(receiveCompletion: {
        print("Received completion (another)", $0)
    },
    receiveValue: {
        print("Received value (another)", $0)
    })

// MARK: Assign

class MyClass {
    var name: String = "" {
        didSet {
            print(name)
        }
    }
}

let obj = MyClass()

let publisher = ["Apple", "IOS", "Combine"].publisher

_ = publisher
    .assign(to: \.name, on: obj)

// MARK: Life cycle

let publisher1 = (1...10).publisher

let sub3 = Subscribers.Sink<Int, Never>(receiveCompletion: { completion in
    print(completion)
}, receiveValue: { value in
    print(value)
})

publisher1.subscribe(sub3)
