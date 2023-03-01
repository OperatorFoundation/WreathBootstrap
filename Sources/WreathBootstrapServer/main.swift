//
//  main.swift
//  Bootstrap
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
import WreathBootstrap
import Gardener
import Net
import Spacetime


struct WreathBootstrapCommandLine: ParsableCommand
{
    static let configuration = CommandConfiguration(
        commandName: "WreathBootstrap",
        subcommands: [New.self, Run.self]
    )
    
    static let clientConfigURL =  File.homeDirectory().appendingPathComponent("Bootstrap-client.json")
    static let serverConfigURL = URL(fileURLWithPath: File.homeDirectory().path).appendingPathComponent("Bootstrap-server.json")
    static let loggerLabel = "org.OperatorFoundation.BootstrapLogger"
}

extension WreathBootstrapCommandLine
{
    struct New: ParsableCommand
    {
        @Argument(help: "Human-readable name for your server to use in invites")
        var name: String

        @Argument(help: "Port on which to run the server")
        var port: Int
        
        mutating public func run() throws
        {
            let keychainDirectoryURL = File.homeDirectory().appendingPathComponent(".Bootstrap-server")
            let keychainLabel = "WreathBootstrap.KeyAgreement"
            
            try Antiphony.generateNew(name: name, port: port, serverConfigURL: serverConfigURL, clientConfigURL: clientConfigURL, keychainURL: keychainDirectoryURL, keychainLabel: keychainLabel)
        }
    }
}

extension WreathBootstrapCommandLine
{
    struct Run: ParsableCommand
    {
        mutating func run() throws
        {
            let customBootstrap = try Antiphony(serverConfigURL: serverConfigURL, loggerLabel: loggerLabel, capabilities: Capabilities(.display, .networkListen))
            
            guard let newListener = customBootstrap.listener else
            {
                throw AntiphonyError.failedToCreateListener
            }
            
            let BootstrapLogic = WreathBootstrap()
            let demoServer = WreathBootstrapServer(listener: newListener, handler: BootstrapLogic)
            
            customBootstrap.wait()
        }
    }
}

WreathBootstrapCommandLine.main()
