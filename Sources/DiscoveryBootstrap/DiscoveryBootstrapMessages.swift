//
//  DiscoveryBootstrapMessages.swift
//
//
//  Created by Clockwork on Feb 6, 2023.
//
import Arcadia

public enum DiscoveryBootstrapRequest: Codable
{
    case getAddresses(Getaddresses)
    case registerNewAddress(Registernewaddress)
    case sendHeartbeat(Sendheartbeat)
}

public struct Getaddresses: Codable
{
    public let serverID: String

    public init(serverID: String)
    {
        self.serverID = serverID
    }
}

public struct Registernewaddress: Codable
{
    public let newServer: DiscoveryServerInfo

    public init(newServer: DiscoveryServerInfo)
    {
        self.newServer = newServer
    }
}

public struct Sendheartbeat: Codable
{
    public let serverID: String

    public init(serverID: String)
    {
        self.serverID = serverID
    }
}

public enum DiscoveryBootstrapResponse: Codable
{
    case getAddresses([DiscoveryServerInfo])
    case registerNewAddress
    case sendHeartbeat
}
