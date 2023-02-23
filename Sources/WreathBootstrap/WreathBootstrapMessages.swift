//
//  BootstrapMessages.swift
//
//
//  Created by Clockwork on Feb 6, 2023.
//
import Arcadia

public enum WreathBootstrapRequest: Codable
{
    case getAddresses(Getaddresses)
    case registerNewAddress(Registernewaddress)
    case sendHeartbeat(Sendheartbeat)
}

public struct Getaddresses: Codable
{
    public let key: Key

    public init(key: Key)
    {
        self.key = key
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
    public let key: Key

    public init(key: Key)
    {
        self.key = key
    }
}

public enum WreathBootstrapResponse: Codable
{
    case getAddresses([WreathServerInfo])
    case registerNewAddress
    case sendHeartbeat
}
