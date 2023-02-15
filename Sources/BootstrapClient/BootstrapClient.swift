//
//  BootstrapClient.swift
//
//
//  Created by Clockwork on Feb 6, 2023.
//

import Foundation

import Arcadia
import TransmissionTypes
import Bootstrap

public class BootstrapClient
{
    let connection: TransmissionTypes.Connection

    public init(connection: TransmissionTypes.Connection)
    {
        self.connection = connection
    }

    public func getAddresses(serverID: String) throws -> [WreathServerInfo]
    {
        let message = BootstrapRequest.getAddresses(Getaddresses(serverID: serverID))
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        guard self.connection.writeWithLengthPrefix(data: data, prefixSizeInBits: 64) else
        {
            throw BootstrapClientError.writeFailed
        }

        guard let responseData = self.connection.readWithLengthPrefix(prefixSizeInBits: 64) else
        {
            throw BootstrapClientError.readFailed
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(BootstrapResponse.self, from: responseData)
        switch response
        {
            case .getAddresses(let value):
                return value
            default:
                throw BootstrapClientError.badReturnType
        }
    }

    public func registerNewAddress(newServer: WreathServerInfo) throws
    {
        let message = BootstrapRequest.registerNewAddress(Registernewaddress(newServer: newServer))
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        guard self.connection.writeWithLengthPrefix(data: data, prefixSizeInBits: 64) else
        {
            throw BootstrapClientError.writeFailed
        }

        guard let responseData = self.connection.readWithLengthPrefix(prefixSizeInBits: 64) else
        {
            throw BootstrapClientError.readFailed
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(BootstrapResponse.self, from: responseData)
        switch response
        {
            case .registerNewAddress:
                return
            default:
                throw BootstrapClientError.badReturnType
        }
    }

    public func sendHeartbeat(serverID: String) throws
    {
        let message = BootstrapRequest.sendHeartbeat(Sendheartbeat(serverID: serverID))
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        guard self.connection.writeWithLengthPrefix(data: data, prefixSizeInBits: 64) else
        {
            throw BootstrapClientError.writeFailed
        }

        guard let responseData = self.connection.readWithLengthPrefix(prefixSizeInBits: 64) else
        {
            throw BootstrapClientError.readFailed
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(BootstrapResponse.self, from: responseData)
        switch response
        {
            case .sendHeartbeat:
                return
            default:
                throw BootstrapClientError.badReturnType
        }
    }
}

public enum BootstrapClientError: Error
{
    case connectionRefused(String, Int)
    case writeFailed
    case readFailed
    case badReturnType
}
