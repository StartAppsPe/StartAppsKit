//
//  ViewController.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 09/17/2015.
//  Copyright (c) 2015 Gabriel Lanata. All rights reserved.
//

import UIKit
import StartAppsKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print(owner: "LoadAction", items: "Cache Loaded = Error", level: LogLevel.Error)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

