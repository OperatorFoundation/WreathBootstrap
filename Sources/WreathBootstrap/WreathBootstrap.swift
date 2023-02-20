import Foundation
import Arcadia

public class WreathBootstrap
{
    public let arcadia = Arcadia()
    // an array of valid Bootstrap servers
    public var availableServers: [String: WreathServerInfo] = [:]
    
    public init() {}
    
    /// Sends a request for a list of WreathServers
    public func getAddresses(serverID: String) -> [WreathServerInfo] {
        return arcadia.findPeers(wreathServers: [WreathServerInfo](availableServers.values), serverID: serverID)
    }
    
    /// Adds a new WreathServer to the verified server list
    public func registerNewAddress(newServer: WreathServerInfo) throws {
        if self.availableServers[newServer.serverID] != nil {
            throw WreathBootstrapError.serverIDAlreadyExists
        } else {
            self.availableServers[newServer.serverID] = newServer
        }
    }
    
    /// A heartbeat function that updates the last date that a check in took place (keep alive)
    public func sendHeartbeat(serverID: String) throws {
        if let server = self.availableServers[serverID] {
            server.lastHeartbeat = Date()
        } else {
            throw WreathBootstrapError.invalidServerID
        }
    }
}

public enum WreathBootstrapError: Error {
    case serverIDAlreadyExists
    case invalidServerID
}
