//
//  RealmTests.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/16/17.
//  Copyright © 2017 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

@testable import Datum
import XCTest

class RealmTests: XCTestCase {

    func testUserPathCode() {
        let appName = "MeToo3"
        let url = URL(string: "http://myserver.level1.com:8080")!

        let user1 = "/~/"
        let realmURL1 = url.realmURL(withAppName: appName, userPath: user1)
        XCTAssert(realmURL1 == URL(string: "realm://myserver.level1.com:8080/~/MeToo3")!)

        let user2 = "~/"
        let realmURL2 = url.realmURL(withAppName: appName, userPath: user2)
        XCTAssert(realmURL2 == URL(string: "realm://myserver.level1.com:8080/~/MeToo3")!)

        let user3 = "~"
        let realmURL3 = url.realmURL(withAppName: appName, userPath: user3)
        XCTAssert(realmURL3 == URL(string: "realm://myserver.level1.com:8080/~/MeToo3")!)

        let user4 = "/jeffburg/"
        let realmURL4 = url.realmURL(withAppName: appName, userPath: user4)
        XCTAssert(realmURL4 == URL(string: "realm://myserver.level1.com:8080/jeffburg/MeToo3")!)

        let user5 = "jeffburg/"
        let realmURL5 = url.realmURL(withAppName: appName, userPath: user5)
        XCTAssert(realmURL5 == URL(string: "realm://myserver.level1.com:8080/jeffburg/MeToo3")!)

        let user6 = "jeffburg"
        let realmURL6 = url.realmURL(withAppName: appName, userPath: user6)
        XCTAssert(realmURL6 == URL(string: "realm://myserver.level1.com:8080/jeffburg/MeToo3")!)
    }

    func testSecureVSNonSecureCode() {
        let appName = "MeToo3"
        let user = "~/"

        let nonSecure = URL(string: "http://myserver.level1.com:8080")!
        let realmURL = nonSecure.realmURL(withAppName: appName, userPath: user)
        XCTAssert(realmURL == URL(string: "realm://myserver.level1.com:8080/~/MeToo3")!)

        let nonSecureSlash = URL(string: "http://myserver.level1.com:8080/")!
        let realmURLSlash = nonSecureSlash.realmURL(withAppName: appName, userPath: user)
        XCTAssert(realmURLSlash == URL(string: "realm://myserver.level1.com:8080/~/MeToo3")!)

        let secure = URL(string: "https://myserver.level1.com:8080")!
        let secureRealmURL = secure.realmURL(withAppName: appName, userPath: user)
        XCTAssert(secureRealmURL == URL(string: "realms://myserver.level1.com:8080/~/MeToo3")!)

        let secureSlash = URL(string: "https://myserver.level1.com:8080/")!
        let secureRealmURLSlash = secureSlash.realmURL(withAppName: appName, userPath: user)
        XCTAssert(secureRealmURLSlash == URL(string: "realms://myserver.level1.com:8080/~/MeToo3")!)
    }

}
