import Foundation
import Arcadia
import KeychainTypes

public class WreathBootstrap
{
    static public let heartbeatInterval = 60.0 // seconds, one minute
    static public let heartbeatTimeout = 60.0 * 2 // seconds, two minutes
    
    public let arcadia = Arcadia()
    // an array of valid Bootstrap servers
    public var availableServers: [Key: WreathServerInfo] = [:]
    
    public init() {}
    
    /// Sends a request for a list of WreathServers
    public func getAddresses(key: Key) -> [WreathServerInfo] {
        removeOldServers()
        return arcadia.findPeers(for: key)
    }
    
    /// Adds a new WreathServer to the verified server list
    public func registerNewAddress(newServer: WreathServerInfo) throws {
        guard let key = newServer.publicKey.arcadiaKey else {
            throw WreathBootstrapError.failedToGetKey
        }
        if self.availableServers[key] != nil {
            throw WreathBootstrapError.serverIDAlreadyExists
        } else {
            self.availableServers[key] = newServer
        }
    }
    
    /// A heartbeat function that updates the last date that a check in took place (keep alive)
    public func sendHeartbeat(key: Key) throws {
        if let server = self.availableServers[key] {
            server.lastHeartbeat = Date()
        } else {
            throw WreathBootstrapError.invalidServerID
        }
    }
    
    func removeOldServers() {
        self.availableServers = self.availableServers.filter
        {
            (key, value) in
            
            let now = Date()
            let timeInterval = now.timeIntervalSince(value.lastHeartbeat)
            return timeInterval < Self.heartbeatTimeout
        }
    }
}

public enum WreathBootstrapError: Error {
    case failedToGetKey
    case serverIDAlreadyExists
    case invalidServerID
}
