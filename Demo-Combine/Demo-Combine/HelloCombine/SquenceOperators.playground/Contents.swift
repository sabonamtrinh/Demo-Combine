import UIKit
import Combine

// MARK: Finding values

// min
var subscriptions = Set<AnyCancellable>()

let publisher = [1, 0 ,4, 100].publisher

publisher
    .print("Publiher")
    .min()
    .sink(receiveValue: { print("Lowest value is \($0)") })
    .store(in: &subscriptions)

let publisher2 = ["1234",
                    "ab",
                    "hello"]
    .compactMap({ $0.data(using: .utf8) })
    .publisher

publisher2
    .min(by: { $0.count < $1.count })
    .sink { data in
        let string = String(data: data, encoding: .utf8)!
        print("Smallest data is \(string), \(data.count) bytes")
    }
    .store(in: &subscriptions)

// max: Tuong tu

// first
publisher
    .print("publisher")
    .first()
    .sink(receiveValue: { print("First value is \($0)") })
    .store(in: &subscriptions)

// first(where:)
publisher
    .print("publisher")
    .first(where: { $0 % 2 == 0 })
    .sink(receiveValue: { print("First match is \($0)") })
    .store(in: &subscriptions                       )

// last & last(where:) : Tuong tu, nhung khi nao phat di completion moi di tim kiem phan tu cuoi cung

// output(at:)
let pub3 = ["A", "B", "C", "D", "E"].publisher

pub3
    .print("Publisher")
    .output(at: 1)
    .sink(receiveValue: { print("Value at index 1 is \($0)") })
    .store(in: &subscriptions)

// output(in:)

pub3
    .output(in: 1...2)
    .sink(receiveCompletion: { print($0) },
          receiveValue: { print("Value in range: \($0)") })
    .store(in: &subscriptions)

// MARK: Querying the publisher

// count

pub3
    .print("publisher")
    .count()
    .sink(receiveValue: { print("I have \($0) items") })
    .store(in: &subscriptions)

// contains
pub3
    .print("publisher")
    .contains("F")
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

// contains(where:)

// allStisfy : true khi tat cả gia tri thoa man
pub3
    .allSatisfy({ $0.count == 1 })
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

// reduce : Nhom cac gia tri lai voi nhau. Lam giam so luong gia tri

let pub4 = ["Hel", "lo", "Wo", "rld", "!"].publisher

pub4
    .print("Publisher4")
    .reduce("") { accumulator, value in
        accumulator + value
    }
    .sink(receiveValue: { print("Reduced into: \($0)") })
    .store(in: &subscriptions)
