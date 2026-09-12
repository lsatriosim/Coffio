//
//  Container.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/09/26.
//

import FactoryKit
import Foundation

extension Container {
    var networkService: Factory<NetworkServiceProtocol> {
        self {
            NetworkService()
        }
        .singleton
    }
}
