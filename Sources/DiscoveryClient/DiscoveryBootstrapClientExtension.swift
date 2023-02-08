//
//  File.swift
//  
//
//  Created by Joshua Clark on 2/6/23.
//

import Antiphony
import Foundation
import Transmission

extension DiscoveryBootstrapClient {
    public convenience init(configURL: URL) throws
    {
        guard let config = ClientConfig(url: configURL) else {
            throw AntiphonyError.invalidConfigFile
        }
        
        guard let connection = TransmissionConnection(host: config.host, port: config.port) else
        {
            throw AntiphonyError.failedToCreateConnection
        }
        
        self.init(connection: connection)
    }
}

