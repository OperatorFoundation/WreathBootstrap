import XCTest
@testable import WreathBootstrap
@testable import WreathBootstrapClient
@testable import WreathBootstrapServer
import Arcadia
import Gardener
import KeychainTypes
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
        let key = try PublicKey(string: "thisisnotarealid")
        let serverInfo = WreathServerInfo(publicKey: key, serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo)
        try client.sendHeartbeat(key: key.arcadiaKey!)
    }
    
    func testBootstrapClient() throws {
        let configURL = File.homeDirectory().appendingPathComponent("Bootstrap-client.json")
        let client = try WreathBootstrapClient(configURL: configURL)
        let key = try PublicKey(string: "thisisnotarealid")
        let serverInfo = WreathServerInfo(publicKey: key, serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo)
        try client.sendHeartbeat(key: key.arcadiaKey!)
    }
    
    func testBootstrapClientTenMinutes() throws {
        let configURL = File.homeDirectory().appendingPathComponent("Bootstrap-client.json")
        let client = try WreathBootstrapClient(configURL: configURL)
        let key = try PublicKey(string: "thisisnotarealid")
        let serverInfo = WreathServerInfo(publicKey: key, serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo)
        var index = 0
        let lock = DispatchSemaphore(value: 0)
        try scheduleHeartbeat(index: index, lock: lock, client: client)
        lock.wait()
    }
    
    func scheduleHeartbeat(index: Int, lock: DispatchSemaphore, client: WreathBootstrapClient) throws {
        let secondsToDelay = 60.0
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
            guard let key = try? PublicKey(string: "thisisnotarealid") else {
                XCTFail()
                return
            }
            
            try? client.sendHeartbeat(key: key.arcadiaKey!)
            print("Heartbeat called")
            if index < 10 {
                try? self.scheduleHeartbeat(index: index + 1, lock: lock, client: client)
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
        let key = try PublicKey(string: "thisisnotarealid")
        let serverInfo = WreathServerInfo(publicKey: key, serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo)
        
        let key2 = try PublicKey(string: "thisisnotarealideither")
        let serverInfo2 = WreathServerInfo(publicKey: key2, serverAddress: "127.0.0.1:1234")
        try client.registerNewAddress(newServer: serverInfo2)
        
        var wreathServers = try client.getAddresses(key: key.arcadiaKey!)
        XCTAssertEqual(wreathServers.count, 2)
        
        Thread.sleep(forTimeInterval: WreathBootstrap.heartbeatInterval)
        try client.sendHeartbeat(key: key.arcadiaKey!)
        Thread.sleep(forTimeInterval: WreathBootstrap.heartbeatTimeout - WreathBootstrap.heartbeatInterval)
        
        wreathServers = try client.getAddresses(key: key.arcadiaKey!)
        XCTAssertEqual(wreathServers.count, 1)
    }
}
