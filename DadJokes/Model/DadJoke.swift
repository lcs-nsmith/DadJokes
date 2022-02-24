//
//  DadJoke.swift
//  DadJokes
//
//  Created by Nathan Smith on 2022-02-22.
//

import Foundation
import System

// The Dadjoke structure confomrs to the Decodable Protocol. This means that we want Swift to be able to take a JSON object and 'decode' into an instance of this structure.
struct DadJoke: Decodable, Hashable, Encodable {
    let id: String
    let joke: String
    let status: Int
}
