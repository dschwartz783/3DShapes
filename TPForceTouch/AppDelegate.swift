//
//  AppDelegate.swift
//  TPForceTouch
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
    let calcQueue: dispatch_queue_t = dispatch_queue_create("calcQueue", DISPATCH_QUEUE_CONCURRENT)
    let arrayQueue: dispatch_queue_t = dispatch_queue_create("arrayQueue", DISPATCH_QUEUE_SERIAL)
    var coordinateArray: Array<SCNVector3> = []
    var indices: [Int] = []
    @IBOutlet weak var mainScene: SCNView!
    
    func drawArt(window: NSView)
    {
        let begin_time = NSDate().timeIntervalSince1970
        let numPoints = CGFloat((self.numPointsField.stringValue as NSString).doubleValue)
        if numPoints > 0
        {
            let mainPath: NSBezierPath = NSBezierPath()
            mainPath.lineWidth = 0.25
            NSColor.greenColor().set()
            var smallestDimension: CGFloat
            if (window.frame.height < window.frame.width)
            {
                smallestDimension = window.frame.height
            }
            else
            {
                smallestDimension = window.frame.width
            }
            
            let r: CGFloat = 1
            
            self.coordinateArray.removeAll()
            
            for (var theta: CGFloat = 0; theta <= CGFloat(M_PI); theta += CGFloat(M_PI) / CGFloat(numPoints) * 2)
            {
                    dispatch_apply(Int(numPoints), calcQueue, { (n: Int) -> Void in
                        var phi = M_PI * Double(2) / Double(numPoints) * Double(n)
                        let newVector = SCNVector3Make(r * CGFloat(sin(theta)) * CGFloat(cos(phi)), r * CGFloat(sin(theta)) * CGFloat(sin(phi)), r * CGFloat(cos(theta)))
                            dispatch_sync(self.arrayQueue, { () -> Void in
                                self.coordinateArray.append(newVector)
                            })
                    })
                
            }
            dispatch_barrier_async(calcQueue, { () -> Void in
                
                let testScene = SCNScene()
                
                for coord1 in self.coordinateArray
                {
                    let junkNode1: SCNNode = SCNNode()
                    junkNode1.position = coord1
                    
                    for coord2 in self.coordinateArray
                    {
                        let junkNode2: SCNNode = SCNNode()
                        junkNode2.position = coord2
                        let newNode = self.lineBetweenNodeA(junkNode1, nodeB: junkNode2)

                        testScene.rootNode.addChildNode(newNode)
                        
                    }
                }
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.mainScene.autoenablesDefaultLighting = true
                    self.mainScene.allowsCameraControl = true
                    self.mainScene.scene = testScene
                })
            })
        }
        let totalTime = NSDate().timeIntervalSince1970 - begin_time
    }
    
    func lineBetweenNodeA(nodeA: SCNNode, nodeB: SCNNode) -> SCNNode
    {
        let positions: [CGFloat] = [nodeA.position.x, nodeA.position.y, nodeA.position.z, nodeB.position.x, nodeB.position.y, nodeB.position.z]
        let positionData = NSData(bytes: positions, length: sizeof(CGFloat)*positions.count)
        let indices: [Int32] = [0, 1]
        let indexData = NSData(bytes: indices, length: sizeof(Int32) * indices.count)
        
        let source = SCNGeometrySource(data: positionData, semantic: SCNGeometrySourceSemanticVertex, vectorCount: indices.count, floatComponents: true, componentsPerVector: 3, bytesPerComponent: sizeof(CGFloat), dataOffset: 0, dataStride: sizeof(CGFloat) * 3)
        let element = SCNGeometryElement(data: indexData, primitiveType: SCNGeometryPrimitiveType.Line, primitiveCount: indices.count, bytesPerIndex: sizeof(Int32))
        
        let line = SCNGeometry(sources: [source], elements: [element])
        return SCNNode(geometry: line)
    }

    @IBAction func drawPushed(sender: NSButton)
    {
        //self.mainScene.backgroundColor = NSColor.blackColor()
        sender.enabled = false
        self.drawArt(self.mainScene)
        sender.enabled = true
    }
    
    @IBAction func buttonPressed(sender: NSButton)
    {
        self.pressLabel.stringValue=sender.integerValue.description
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification)
    {
        self.window.delegate = self
        // Insert code here to initialize your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool
    {
        return true;
    }
    
    func xy_values(angle: CGFloat, currentWindow: AnyObject?) -> (CGFloat, CGFloat)
    {
        var cur_size: CGFloat = window.frame.height
        if window.frame.width < window.frame.height {
            cur_size = window.frame.width
        }
        var compensated_x = sin(angle / CGFloat(180.0) * CGFloat(M_PI)) * (cur_size - 60) / 2 + window.frame.width / 2
        var compensated_y = cos(angle / CGFloat(180.0) * CGFloat(M_PI)) * (cur_size - 60) / 2 + window.frame.height / 2
        return (compensated_x, compensated_y)
    }
}