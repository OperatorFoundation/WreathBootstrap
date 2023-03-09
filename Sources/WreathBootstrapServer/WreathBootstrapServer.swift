//
//  WreathBootstrapServer.swift
//
//
//  Created by Clockwork on Mar 8, 2023.
//

import Foundation

import Arcadia
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
                    throw WreathBootstrapServerError.readFailed
                }

                let decoder = JSONDecoder()
                let request = try decoder.decode(WreathBootstrapRequest.self, from: requestData)
                print("-> BootstrapServer received a request: \(request)")
                switch request
                {
                    case .GetaddressesRequest(let value):
                        let result = self.handler.getAddresses(serverID: value.serverID)
                        let response = WreathBootstrapResponse.GetaddressesResponse(result)
                        let encoder = JSONEncoder()
                        let responseData = try encoder.encode(response)
                        
                        print("-> BootstrapServer is sending a reponse: \(responseData.string)")
                        guard connection.writeWithLengthPrefix(data: responseData, prefixSizeInBits: 64) else
                        {
                            throw WreathBootstrapServerError.writeFailed
                        }
                    case .RegisternewaddressRequest(let value):
                        self.handler.registerNewAddress(newServer: value.newServer)
                        let response = WreathBootstrapResponse.RegisternewaddressResponse
                        let encoder = JSONEncoder()
                        let responseData = try encoder.encode(response)
                        print("-> BootstrapServer is sending a reponse: \(responseData.string)")
                        guard connection.writeWithLengthPrefix(data: responseData, prefixSizeInBits: 64) else
                        {
                            throw WreathBootstrapServerError.writeFailed
                        }
                    case .SendheartbeatRequest(let value):
                        self.handler.sendHeartbeat(serverID: value.serverID)
                        let response = WreathBootstrapResponse.SendheartbeatResponse
                        let encoder = JSONEncoder()
                        let responseData = try encoder.encode(response)
                        print("-> BootstrapServer is sending a reponse: \(responseData.string)")
                        guard connection.writeWithLengthPrefix(data: responseData, prefixSizeInBits: 64) else
                        {
                            throw WreathBootstrapServerError.writeFailed
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

public enum WreathBootstrapServerError: Error
{
    case connectionRefused(String, Int)
    case writeFailed
    case readFailed
    case badReturnType
}
