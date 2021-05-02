//
//  GameViewController.swift
//  Zombie Conga!
// this code was used from the book 2D Apple Games by Tutorials published by raywenderlich.com 2017
//

//
//  Created by Marcus on 2021-04-19.
//

import UIKit
import SpriteKit
//import GameplayKit

class GameViewController: UIViewController {

    
    //overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = MainMenuScene(size:CGSize(width: 2048, height: 1536))
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
