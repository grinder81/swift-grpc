import UIKit
import Combine

func returnFuture() -> AnyPublisher<String, Never> {
    Deferred {
        Future<String, Never> { promise in
            print("Creating Future")
            promise(.success("Hello World!"))
        }
    }.eraseToAnyPublisher()
}

let f = returnFuture()
var store = Set<AnyCancellable>()

//f.sink(receiveCompletion: { complete in
//    print(complete)
//}) { (str) in
//    print(str)
//}
//.store(in: &store)

print("✅")
