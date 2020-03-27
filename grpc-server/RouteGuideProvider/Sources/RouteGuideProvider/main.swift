import Foundation
import GRPC
import RouteGuide
import NIO
import Logging
import SwiftProtobuf

// Quieten the logs.
LoggingSystem.bootstrap {
  var handler = StreamLogHandler.standardOutput(label: $0)
  handler.logLevel = .critical
  return handler
}

/// Loads the features from `route_guide_db.json`, assumed to be in the directory above this file.
func loadFeatures() throws -> [Routeguide_Feature] {
  let url = URL(fileURLWithPath: #file)
    .deletingLastPathComponent()  // main.swift
    .deletingLastPathComponent()  // Server/
    .appendingPathComponent("route_guide_db.json")

  let data = try Data(contentsOf: url)
  return try Routeguide_Feature.array(fromJSONUTF8Data: data)
}

func main(args: [String]) throws {
  // Create an event loop group for the server to run on.
  let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
  defer {
    try! group.syncShutdownGracefully()
  }

  // Read the feature database.
  let features = try loadFeatures()

  // Create a provider using the features we read.
  let provider = RouteGuideProvider(features: features)

  // Start the server and print its address once it has started.
  let server = Server.insecure(group: group)
    .withServiceProviders([provider])
    .bind(host: "localhost", port: 58198)

  server.map {
    $0.channel.localAddress
  }.whenSuccess { address in
    print("server started on port \(address!.port!)")
  }

  // Wait on the server's `onClose` future to stop the program from exiting.
  _ = try server.flatMap {
    $0.onClose
  }.wait()
}

try main(args: CommandLine.arguments)

