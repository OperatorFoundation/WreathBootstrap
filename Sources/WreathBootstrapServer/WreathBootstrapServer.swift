//
//  BootstrapServer.swift
//
//
//  Created by Clockwork on Feb 6, 2023.
//

import Foundation

import TransmissionTypes
import WreathBootstrap

public class WreathBootstrapServer
{
    let listener: TransmissionTypes.Listener
    let handler: WreathBootstrap

    var running: Bool = true

    public init(listener: TransmissionTypes.Listener, handler: WreathBootstrap)
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
                    throw BootstrapServerError.readFailed
                }

                let decoder = JSONDecoder()
                let request = try decoder.decode(WreathBootstrapRequest.self, from: requestData)
                switch request
                {
                    case .getAddresses(let value):
                        let result = self.handler.getAddresses(key: value.key)
                        let response = WreathBootstrapResponse.getAddresses(result)
                        let encoder = JSONEncoder()
                        let responseData = try encoder.encode(response)
                        guard connection.writeWithLengthPrefix(data: responseData, prefixSizeInBits: 64) else
                        {
                            throw BootstrapServerError.writeFailed
                        }
                    case .registerNewAddress(let value):
                        try self.handler.registerNewAddress(newServer: value.newServer)
                        let response = WreathBootstrapResponse.registerNewAddress
                        let encoder = JSONEncoder()
                        let responseData = try encoder.encode(response)
                        guard connection.writeWithLengthPrefix(data: responseData, prefixSizeInBits: 64) else
                        {
                            throw BootstrapServerError.writeFailed
                        }
                    case .sendHeartbeat(let value):
                        try self.handler.sendHeartbeat(key: value.key)
                        let response = WreathBootstrapResponse.sendHeartbeat
                        let encoder = JSONEncoder()
                        let responseData = try encoder.encode(response)
                        guard connection.writeWithLengthPrefix(data: responseData, prefixSizeInBits: 64) else
                        {
                            throw BootstrapServerError.writeFailed
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

public enum BootstrapServerError: Error
{
    case connectionRefused(String, Int)
    case writeFailed
    case readFailed
    case badReturnType
}
