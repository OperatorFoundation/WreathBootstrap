import XCTest
@testable import WreathBootstrap
@testable import WreathBootstrapClient
@testable import WreathBootstrapServer
import Arcadia
import Antiphony
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
        guard let config = ClientConfig(url: configURL) else {
            throw AntiphonyError.invalidConfigFile
        }
        
        guard let connection = TransmissionConnection(host: config.host, port: config.port) else
        {
            throw AntiphonyError.failedToCreateConnection
        }
        
        let client = WreathBootstrapClient(connection: connection)
        let serverInfo = WreathServerInfo(publicKey: config.serverPublicKey, serverAddress: "")
        try client.registerNewAddress(newServer: serverInfo)
        try client.sendHeartbeat(serverID: config.serverPublicKey.arcadiaKey!)
    }
    
    func testBootstrapClient() throws
    {
        let configURL = File.homeDirectory().appendingPathComponent("Bootstrap-client.json")
        
        guard let config = ClientConfig(url: configURL) else
        {
            throw AntiphonyError.invalidConfigFile
        }
        
        
        guard let connection = TransmissionConnection(host: config.host, port: config.port) else
        {
            throw AntiphonyError.failedToCreateConnection
        }
        
        let client = WreathBootstrapClient(connection: connection)
        let serverInfo = WreathServerInfo(publicKey: config.serverPublicKey, serverAddress:  "\(config.host):\(config.port)")
        try client.registerNewAddress(newServer: serverInfo)
        try client.sendHeartbeat(serverID: config.serverPublicKey.arcadiaKey!)
    }
    
    func testBootstrapClientTenMinutes() throws {
        let configURL = File.homeDirectory().appendingPathComponent("Bootstrap-client.json")
        
        guard let config = ClientConfig(url: configURL) else
        {
            throw AntiphonyError.invalidConfigFile
        }
        
        guard let connection = TransmissionConnection(host: config.host, port: config.port) else
        {
            throw AntiphonyError.failedToCreateConnection
        }
        
        let client = WreathBootstrapClient(connection: connection)
        let serverInfo = WreathServerInfo(publicKey: config.serverPublicKey, serverAddress: "")
        try client.registerNewAddress(newServer: serverInfo)
        var index = 0
        let lock = DispatchSemaphore(value: 0)
        try scheduleHeartbeat(index: index, lock: lock, client: client)
        lock.wait()
    }
    
    func scheduleHeartbeat(index: Int, lock: DispatchSemaphore, client: WreathBootstrapClient) throws {
        let secondsToDelay = 60.0
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
            guard let key = try? PublicKey(string: "") else {
                XCTFail()
                return
            }
            
            try? client.sendHeartbeat(serverID: key.arcadiaKey!)
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
        let key = try PublicKey(string: "")
        let serverInfo = WreathServerInfo(publicKey: key, serverAddress: "")
        try client.registerNewAddress(newServer: serverInfo)
        
        let key2 = try PublicKey(string: "")
        let serverInfo2 = WreathServerInfo(publicKey: key2, serverAddress: "")
        try client.registerNewAddress(newServer: serverInfo2)
        
        var wreathServers = try client.getAddresses(serverID: key.arcadiaKey!)
        XCTAssertEqual(wreathServers.count, 2)
        
        Thread.sleep(forTimeInterval: WreathBootstrap.heartbeatInterval)
        try client.sendHeartbeat(serverID: key.arcadiaKey!)
        Thread.sleep(forTimeInterval: WreathBootstrap.heartbeatTimeout - WreathBootstrap.heartbeatInterval)
        
        wreathServers = try client.getAddresses(serverID: key.arcadiaKey!)
        XCTAssertEqual(wreathServers.count, 1)
    }
}
