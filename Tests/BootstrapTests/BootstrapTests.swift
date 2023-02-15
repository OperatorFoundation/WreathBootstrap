import XCTest
@testable import Bootstrap
@testable import BootstrapClient
@testable import BootstrapServer
import Arcadia
import Gardener
import Transmission

final class BootstrapTests: XCTestCase {
    func testServerAndClient() throws {
        Task {
            guard let listener = TransmissionListener(port: 1234, logger: nil) else
            {
                XCTFail()
                return
            }
            
            let bootstrap = Bootstrap()
            let server = BootstrapServer(listener: listener, handler: bootstrap)
            server.acceptLoop()
        }
        
        let configURL = File.homeDirectory().appendingPathComponent("Bootstrap-client.json")
        let client = try BootstrapClient(configURL: configURL)
        let serverInfo = WreathServerInfo(serverID: "thisisnotarealid", serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo)
        try client.sendHeartbeat(serverID: "thisisnotarealid")
    }
    
    func testBootstrapClient() throws {
        let configURL = File.homeDirectory().appendingPathComponent("Bootstrap-client.json")
        let client = try BootstrapClient(configURL: configURL)
        let serverInfo = WreathServerInfo(serverID: "thisisnotarealid", serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo)
        try client.sendHeartbeat(serverID: "thisisnotarealid")
    }
}
