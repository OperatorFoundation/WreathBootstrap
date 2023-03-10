//
//  WreathBootstrapClient.swift
//
//
//  Created by Clockwork on Mar 8, 2023.
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

    public func getAddresses(serverID: ArcadiaID) throws -> [WreathServerInfo]
    {
        let message = WreathBootstrapRequest.GetaddressesRequest(Getaddresses(serverID: serverID))
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        print("-> BootstrapClient is sending a request \(data.count) bytes: \(data.string)")
        guard self.connection.writeWithLengthPrefix(data: data, prefixSizeInBits: 64) else
        {
            throw WreathBootstrapClientError.writeFailed
        }

        guard let responseData = self.connection.readWithLengthPrefix(prefixSizeInBits: 64) else
        {
            throw WreathBootstrapClientError.readFailed
        }
        
        print("-> BootstrapClient received a response \(responseData.count) bytes: \(responseData.string)")

        let decoder = JSONDecoder()
        let response = try decoder.decode(WreathBootstrapResponse.self, from: responseData)
        switch response
        {
            case .GetaddressesResponse(let value):
                return value
            default:
                throw WreathBootstrapClientError.badReturnType
        }
    }

    public func registerNewAddress(newServer: WreathServerInfo) throws
    {
        let message = WreathBootstrapRequest.RegisternewaddressRequest(Registernewaddress(newServer: newServer))
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        print("-> BootstrapClient is sending a request \(data.count) bytes: \(data.string)")
        guard self.connection.writeWithLengthPrefix(data: data, prefixSizeInBits: 64) else
        {
            throw WreathBootstrapClientError.writeFailed
        }

        guard let responseData = self.connection.readWithLengthPrefix(prefixSizeInBits: 64) else
        {
            throw WreathBootstrapClientError.readFailed
        }
        
        print("-> BootstrapClient received a response \(responseData.count) bytes: \(responseData.string)")

        let decoder = JSONDecoder()
        let response = try decoder.decode(WreathBootstrapResponse.self, from: responseData)
        switch response
        {
            case .RegisternewaddressResponse:
                return
            default:
                throw WreathBootstrapClientError.badReturnType
        }
    }

    public func sendHeartbeat(serverID: ArcadiaID) throws
    {
        let message = WreathBootstrapRequest.SendheartbeatRequest(Sendheartbeat(serverID: serverID))
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        print("-> BootstrapClient is sending a request \(data.count) bytes: \(data.string)")
        guard self.connection.writeWithLengthPrefix(data: data, prefixSizeInBits: 64) else
        {
            throw WreathBootstrapClientError.writeFailed
        }

        guard let responseData = self.connection.readWithLengthPrefix(prefixSizeInBits: 64) else
        {
            throw WreathBootstrapClientError.readFailed
        }
        
        print("-> BootstrapClient received a response \(responseData.count) bytes: \(responseData.string)")

        let decoder = JSONDecoder()
        let response = try decoder.decode(WreathBootstrapResponse.self, from: responseData)
        switch response
        {
            case .SendheartbeatResponse:
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
