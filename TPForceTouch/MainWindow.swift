//
//  MainWindow.swift
//  TPForceTouch
//
//  Created by MainWaffle on 3/28/15.
//  Copyright (c) 2015 MainWaffle. All rights reserved.
//

import Cocoa
import SceneKit

class MainWindow: NSWindow {
    
    
    override func update() {    }
    
    func xy_values(angle: CGFloat) -> (CGFloat, CGFloat)
    {
        var cur_size: CGFloat = self.frame.height
        if self.frame.width < self.frame.height {
            cur_size = self.frame.width
        }
        var compensated_x = sin(angle / CGFloat(360) * CGFloat(M_2_PI)) * cur_size / 2 + self.frame.width / 2
        var compensated_y = cos(angle / CGFloat(360) * CGFloat(M_2_PI)) * cur_size / 2 + self.frame.height / 2
        return (compensated_x, compensated_y)
    }
}