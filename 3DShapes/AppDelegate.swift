    //
//  AppDelegate.swift
//  3DShapes
//
//  Created by MainWaffle on 3/28/15.
//  Copyright (c) 2015 MainWaffle. All rights reserved.
//

import Cocoa
import SceneKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, SCNSceneRendererDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var pressLabel: NSTextField!
    @IBOutlet weak var numPointsField: NSTextField!
    let calcQueue = DispatchQueue(label: "calcQueue", qos: DispatchQoS.userInteractive, attributes: DispatchQueue.Attributes.concurrent)
    let arrayQueue = DispatchQueue(label: "arrayQueue")
    
    @IBOutlet weak var mainScene: SCNView!
    
    func drawArt(window: NSView) {
        let numPoints = (self.numPointsField.stringValue as NSString).doubleValue
        if numPoints > 0 {
            
            let r: CGFloat = 1
            
            var coordinateArray: [SCNVector3] = []
            
            stride(from: 0, through: Double.pi, by: Double.pi / numPoints * 2).forEach({ (theta) in
                stride(from: 0, through: Double.pi * 2, by: Double.pi / numPoints * 2).forEach({ (phi) in
                    let newVector = SCNVector3Make(r * CGFloat(sin(theta)) * CGFloat(cos(phi)), r * CGFloat(sin(theta)) * CGFloat(sin(phi)), r * CGFloat(cos(theta)))
                    coordinateArray.append(newVector)
                })
            })
            
            let mainNode = SCNNode()
            
            coordinateArray.forEach({ (coord1) in
                
                coordinateArray.forEach({ (coord2) in
                    let newNode = self.line(from: coord1, to: coord2)!
                    
                    mainNode.addChildNode(newNode)

                    let colorMaterial = SCNMaterial()
                    colorMaterial.diffuse.contents = NSColor.yellow
                    newNode.geometry!.firstMaterial = colorMaterial
                })
            })
            
            let resultScene = SCNScene()
            resultScene.rootNode.addChildNode(mainNode)
            self.mainScene.scene = resultScene
        }
    }
    
    func line(from p1: SCNVector3, to p2: SCNVector3) -> SCNNode? {
        // Draw a line between two points and return it as a node
        var indices: [Int32] = [0, 1]
        let positions = [p1, p2]
        let vertexSource = SCNGeometrySource(vertices: positions)
        let indexData = Data(bytes: &indices, count:MemoryLayout<Int32>.size * indices.count)
         let element = SCNGeometryElement(data: indexData, primitiveType: .line, primitiveCount: 1, bytesPerIndex: MemoryLayout<Int32>.size)
        let line = SCNGeometry(sources: [vertexSource], elements: [element])
        let lineNode = SCNNode(geometry: line)
        return lineNode
    }
    
    @IBAction func drawPushed(sender: NSButton) {
        sender.isEnabled = false
        self.drawArt(window: self.mainScene)
        sender.isEnabled = true
    }
    
    @IBAction func buttonPressed(sender: NSButton) {
        self.pressLabel.stringValue=sender.integerValue.description
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.window.delegate = self
        // Insert code here to initialize your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true;
    }
    
    func xy_values(angle: CGFloat, currentWindow: AnyObject?) -> (CGFloat, CGFloat) {
        var cur_size: CGFloat = window.frame.height
        if window.frame.width < window.frame.height {
            cur_size = window.frame.width
        }
        let compensated_x = sin(angle / CGFloat(180.0) * CGFloat(Double.pi)) * (cur_size - 60) / 2 + window.frame.width / 2
        let compensated_y = cos(angle / CGFloat(180.0) * CGFloat(Double.pi)) * (cur_size - 60) / 2 + window.frame.height / 2
        return (compensated_x, compensated_y)
    }
}
