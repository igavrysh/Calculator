//
//  VariablesViewController.swift
//  Calculator
//
//  Created by Gavrysh on 8/24/17.
//  Copyright © 2017 Gavrysh. All rights reserved.
//

import UIKit

class VariablesViewGenerator {
    
    static func variablesView(withTitle title: String,
                              message: String,
                              sourceView: UIView,
                              value: Double,
                              onOkHandler: @escaping ((_ sender: UIAlertController) -> Void)) -> UIAlertController
    {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        
        alertController.popoverPresentationController?.sourceView = sourceView
        alertController.popoverPresentationController?.sourceRect =  sourceView.bounds
        
        let okAction = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: { (alert :UIAlertAction!) in
                onOkHandler(alertController)
            }
        )
        
        alertController.addTextField(configurationHandler: { textField in
            textField.text = String(value)
            textField.textAlignment = .center
        })
        
        alertController.addAction(okAction)
        
        return alertController
    }
}
