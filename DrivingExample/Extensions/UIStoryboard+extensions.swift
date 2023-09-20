//
//  UIStoryboard+extensions.swift
//  Hekate
//
//  Created by Juraj Antas on 12/11/2018.
//  Copyright © 2018 Juraj Antas. All rights reserved.
//

import UIKit

extension UIStoryboard {
    func initialViewController<T: UIViewController>() -> T {
        return self.instantiateInitialViewController() as! T
    }
}
