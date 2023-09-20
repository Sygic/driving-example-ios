//
//  UIDevice+extensions.swift
//  Hekate
//
//  Created by Juraj Antas on 05/11/2018.
//  Copyright © 2018 Juraj Antas. All rights reserved.
//

import UIKit

extension UIDevice {
    var isSimulator: Bool {
        #if IOS_SIMULATOR
        return true
        #else
        return false
        #endif
    }
}
