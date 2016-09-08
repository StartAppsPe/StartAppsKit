//
//  ViewController.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 09/18/2015.
//  Copyright (c) 2015 Gabriel Lanata. All rights reserved.
//

import UIKit
import StartAppsKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //print(owner: "Hola", items: "Chau1", "Chau2", "Chau3", level: .Error)
        //print(owner: "Calendar", items: "Bien", level: .Error)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


let jsonUrl = NSURL(string: "http://beta.json-generator.com/api/json/get/Nyg_6Muo-")!

class ViewController2: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let loadAction = JsonLoadAction(
        baseLoadAction: WebLoadAction(
            urlRequest: { (completion) in
                completion(result: .Success(NSURLRequest(URL: jsonUrl)))
            }
        )
    )
    
    let loadAction2 = WebLoadAction(urlRequest: { (completion) in
        completion(result: .Success(NSURLRequest(URL: jsonUrl)))
    }).then({ (loadAction) in
        return JsonLoadAction(baseLoadAction: loadAction)
    })
    
    
    
    
    let loadAction3 = LoadAction.start({
        return WebLoadAction(
            urlRequest: { (completion) in
                completion(result: .Success(NSURLRequest(URL: jsonUrl)))
            }
        )
    }).then({ (loadAction) in
        return JsonLoadAction(baseLoadAction: loadAction)
    })
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        loadAction.addDelegate(tableView)
        loadAction.load(completion: nil)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loadAction.value?.array?.count ?? 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let person = loadAction.value!.array![indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath)
        cell.textLabel?.text = person["balance"].string!
        return cell
    }
    
    
}