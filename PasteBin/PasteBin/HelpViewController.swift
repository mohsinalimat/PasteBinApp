//
//  HelpViewController.swift
//  PasteBin
//
//  Created by JonLuca De Caro on 12/29/16.
//  Copyright © 2016 JonLuca De Caro. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var previousStoryboardIsMainView = false
    
    @IBAction func buttonBack(_ sender: Any) {
        
        if previousStoryboardIsMainView {
            // Transition to main view in order to reset background scrolling
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil);
            let vC: ViewController = mainStoryboard.instantiateViewController(withIdentifier: "mainView") as! ViewController
            self.present(vC, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func done(_ sender: Any) {
        
        if previousStoryboardIsMainView {
            // Transition to main view in order to reset background scrolling
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil);
            let vC: ViewController = mainStoryboard.instantiateViewController(withIdentifier: "mainView") as! ViewController
            self.present(vC, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    
    }
}
