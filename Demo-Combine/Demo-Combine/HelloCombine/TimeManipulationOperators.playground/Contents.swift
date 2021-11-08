import UIKit
import Combine

// MARK: Delay

var subscriptions = Set<AnyCancellable>()

let value = 1.0
let delay = 2.0

let publisher = PassthroughSubject<Date, Never>()
let delayPublisher = publisher.delay(for: .seconds(delay), scheduler: DispatchQueue.main)

publisher
    .sink(receiveCompletion: { print("Completed", $0)},
          receiveValue: { print("Source ", $0) })
    .store(in: &subscriptions)

delayPublisher
    .sink(receiveCompletion: { print("Completed", $0)}, receiveValue: { print("Delay  ",$0) })
    .store(in: &subscriptions)

DispatchQueue.main.async {
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
        publisher.send(Date())
    }
}


// MARK: Collecting values
print("=======================")
let collectTime = 4

let sourcePublisher = PassthroughSubject<Int, Never>()

let collectedPublisher = sourcePublisher
    .collect(.byTime(DispatchQueue.main, .seconds(collectTime)))
    .flatMap { date in
        date.publisher
    }

let collectedPublisher2 = sourcePublisher
        .collect(.byTimeOrCount(DispatchQueue.main, .seconds(collectTime), 3))
        .flatMap { dates in dates.publisher }

sourcePublisher
    .sink(receiveCompletion: { print("\(Date()) - 🔵 complete: ", $0) }) { print("\(Date()) - 🔵: ", $0)}
    .store(in: &subscriptions)
collectedPublisher
   .sink(receiveCompletion: { print("\(Date()) - 🔴 complete: \($0)") }) { print("\(Date()) - 🔴: \($0)")}
   .store(in: &subscriptions)
DispatchQueue.main.async {
    sourcePublisher.send(0)
  
    var count = 1
    Timer.scheduledTimer(withTimeInterval: 1.0 / value, repeats: true) { _ in
        sourcePublisher.send(count)
        count += 1
    }
}


// MARK: Holding off on events

// debounce
func printDate() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.S"
    return formatter.string(from: Date())
}

//data
let typingHelloWorld: [(TimeInterval, String)] = [
  (0.0, "H"),
  (0.1, "He"),
  (0.2, "Hel"),
  (0.3, "Hell"),
  (0.5, "Hello"),
  (0.6, "Hello "),
  (2.0, "Hello W"),
  (2.1, "Hello Wo"),
  (2.2, "Hello Wor"),
  (2.4, "Hello Worl"),
  (2.5, "Hello World")
]

//subject
let subject = PassthroughSubject<String, Never>()
//debounce publisher
let debounced = subject
    .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
    .share()
//subscription
subject
    .sink { string in
        print("\(printDate()) - 🔵 : \(string)")
    }
    .store(in: &subscriptions)
debounced
    .sink { string in
        print("\(printDate()) - 🔴 : \(string)")
    }
    .store(in: &subscriptions)
//loop
let now = DispatchTime.now()
for item in typingHelloWorld {
    DispatchQueue.main.asyncAfter(deadline: now + item.0) {
        subject.send(item.1)
    }
}

// throttle

//debounce publisher
let throttle = subject
    .throttle(for: .seconds(1.0), scheduler: DispatchQueue.main, latest: true)
    .share()
//subscription
subject
    .sink { string in
        print("\(printDate()) - 🔵 : \(string)")
    }
    .store(in: &subscriptions)
throttle
    .sink { string in
        print("\(printDate()) - 🔴 : \(string)")
    }
    .store(in: &subscriptions)
//loop

for item in typingHelloWorld {
    DispatchQueue.main.asyncAfter(deadline: now + item.0) {
        subject.send(item.1)
    }
}

// MARK: Timing out
enum TimeoutError: Error {
    case timedOut
}

let subject2 = PassthroughSubject<Void, TimeoutError>()

let timeoutSubject = subject2.timeout(.seconds(5),
                                      scheduler: DispatchQueue.main,
                                      customError: { .timedOut })
    
    subject2
        .sink(receiveCompletion: { print("\(printDate()) - 🔵 completion: ", $0) }) { print("\(printDate()) - 🔵 : event")}
        .store(in: &subscriptions)
    
    timeoutSubject
        .sink(receiveCompletion: { print("\(printDate()) - 🔴 completion: ", $0) }) { print("\(printDate()) - 🔴 : event")}
        .store(in: &subscriptions)
    
    print("\(printDate()) - BEGIN")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        subject2.send()
    }


// MARK: Measuring time
let measureSubject = subject.measureInterval(using: DispatchQueue.main)
let measureSubject2 = subject.measureInterval(using: RunLoop.main)
//subscription
subject
    .sink { string in
        print("\(printDate()) - 🔵 : \(string)")
    }
    .store(in: &subscriptions)
measureSubject
    .sink { string in
        print("\(printDate()) - 🔴 : \(string)")
    }
    .store(in: &subscriptions)
measureSubject2
    .sink { string in
        print("\(printDate()) - 🔶 : \(string)")
    }
    .store(in: &subscriptions)

//loop
for item in typingHelloWorld {
    DispatchQueue.main.asyncAfter(deadline: now + item.0) {
        subject.send(item.1)
    }
}
