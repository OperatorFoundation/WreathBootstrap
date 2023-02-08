//
//  DiscoveryBootstrapServer.swift
//
//
//  Created by Clockwork on Feb 6, 2023.
//

import Foundation

import TransmissionTypes
import DiscoveryBootstrap

public class DiscoveryBootstrapServer
{
    let listener: TransmissionTypes.Listener
    let handler: DiscoveryBootstrap

    var running: Bool = true

    public init(listener: TransmissionTypes.Listener, handler: DiscoveryBootstrap)
    {
        self.listener = listener
        self.handler = handler

        Task
        {
            self.acceptLoop()
        }
    }

    public func shutdown()
    {
        self.running = false
    }

    func acceptLoop()
    {
        while self.running
        {
            do
            {
                let connection = try self.listener.accept()

                Task
                {
                    self.handleConnection(connection)
                }
            }
            catch
            {
                print(error)
                self.running = false
                return
            }
        }
    }

    func handleConnection(_ connection: TransmissionTypes.Connection)
    {
        while self.running
        {
            do
            {
                guard let requestData = connection.readWithLengthPrefix(prefixSizeInBits: 64) else
                {
                    throw DiscoveryBootstrapServerError.readFailed
                }

                let decoder = JSONDecoder()
                let request = try decoder.decode(DiscoveryBootstrapRequest.self, from: requestData)
                switch request
                {
                    case .getAddresses(let value):
                        let result = self.handler.getAddresses(serverID: value.serverID)
                        let response = DiscoveryBootstrapResponse.getAddresses(result)
                        let encoder = JSONEncoder()
                        let responseData = try encoder.encode(response)
                        guard connection.writeWithLengthPrefix(data: responseData, prefixSizeInBits: 64) else
                        {
                            throw DiscoveryBootstrapServerError.writeFailed
                        }
                    case .registerNewAddress(let value):
                        try self.handler.registerNewAddress(newServer: value.newServer)
                        let response = DiscoveryBootstrapResponse.registerNewAddress
                        let encoder = JSONEncoder()
                        let responseData = try encoder.encode(response)
                        guard connection.writeWithLengthPrefix(data: responseData, prefixSizeInBits: 64) else
                        {
                            throw DiscoveryBootstrapServerError.writeFailed
                        }
                    case .sendHeartbeat(let value):
                        try self.handler.sendHeartbeat(serverID: value.serverID)
                        let response = DiscoveryBootstrapResponse.sendHeartbeat
                        let encoder = JSONEncoder()
                        let responseData = try encoder.encode(response)
                        guard connection.writeWithLengthPrefix(data: responseData, prefixSizeInBits: 64) else
                        {
                            throw DiscoveryBootstrapServerError.writeFailed
                        }
                }
            }
            catch
            {
                print(error)
                return
            }
        }
    }
}

public enum DiscoveryBootstrapServerError: Error
{
    case connectionRefused(String, Int)
    case writeFailed
    case readFailed
    case badReturnType
}
