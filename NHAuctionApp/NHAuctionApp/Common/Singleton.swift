//
//  Singleton.swift
//  NHAuctionApp
//
//  Created by MackBook Pro on 2023/02/14.
//

import Foundation

class Singleton {
    static let shared = Singleton()

    var isAppVersionCheck: Bool = true
    var isNotRunningDynamicLink: String = ""

    private init() { }
}
