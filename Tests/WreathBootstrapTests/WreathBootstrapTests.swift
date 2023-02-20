import XCTest
@testable import Bootstrap
@testable import BootstrapClient
@testable import BootstrapServer
import Arcadia
import Gardener
import Transmission

final class WreathBootstrapTests: XCTestCase {
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
    
    func testBootstrapClientTenMinutes() throws {
        let configURL = File.homeDirectory().appendingPathComponent("Bootstrap-client.json")
        let client = try BootstrapClient(configURL: configURL)
        let serverInfo = WreathServerInfo(serverID: "thisisnotarealid", serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo)
        
        var index = 0
        
        while index <= 10 {
            let secondsToDelay = 5.0
            DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
               print("This message is delayed")
               index += 1
            }
            
            try client.sendHeartbeat(serverID: "thisisnotarealid")
            print("heartbeat called")
        }
    }
    
    func testBootstrapTwoServersSingleHeartbeat() throws {
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
        
        Task {
            guard let listener = TransmissionListener(port: 5678, logger: nil) else
            {
                XCTFail()
                return
            }
            
            let bootstrap = Bootstrap()
            let server = BootstrapServer(listener: listener, handler: bootstrap)
            server.acceptLoop()
            server.shutdown()
        }
        
        let configURL = File.homeDirectory().appendingPathComponent("Bootstrap-client.json")
        let client = try BootstrapClient(configURL: configURL)
        let serverInfo = WreathServerInfo(serverID: "thisisnotarealid", serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo)
        try client.sendHeartbeat(serverID: "thisisnotarealid")
        
        let configURL2 = File.homeDirectory().appendingPathComponent("Bootstrap-client2.json")
        let client2 = try BootstrapClient(configURL: configURL)
        let serverInfo2 = WreathServerInfo(serverID: "thisisnotarealid", serverAddress: "127.0.0.1:5678")
        try client2.registerNewAddress(newServer: serverInfo)
    
    }
}
