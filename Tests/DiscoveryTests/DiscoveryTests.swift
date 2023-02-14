import XCTest
@testable import DiscoveryBootstrap
@testable import DiscoveryClient
@testable import DiscoveryServer
import Arcadia
import Gardener
import Transmission

final class DiscoveryBootstrapTests: XCTestCase {
    func testServerAndClient() throws {
        Task {
            guard let listener = TransmissionListener(port: 1234, logger: nil) else
            {
                XCTFail()
                return
            }
            
            let bootstrap = DiscoveryBootstrap()
            let server = DiscoveryBootstrapServer(listener: listener, handler: bootstrap)
            server.acceptLoop()
        }
        
        let configURL = File.homeDirectory().appendingPathComponent("discovery-client.json")
        let client = try DiscoveryBootstrapClient(configURL: configURL)
        let serverInfo = DiscoveryServerInfo(serverID: "thisisnotarealid", serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo)
        try client.sendHeartbeat(serverID: "thisisnotarealid")
    }
    
    func testDiscoveryClient() throws {
        let configURL = File.homeDirectory().appendingPathComponent("discovery-client.json")
        let client = try DiscoveryBootstrapClient(configURL: configURL)
        let serverInfo = DiscoveryServerInfo(serverID: "thisisnotarealid", serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo)
        try client.sendHeartbeat(serverID: "thisisnotarealid")
    }
}
