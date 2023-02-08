//
//  DiscoveryBootstrapClient.swift
//
//
//  Created by Clockwork on Feb 6, 2023.
//

import Foundation

import Arcadia
import TransmissionTypes
import DiscoveryBootstrap

public class DiscoveryBootstrapClient
{
    let connection: TransmissionTypes.Connection

    public init(connection: TransmissionTypes.Connection)
    {
        self.connection = connection
    }

    public func getAddresses(serverID: String) throws -> [DiscoveryServerInfo]
    {
        let message = DiscoveryBootstrapRequest.getAddresses(Getaddresses(serverID: serverID))
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        guard self.connection.writeWithLengthPrefix(data: data, prefixSizeInBits: 64) else
        {
            throw DiscoveryBootstrapClientError.writeFailed
        }

        guard let responseData = self.connection.readWithLengthPrefix(prefixSizeInBits: 64) else
        {
            throw DiscoveryBootstrapClientError.readFailed
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(DiscoveryBootstrapResponse.self, from: responseData)
        switch response
        {
            case .getAddresses(let value):
                return value
            default:
                throw DiscoveryBootstrapClientError.badReturnType
        }
    }

    public func registerNewAddress(newServer: DiscoveryServerInfo) throws
    {
        let message = DiscoveryBootstrapRequest.registerNewAddress(Registernewaddress(newServer: newServer))
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        guard self.connection.writeWithLengthPrefix(data: data, prefixSizeInBits: 64) else
        {
            throw DiscoveryBootstrapClientError.writeFailed
        }

        guard let responseData = self.connection.readWithLengthPrefix(prefixSizeInBits: 64) else
        {
            throw DiscoveryBootstrapClientError.readFailed
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(DiscoveryBootstrapResponse.self, from: responseData)
        switch response
        {
            case .registerNewAddress:
                return
            default:
                throw DiscoveryBootstrapClientError.badReturnType
        }
    }

    public func sendHeartbeat(serverID: String) throws
    {
        let message = DiscoveryBootstrapRequest.sendHeartbeat(Sendheartbeat(serverID: serverID))
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        guard self.connection.writeWithLengthPrefix(data: data, prefixSizeInBits: 64) else
        {
            throw DiscoveryBootstrapClientError.writeFailed
        }

        guard let responseData = self.connection.readWithLengthPrefix(prefixSizeInBits: 64) else
        {
            throw DiscoveryBootstrapClientError.readFailed
        }

        let decoder = JSONDecoder()
        let response = try decoder.decode(DiscoveryBootstrapResponse.self, from: responseData)
        switch response
        {
            case .sendHeartbeat:
                return
            default:
                throw DiscoveryBootstrapClientError.badReturnType
        }
    }
}

public enum DiscoveryBootstrapClientError: Error
{
    case connectionRefused(String, Int)
    case writeFailed
    case readFailed
    case badReturnType
}
