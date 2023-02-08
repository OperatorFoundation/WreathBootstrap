//
//  main.swift
//  Discovery
//
//  Created by Joshua on 02/06/2023
//

import ArgumentParser
import Foundation

#if os(macOS) || os(iOS)
import os.log
#else
import FoundationNetworking
import Logging
#endif

import Antiphony
import DiscoveryBootstrap
import Gardener
import Net
import Spacetime


struct DiscoveryCommandLine: ParsableCommand
{
    static let configuration = CommandConfiguration(
        commandName: "discovery",
        subcommands: [New.self, Run.self]
    )
    
    static let clientConfigURL =  File.homeDirectory().appendingPathComponent("discovery-client.json")
    static let serverConfigURL = URL(fileURLWithPath: File.homeDirectory().path).appendingPathComponent("discovery-server.json")
    static let loggerLabel = "org.OperatorFoundation.DiscoveryLogger"
}

extension DiscoveryCommandLine
{
    struct New: ParsableCommand
    {
        @Argument(help: "Human-readable name for your server to use in invites")
        var name: String

        @Argument(help: "Port on which to run the server")
        var port: Int
        
        mutating public func run() throws
        {
            let keychainDirectoryURL = File.homeDirectory().appendingPathComponent(".discovery-server")
            let keychainLabel = "Discovery.KeyAgreement"
            
            try Antiphony.generateNew(name: name, port: port, serverConfigURL: serverConfigURL, clientConfigURL: clientConfigURL, keychainURL: keychainDirectoryURL, keychainLabel: keychainLabel)
        }
    }
}

extension DiscoveryCommandLine
{
    struct Run: ParsableCommand
    {
        mutating func run() throws
        {
            let customDiscovery = try Antiphony(serverConfigURL: serverConfigURL, loggerLabel: loggerLabel, capabilities: Capabilities(.display, .networkListen))
            
            guard let newListener = customDiscovery.listener else
            {
                throw AntiphonyError.failedToCreateListener
            }
            
            let discoveryLogic = DiscoveryBootstrap()
            let demoServer = DiscoveryBootstrapServer(listener: newListener, handler: discoveryLogic)
            
            customDiscovery.wait()
        }
    }
}

DiscoveryCommandLine.main()
