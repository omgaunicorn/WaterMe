//
//  ViewController.swift
//  AdminConsole
//
//  Created by Jeffrey Bergier on 5/18/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeData
import RealmSwift
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data = PrivateKeys.jsonSampleData.data(using: .utf8)!
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        print(json)
    }
}

