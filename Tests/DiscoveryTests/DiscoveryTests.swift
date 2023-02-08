import XCTest
@testable import DiscoveryBootstrap
@testable import DiscoveryClient
import Arcadia
import Gardener

final class DiscoveryBootstrapTests: XCTestCase {
    func testDiscoveryClient() throws {
        let configURL = File.homeDirectory().appendingPathComponent("discovery-client.json")
        let client = try DiscoveryBootstrapClient(configURL: configURL)
        let serverInfo = DiscoveryServerInfo(serverID: "thisisnotarealid", serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo)
        try client.sendHeartbeat(serverID: "thisisnotarealid")
    }
}
