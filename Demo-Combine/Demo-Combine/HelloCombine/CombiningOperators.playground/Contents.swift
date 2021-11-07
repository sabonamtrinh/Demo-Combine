import UIKit
import Combine

// MARK: Prepending : Bổ sung giá trị trước khi phát đi

// prepend(Output) : Cung cap truoc cac gia tri cho 1 publisher

var subscriptions = Set<AnyCancellable>()
let publisher = [3, 4].publisher

publisher
    .prepend(1, 2)
    .prepend(0)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

// prepend(Squence): tuong tu nhung them array hoac set

publisher
    .prepend([1, 2])
    .prepend(Set(-1...0))
    .prepend(stride(from: 6, to: 11, by: 2))
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

// prepen(publisher)

let publisher1 = [3, 4].publisher
let publisher2 = PassthroughSubject<Int, Never>()

publisher1
    .prepend(publisher2)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

publisher2.send(-1)
publisher2.send(0)
publisher2.send(completion: .finished)


// MARK: Appending : Ngược lại với prepend
print("===========================")
// append(Output)

publisher
    .append(5, 6)
    .append(7)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

// append(Sequence)

publisher1
    .append(publisher2)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)


// MARK: Advanced combining


// switchToLastest : Nhận được giá trị cuối cùng đc gửi đi
print("==========================")

let pub1 = PassthroughSubject<Int, Never>()
let pub2 = PassthroughSubject<Int, Never>()
let pub3 = PassthroughSubject<Int, Never>()

let publishers = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()

publishers
    .switchToLatest()
    .sink { _ in
        print("Completed!")
    } receiveValue: { value in
        print(value)
    }
    .store(in: &subscriptions)

publishers.send(pub1)
pub1.send(1)
pub1.send(2)

publishers.send(pub2)
pub1.send(3)
pub2.send(4)
pub2.send(5)

publishers.send(pub3)
pub2.send(6)
pub2.send(7)
pub3.send(8)
pub3.send(9)

pub3.send(completion: .finished)
publishers.send(completion: .finished)

print("=======================")
// merge(with:)

pub1
    .merge(with: pub2)
    .sink { _ in
        print("Completed")
    } receiveValue: { value in
        print(value)
    }
    .store(in: &subscriptions)

pub1.send(1)
pub1.send(2)

pub2.send(3)
pub2.send(4)

pub1.send(completion: .finished)
pub2.send(completion: .finished)


print("==========================")
// combineLastest
let pub4 = PassthroughSubject<String, Never>()
let pub5 = PassthroughSubject<Int, Never>()

pub5
    .combineLatest(pub4)
    .sink { _ in
        print("completed")
    } receiveValue: {
        print("P1: \($0), P2: \($1)")
    }
    .store(in: &subscriptions)

pub5.send(1)
pub5.send(2)

pub4.send("a")
pub4.send("b")

pub5.send(3)

pub4.send("c")
// 4
pub5.send(completion: .finished)
pub4.send(completion: .finished)

print("=============================")

// zip
let pub6 = PassthroughSubject<Int, Never>()
let pub7 = PassthroughSubject<String, Never>()

pub6
    .zip(pub7)
    .sink(receiveCompletion: { _ in print("completed!") },
          receiveValue: { print("P1: \($0), P2: \($1)") })
    .store(in: &subscriptions)

pub6.send(1)
pub6.send(2)

pub7.send("A")
pub7.send("B")

pub6.send(3)
pub7.send("C")
pub7.send("D")

pub6.send(completion: .finished)
pub7.send(completion: .finished)
