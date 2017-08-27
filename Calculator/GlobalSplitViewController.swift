//
//  GlobalSplitViewController.swift
//  Calculator
//
//  Created by Gavrysh on 8/27/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import UIKit

class GlobalSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool
    {
        if let navigationController = secondaryViewController as? UINavigationController,
            let _ = navigationController.topViewController as? GraphViewController
        {
            return false
        }
        
        return true
    }
    
}