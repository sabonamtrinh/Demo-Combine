import UIKit
import Combine

// MARK: Publisher từ giá trị

let helloPublisher = "Hello World!".publisher
let _ = helloPublisher
    .sink { print($0) }

let fibonacciPublisher = [0, 1, 1, 2, 3, 5].publisher
_ = fibonacciPublisher
  .sink { print($0) }

let dictPublisher = [1: "Hello", 2: "World"].publisher
_ = dictPublisher
  .sink { print($0) }

// MARK: Publisher từ biến đổi

let pub1 = (1...10).publisher
let pub2 = pub1.map {
    return $0 * 2
}

pub2.sink {
    print($0)
}

let subscriber = Subscribers.Sink<Int, Never>(receiveCompletion: { completion in
    print(completion)
}, receiveValue: { value in
    print(value)
})

Publishers.Sequence<[Int], Never>(sequence: [1, 2, 3, 4])
      .receive(subscriber: subscriber)

// MARK: Publisher từ các property của Class

class Student {
    @Published var name: String
    @Published var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

let student = Student(name: "Nam", age: 22)

_ = student.$name.sink(receiveValue: { value in
    print("Student name is \(value)")
})

// MARK: Just

let just = Just("Hello World!")

_ = just
    .sink(receiveCompletion: {
       print("Received completion", $0)
    }, receiveValue: {
        print("Received value", $0)
    })

_ = just
    .sink(receiveCompletion: {
        print("Received completion (another)", $0)
    }, receiveValue: {
        print("Received value (another)", $0)
    })

// MARK: Future

var subscriptions = Set<AnyCancellable>()

func futureIncrement(integer: Int,
                     afterDelay delay: TimeInterval) -> Future<Int, Never> {
    Future<Int, Never> { promise in
         print("Original")
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            promise(.success(integer + 1))
        }
    }
}

DispatchQueue.main.async {
    let future = futureIncrement(integer: 1, afterDelay: 3)
    
    future.sink(receiveCompletion: {
        print($0)
    }, receiveValue: {
        print($0)
    })
    .store(in: &subscriptions)
    
    future.sink(receiveCompletion: {
        print("Second", $0)
    },receiveValue: { print("Second", $0) })
    .store(in: &subscriptions)
}

// MARK: Subject

let passthroughSubject = PassthroughSubject<Int, Never>()
passthroughSubject.send(0)

_ = passthroughSubject.sink(receiveValue: { value in
    print("🔵 : \(value)")
})

passthroughSubject.send(1)
passthroughSubject.send(2)

_ = passthroughSubject.sink(receiveValue: { (value) in
  print("🔴 : \(value)")
})

passthroughSubject.send(3)
passthroughSubject.send(4)
passthroughSubject.send(completion: .finished)
passthroughSubject.send(5)


let currentValueSubject = CurrentValueSubject<Int, Never>(0)

_ = currentValueSubject.sink(receiveValue: { (value) in
    print("🔵 : \(value)")
})
// send values
currentValueSubject.send(1)
currentValueSubject.send(2)
currentValueSubject.send(3)
currentValueSubject.send(4)
//subscription 2
_ = currentValueSubject.sink(receiveValue: { (value) in
    print("🔴 : \(value)")
})
// send value
currentValueSubject.send(5)
// Finished
currentValueSubject.send(completion: .finished)
// send value
currentValueSubject.send(6)


// MARK: Type erasure

var subscriptions2 = Set<AnyCancellable>()

let subject = PassthroughSubject<Int, Never>()

let publisher = subject.eraseToAnyPublisher()

publisher.sink { value in
    print(value)
}
.store(in: &subscriptions2)

subject.send(0)
