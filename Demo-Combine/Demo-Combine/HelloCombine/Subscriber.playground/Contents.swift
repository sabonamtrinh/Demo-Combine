import UIKit
import Combine

// A protocol that declares a type that can receive input from a publisher.

// MARK: Assign

class Dog {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

let dog = Dog(name: "Milo")
print("Dog name is \(dog.name)")

let subscriber = Subscribers.Assign(object: dog, keyPath: \.name)

let publisher = Just("Mic")
publisher.subscribe(subscriber)
print("Dog name is \(dog.name)")


// MARK: Sink

let subscriber2 = Subscribers.Sink<String, Never> { completion in
    print(completion)
} receiveValue: { name in
    dog.name = name
}

let publisher2 = PassthroughSubject<String, Never>()
publisher2.subscribe(subscriber2)

publisher2.send("Milu")
print("Dog name is \(dog.name)")
publisher2.send(completion: .finished)
print("Dog name is \(dog.name)")


// MARK: AnyCancellable

let publisher3 = PassthroughSubject<String, Never>()
let cancellable = publisher3.sink { completion in
    print(completion)
} receiveValue: { name in
    dog.name = name
}

let cancellable2 = publisher3.assign(to: \.name, on: dog)

// không thể tạo nhiều đối tượng cancellable cho 1 lần subscriber. Nên quản lý tập trung

var subscriptions = Set<AnyCancellable>()

let publisher4 = PassthroughSubject<String, Never>()

// sub1
publisher3.sink { completion in
    print(completion)
} receiveValue: { value in
    print(value)
}
.store(in: &subscriptions)

// sub2

publisher4
    .assign(to: \.name, on: dog)
    .store(in: &subscriptions)

// Eg:
class ViewModel {
    var subscriptions = Set<AnyCancellable>()
    
    deinit {
        subscriptions.removeAll()
    }
}


// MARK: Custom Subscriber

// Define class

final class IntSubscriber: Subscriber {
    
    typealias Input = Int
    typealias Failure = Never
    
    func receive(subscription: Subscription) {
        subscription.request(.max(1)) // lấy 1 giá trị đầu tiên
    }
    
    func receive(_ input: Int) -> Subscribers.Demand {
        print("Receive value:", input)
        return .unlimited // lấy hết
        //     .none         không lấy thêm phần tử nào nữa
        //     .value        lấy n phần tử tiếp theo
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("Receive completion:", completion)
    }
}

let publisher5 = (1...10).publisher

let subInt = IntSubscriber()
publisher5.subscribe(subInt)


// Dynamically adjusting Demand

final class Student {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Student: Subscriber {
    typealias Input = String
    typealias Failure = Never
    
    func receive(subscription: Subscription) {
        subscription.request(.max(3))
    }
    
    func receive(_ input: String) -> Subscribers.Demand {
        self.name = input
        return .unlimited
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("Receive completion", completion)
    }
}

let student = Student(name: "Nam")
print("Student name is \(student.name)")

let publisher6 = PassthroughSubject<String, Never>()
publisher6.subscribe(student)

publisher6.send("Tung")
print("Student name is \(student.name)")
