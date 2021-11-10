import UIKit
import Combine


// MARK: Filtering basic

// filter
var subscripton = Set<AnyCancellable>()

let numbers = (1...10).publisher

numbers
    .filter { $0.isMultiple(of: 3) }
    .sink { value in
        print("\(value) is a multiple of 3!")
    }
    .store(in: &subscripton)

// removeDuplicates

let words = "Thoi tiet hom nay nay, dep qua qua di."
    .components(separatedBy: " ")
    .publisher

words
    .removeDuplicates()
    .sink { print($0) }
    .store(in: &subscripton)

// MARK: Compacing & ignoring

// compactMap : Loai bo gia tri optional hoac nil

let strings = ["a", "3.4", "3", "def", "0.45"].publisher

strings
    .compactMap { Float($0) }
    .sink(receiveValue: { print($0) })
    .store(in: &subscripton)


// ignoreOutput: Loai tru het tat ca thanh phan phat ra toi luc nhan completion

let numbers2 = (1...10_000_000).publisher

numbers2
    .ignoreOutput()
    .sink(receiveCompletion: { complete in
        print("Completed with: \(complete)")
    }, receiveValue: { value in
        print("Value: \(value)")
    })
    .store(in: &subscripton)


// MARK: Finding value

// first(where:): tim kiem phan tu dau tien thoa man sau do tu completion


numbers
    .first(where: { $0 % 2 == 0 })
    .sink(receiveValue: { print("First value: \($0)") })
    .store(in: &subscripton)


// last(where:): tim kiem phan tu cuoi cung thoa man truoc khi co completion

numbers
    .last(where: { $0 % 2 == 0 })
    .sink(receiveValue: { print("Last value : \($0)") })
    .store(in: &subscripton)


// MARK: Dropping values

// dropFirst: Bo di n phan tu dau tien

let chars = ["a","b","c","e","f","g","h","i","k","l","m","n"].publisher

chars
    .dropFirst(8)
    .sink(receiveValue: { print($0) })
    .store(in: &subscripton)

// drop(while:): bo di nhung phan tu thoa man

numbers
    .drop(while: {
        return $0 % 5 != 0
    })
    .sink(receiveValue: { print($0) })
    .store(in: &subscripton)

// drop(untilOutputFrom:)

let isReady = PassthroughSubject<Void, Never>()
let taps = PassthroughSubject<Int, Never>()

taps
  .drop(untilOutputFrom: isReady)
  .sink(receiveValue: { print($0) })
  .store(in: &subscripton)

(1...15).forEach { n in
  taps.send(n)
  
  if n == 3 {
    isReady.send()
  }
}

// MARK: Litmit Values

// prefix(:) giu lai cac phan tu dau tien toi index do
// prefix(while:) giu lai cac phan tu cho den khi dk ko thoa man nua
// prefix(untilOutputFrom:) giu lai cac phan tu cho den khi nhan su kien tu 1 publisher khac


