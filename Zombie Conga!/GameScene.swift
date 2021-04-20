//
//  GameScene.swift
//  Zombie Conga!
//
//  Created by Marcus on 2021-04-19.
//

import SpriteKit
//import GameplayKit

class GameScene: SKScene {
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    var playableRect: CGRect
    
    //move sprite with velocity
    private func move(sprite: SKSpriteNode, velocity: CGPoint) {
        //move sprite points/sec X fraction of seconds since last update, the vector
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y*CGFloat(dt))
        print("AMount to move: \(amountToMove)")
        //add vector to sprites new position
        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
    }
    
    private func moveZombieToward(location: CGPoint) {
        let offset = CGPoint(x: location.x - zombie.position.x,
                             y: location.y - zombie.position.y)
        let length = sqrt(
          Double(offset.x * offset.x + offset.y * offset.y))
        let direction = CGPoint(x: offset.x / CGFloat(length),
                                y: offset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * zombieMovePointsPerSec,
                           y: direction.y * zombieMovePointsPerSec)
      }
    
    func sceneTouched(touchLocation: CGPoint) {
        moveZombieToward(location: touchLocation)
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode(rect: playableRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }

    
    
    //overrides
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 2.16 // max aspect ratio
        let playableHeight = size.width / maxAspectRatio // playable heiht is height of scene / max aspect ration
        let playableMargin = (size.height-playableHeight)/2.0 // want the margin so subtract playable height from scene height
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight) // make the playable rectangle
        super.init(size: size) // call initilizer of super class
      }

      required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // must override requiredNSCoder
      }

    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        //set background sprirte
        let background = SKSpriteNode(imageNamed: "background1")
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint.zero
        background.zPosition = -1
        //set zombie
        
        zombie.anchorPoint = CGPoint.zero
        zombie.zPosition = 1
        zombie.position = CGPoint(x: 400, y: 400)
        
        //add nodes
        addChild(background)
        addChild(zombie)
        debugDrawPlayableArea()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        }
        else {
            dt = 0
        }
        lastUpdateTime = currentTime
        print("\(dt*1000) milliseconds since last update)")
        move(sprite: zombie, velocity: velocity)
        boundsCheckZombie()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return}
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return}
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
}
