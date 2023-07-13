//
//  GameViewController.swift
//  Space Shooter
//
//  Created by Jason Castillo on 1/7/17.
//  Copyright © 2017 Jason Castillo. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: CGSize(width: 1536, height: 2048))
         let view = self.view as! SKView
            // Load the SKScene from 'GameScene.sks'
                            // Set the scale mode to scale to fit the window
        
        
            view.showsFPS = true
            view.showsNodeCount = true
            view.ignoresSiblingOrder = true
        
        scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
