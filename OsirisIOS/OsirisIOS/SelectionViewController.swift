//
//  SelectionViewController.swift
//  OsirisIOS
//
//  Created by Avinash Jain on 3/10/18.
//  Copyright © 2018 Avinash Jain. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func numbersPressed(_ sender: Any) {
        User.currentUser.category = .numbers
        performSegue(withIdentifier: "display", sender: self)
    }
    
    @IBAction func lettersPressed(_ sender: Any) {
        User.currentUser.category = .letters
        performSegue(withIdentifier: "display", sender: self)
    }
}
