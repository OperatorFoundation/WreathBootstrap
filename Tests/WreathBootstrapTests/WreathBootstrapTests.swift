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
        let serverInfo = WreathServerInfo(publicKey: config.serverPublicKey, serverAddress: "\(config.host):\(config.port)")
        try client.registerNewAddress(newServer: serverInfo)
        try client.sendHeartbeat(serverID: config.serverPublicKey.arcadiaID!)
    }
    
    func startClient() throws -> (client: WreathBootstrapClient, clientConfig: ClientConfig)
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
        
        return (client, config)
    }
    

    func testBootstrapClientRegisterNewAddress() throws
    {
        let (client, config) = try startClient()
        let serverInfo = WreathServerInfo(publicKey: config.serverPublicKey, serverAddress:  "\(config.host):\(config.port)")
        try client.registerNewAddress(newServer: serverInfo)
    }
    
    func testBootstrapClientSendHeartbeat() throws
    {
        let (client, config) = try startClient()
        try client.sendHeartbeat(serverID: config.serverPublicKey.arcadiaID!)
    }
    
    /// Note: This will return an empty array if you have not registered more than one server with this instance of the Bootstrap server
    func testBootstrapClientGetAddresses() throws
    {
        let (client, config) = try startClient()
        let wreathServers = try client.getAddresses(serverID: config.serverPublicKey.arcadiaID!)
        print("Received a GetAddresses response from the server: \(wreathServers)")
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
        let serverInfo = WreathServerInfo(publicKey: config.serverPublicKey, serverAddress: "\(config.host):\(config.port)")
        try client.registerNewAddress(newServer: serverInfo)
        let index = 0
        let lock = DispatchSemaphore(value: 0)
        try scheduleHeartbeat(index: index, lock: lock, client: client, arcadiaID: config.serverPublicKey.arcadiaID!)
        lock.wait()
    }
    
    func scheduleHeartbeat(index: Int, lock: DispatchSemaphore, client: WreathBootstrapClient, arcadiaID: ArcadiaID) throws {
        let secondsToDelay = 60.0
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
            try? client.sendHeartbeat(serverID: arcadiaID)
            print("Heartbeat called")
            if index < 10 {
                try? self.scheduleHeartbeat(index: index + 1, lock: lock, client: client, arcadiaID: arcadiaID)
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
        guard let config = ClientConfig(url: configURL) else
        {
            throw AntiphonyError.invalidConfigFile
        }
        
        guard let connection = TransmissionConnection(host: config.host, port: config.port) else
        {
            throw AntiphonyError.failedToCreateConnection
        }
        
        let client = WreathBootstrapClient(connection: connection)
        let serverInfo = WreathServerInfo(publicKey: config.serverPublicKey, serverAddress: "\(config.host):\(config.port)")
        try client.registerNewAddress(newServer: serverInfo)
        
        let configURL2 = File.homeDirectory().appendingPathComponent("Bootstrap-client2.json")
        guard let config2 = ClientConfig(url: configURL2) else
        {
            throw AntiphonyError.invalidConfigFile
        }
        
        let serverInfo2 = WreathServerInfo(publicKey: config2.serverPublicKey, serverAddress: "\(config2.host):\(config2.port)")
        try client.registerNewAddress(newServer: serverInfo2)
        
        var wreathServers = try client.getAddresses(serverID: config.serverPublicKey.arcadiaID!)
        XCTAssertEqual(wreathServers.count, 2)
        
        Thread.sleep(forTimeInterval: WreathBootstrap.heartbeatInterval)
        try client.sendHeartbeat(serverID: config.serverPublicKey.arcadiaID!)
        Thread.sleep(forTimeInterval: WreathBootstrap.heartbeatTimeout - WreathBootstrap.heartbeatInterval)
        
        wreathServers = try client.getAddresses(serverID: config.serverPublicKey.arcadiaID!)
        XCTAssertEqual(wreathServers.count, 1)
    }
}
