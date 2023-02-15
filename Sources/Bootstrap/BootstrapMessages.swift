//
//  BootstrapMessages.swift
//
//
//  Created by Clockwork on Feb 6, 2023.
//
import Arcadia

public enum BootstrapRequest: Codable
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
    public let newServer: WreathServerInfo

    public init(newServer: WreathServerInfo)
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

public enum BootstrapResponse: Codable
{
    case getAddresses([WreathServerInfo])
    case registerNewAddress
    case sendHeartbeat
}
