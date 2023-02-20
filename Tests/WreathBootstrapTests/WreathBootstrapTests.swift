import XCTest
@testable import WreathBootstrap
@testable import WreathBootstrapClient
@testable import WreathBootstrapServer
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
            
            let bootstrap = WreathBootstrap()
            let server = WreathBootstrapServer(listener: listener, handler: bootstrap)
            server.acceptLoop()
        }
        
        let configURL = File.homeDirectory().appendingPathComponent("Bootstrap-client.json")
        let client = try WreathBootstrapClient(configURL: configURL)
        let serverInfo = WreathServerInfo(serverID: "thisisnotarealid", serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo)
        try client.sendHeartbeat(serverID: "thisisnotarealid")
    }
    
    func testBootstrapClient() throws {
        let configURL = File.homeDirectory().appendingPathComponent("Bootstrap-client.json")
        let client = try WreathBootstrapClient(configURL: configURL)
        let serverInfo = WreathServerInfo(serverID: "thisisnotarealid", serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo)
        try client.sendHeartbeat(serverID: "thisisnotarealid")
    }
    
    func testBootstrapClientTenMinutes() throws {
        let configURL = File.homeDirectory().appendingPathComponent("Bootstrap-client.json")
        let client = try WreathBootstrapClient(configURL: configURL)
        let serverInfo = WreathServerInfo(serverID: "thisisnotarealid", serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo)
        var index = 0
        let lock = DispatchSemaphore(value: 0)
        scheduleHeartbeat(index: index, lock: lock, client: client)
        lock.wait()
    }
    
    func scheduleHeartbeat(index: Int, lock: DispatchSemaphore, client: WreathBootstrapClient) {
        let secondsToDelay = 60.0
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
            try? client.sendHeartbeat(serverID: "thisisnotarealid")
            print("Heartbeat called")
            if index < 10 {
                self.scheduleHeartbeat(index: index + 1, lock: lock, client: client)
            } else {
                lock.signal()
            }
        }
    }
    
    func testBootstrapTwoServersSingleHeartbeat() throws {
        guard let listener = TransmissionListener(port: 1234, logger: nil) else
        {
            XCTFail()
            return
        }
        
        let bootstrap = WreathBootstrap()
        let server = WreathBootstrapServer(listener: listener, handler: bootstrap)
        Task {
            server.acceptLoop()
        }
        
        let configURL = File.homeDirectory().appendingPathComponent("Bootstrap-client.json")
        let client = try WreathBootstrapClient(configURL: configURL)
        let serverInfo = WreathServerInfo(serverID: "thisisnotarealid", serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo)
        
        let serverInfo2 = WreathServerInfo(serverID: "thisisnotarealideither", serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo2)
        
        var wreathServers = try client.getAddresses(serverID: "thisisnotarealid")
        XCTAssertEqual(wreathServers.count, 2)
        
        Thread.sleep(forTimeInterval: WreathBootstrap.heartbeatInterval)
        try client.sendHeartbeat(serverID: "thisisnotarealid")
        Thread.sleep(forTimeInterval: WreathBootstrap.heartbeatTimeout - WreathBootstrap.heartbeatInterval)
        
        wreathServers = try client.getAddresses(serverID: "thisisnotarealid")
        XCTAssertEqual(wreathServers.count, 1)
    }
}
