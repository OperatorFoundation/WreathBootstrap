import Foundation
import Arcadia

public class DiscoveryBootstrap
{
    public let arcadia = Arcadia()
    // the array of valid discovery servers
    public var availableServers: [String: DiscoveryServerInfo] = [:]
    
    public init() {}
    
    // sends a request for a list of servers
    public func getAddresses(serverID: String) -> [DiscoveryServerInfo] {
        return arcadia.findPeers(discoveryServers: [DiscoveryServerInfo](availableServers.values), serverID: serverID)
    }
    
    // adds a new server to the verified server list
    public func registerNewAddress(newServer: DiscoveryServerInfo) throws {
        if self.availableServers[newServer.serverID] != nil {
            throw DiscoveryBootstrapError.serverIDAlreadyExists
        } else {
            self.availableServers[newServer.serverID] = newServer
        }
    }
    
    // the discovery server should have a heartbeat function
    // and a property that has the last date that a check took place
    // checkHeartbeat should update this property
    public func sendHeartbeat(serverID: String) throws {
        if let server = self.availableServers[serverID] {
            server.lastHeartbeat = Date()
        } else {
            throw DiscoveryBootstrapError.invalidServerID
        }
    }
}

public enum DiscoveryBootstrapError: Error {
    case serverIDAlreadyExists
    case invalidServerID
}
