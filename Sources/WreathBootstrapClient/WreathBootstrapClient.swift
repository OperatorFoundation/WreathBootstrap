//
//  BootstrapClient.swift
//
//
//  Created by Clockwork on Feb 6, 2023.
//

import Foundation

import Arcadia
import TransmissionTypes
import WreathBootstrap

public class WreathBootstrapClient
{
    let connection: TransmissionTypes.Connection

    public init(connection: TransmissionTypes.Connection)
    {
        self.connection = connection
    }

    public func getAddresses(serverID: String) throws -> [WreathServerInfo]
    {
        let message = WreathBootstrapRequest.getAddresses(Getaddresses(serverID: serverID))
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        guard self.connection.writeWithLengthPrefix(data: data, prefixSizeInBits: 64) else
        {
            throw WreathBootstrapClientError.writeFailed
        }

        guard let responseData = self.connection.readWithLengthPrefix(prefixSizeInBits: 64) else
        {
            throw WreathBootstrapClientError.readFailed
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(WreathBootstrapResponse.self, from: responseData)
        switch response
        {
            case .getAddresses(let value):
                return value
            default:
                throw WreathBootstrapClientError.badReturnType
        }
    }

    public func registerNewAddress(newServer: WreathServerInfo) throws
    {
        let message = WreathBootstrapRequest.registerNewAddress(Registernewaddress(newServer: newServer))
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        guard self.connection.writeWithLengthPrefix(data: data, prefixSizeInBits: 64) else
        {
            throw WreathBootstrapClientError.writeFailed
        }

        guard let responseData = self.connection.readWithLengthPrefix(prefixSizeInBits: 64) else
        {
            throw WreathBootstrapClientError.readFailed
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(WreathBootstrapResponse.self, from: responseData)
        switch response
        {
            case .registerNewAddress:
                return
            default:
                throw WreathBootstrapClientError.badReturnType
        }
    }

    public func sendHeartbeat(serverID: String) throws
    {
        let message = WreathBootstrapRequest.sendHeartbeat(Sendheartbeat(serverID: serverID))
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        guard self.connection.writeWithLengthPrefix(data: data, prefixSizeInBits: 64) else
        {
            throw WreathBootstrapClientError.writeFailed
        }

        guard let responseData = self.connection.readWithLengthPrefix(prefixSizeInBits: 64) else
        {
            throw WreathBootstrapClientError.readFailed
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(WreathBootstrapResponse.self, from: responseData)
        switch response
        {
            case .sendHeartbeat:
                return
            default:
                throw WreathBootstrapClientError.badReturnType
        }
    }
}

public enum WreathBootstrapClientError: Error
{
    case connectionRefused(String, Int)
    case writeFailed
    case readFailed
    case badReturnType
}
