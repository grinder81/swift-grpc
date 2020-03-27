import RouteGuide
import Foundation
import GRPC
import NIO
import Logging
import Combine

protocol RouteGuideType {
    func connect(_ creator: @escaping (EventLoopGroup) -> Routeguide_RouteGuideClientProtocol)
    func disconnect()
    func fetchFeature(latitude: Int, longitude: Int) -> AnyPublisher<Routeguide_Feature, Error>
}

struct ServerInfo {
    let host: String
    let port: Int
}

final class RouteGuideService: RouteGuideType {
    private var group: EventLoopGroup?
    private var client: Routeguide_RouteGuideClientProtocol?
    
    func connect(_ creator: @escaping (EventLoopGroup) -> Routeguide_RouteGuideClientProtocol) {
        self.group  = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.client = creator(self.group!)
    }
    
    func disconnect() {
        DispatchQueue.global().async {
            if let client = self.client as? Routeguide_RouteGuideClient, let group = self.group {
                do {
                    try client.channel.close().wait()
                    try group.syncShutdownGracefully()
                } catch {
                    print(error)
                }
            }
        }
    }

    func fetchFeature(latitude: Int, longitude: Int) -> AnyPublisher<Routeguide_Feature, Error> {
        Deferred {
            Future<Routeguide_Feature, Error> { promise in
                let point = Routeguide_Point.with {
                    $0.latitude     = numericCast(latitude)
                    $0.longitude    = numericCast(longitude)
                }
                guard let client = self.client else {
                    fatalError()
                }
                do {
                    let feature = try client.getFeature(point, callOptions: nil)
                        .response
                        .wait()
                    promise(.success(feature))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

func makeClient(host: String = "localhost",port: Int,group:  EventLoopGroup) -> Routeguide_RouteGuideClientProtocol {
    return Routeguide_RouteGuideClient(
        channel: ClientConnection.insecure(group: group)
            .connect(host: host, port: port)
    )
}
