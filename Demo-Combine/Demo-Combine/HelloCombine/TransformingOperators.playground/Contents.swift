import UIKit
import Combine

// MARK: Collecting value

var subscription = Set<AnyCancellable>()

let publisher = (1...99).publisher

publisher
    .collect()
    .sink { complete in
        print(complete)
    } receiveValue: { value in
        print(value)
    }
    .store(in: &subscription)

// Mapping value

let formatter = NumberFormatter()
formatter.numberStyle = .spellOut

[11, 02, 1999].publisher
    .map {
        formatter.string(for: NSNumber(integerLiteral: $0)) ?? "" }
    .sink(receiveValue: {print($0) })
    .store(in: &subscription)


// MARK: Map key paths

//      map<T>(_:)
//      map<T0, T1>(_:, _:)
//      map<T0, T1, T2>(_:, _:, _:)

struct Student {
    var name: String
    var age: Int
}

let publisher1 = [Student(name: "Nam", age: 22),
                  Student(name: "Tung", age: 20),
                  Student(name: "Hoang", age: 21)].publisher

publisher1
    .map(\.name)
    .sink(receiveValue: { print($0) })
    .store(in: &subscription)

// tryMap

Just("Dayladuongdantoiimage")
    .tryMap { try URL(string: $0) }
    .sink { complete in
        print(complete)
    } receiveValue: { value in
        print("Value", value ?? "")
    }
    .store(in: &subscription)


// MARK: flatMap

public struct Chatter {
    public let name: String
    public let message: CurrentValueSubject<String, Never>
    public init(name: String, message: String) {
        self.name = name
        self.message = CurrentValueSubject(message)
    }
}

let nam = Chatter(name: "Nam", message: "-- Nam joined --")
let nu = Chatter(name: "Nu", message: "-- Nu joined --")

let chat = PassthroughSubject<Chatter, Never>()

chat
    .flatMap { $0.message }
    .sink(receiveValue: { print($0) })
    .store(in: &subscription)
//
//chat.send(nam)
//nam.message.value = "Nam: Cau an com chua :))"
//
//
//chat.send(nu)
//nu.message.value = "Chua"
//
// MARK: Replacing upstream output

// replacingNil(with:)

["A", nil, "B"].publisher
    .replaceNil(with: "-")
    .sink(receiveValue: { print($0 ?? "") })
    .store(in: &subscription)

// replaceEmpty(with:)

let empty = Empty<Int, Never>()

empty.replaceEmpty(with: 1)
    .sink(receiveValue: { print($0) })
    .store(in: &subscription)

// Scan

let pub = (0...5).publisher

pub.scan(0, { $0 + $1})
    .sink(receiveValue: { print($0) })
    .store(in: &subscription)
