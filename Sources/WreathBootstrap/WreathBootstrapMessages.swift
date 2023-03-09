//
//  WreathBootstrapMessages.swift
//
//
//  Created by Clockwork on Mar 8, 2023.
//

import Arcadia

public enum WreathBootstrapRequest: Codable
{
    case GetaddressesRequest(Getaddresses)
    case RegisternewaddressRequest(Registernewaddress)
    case SendheartbeatRequest(Sendheartbeat)
}

public struct Getaddresses: Codable
{
    public let serverID: ArcadiaID

    public init(serverID: ArcadiaID)
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
    public let serverID: ArcadiaID

    public init(serverID: ArcadiaID)
    {
        self.serverID = serverID
    }
}

public enum WreathBootstrapResponse: Codable
{
    case GetaddressesResponse([WreathServerInfo])
    case RegisternewaddressResponse
    case SendheartbeatResponse
}
