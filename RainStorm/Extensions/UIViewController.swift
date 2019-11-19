//
//  UIViewController.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 19/11/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import UIKit

extension UIViewController {
    //MARK: Static Properties
    
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}
