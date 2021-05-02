//
//  MainMenuScene.swift
//  Zombie Conga!
//
//  Created by Marcus on 2021-05-02.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    func sceneTapped() {
        let myScene = GameScene(size: self.size)
        myScene.scaleMode = self.scaleMode
        let reveal = SKTransition.doorway(withDuration: 1.5)
        self.view?.presentScene(myScene, transition: reveal)
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "MainMenu")
        
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        self.addChild(background)
        print("at main menu")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneTapped()
        print("mainmenu tapped")
    }
    
    
    
}
