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
    let zombieAnimation: SKAction
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    var playableRect: CGRect
    var lastTouchLocation: CGPoint?
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    var zombieIsInvincible = false
    let catMovePerSecond: CGFloat = 480.0
    var zombieLives = 5
    var gameOver = false
    let cameraNode = SKCameraNode()
    let cameraMovePointPerSec: CGFloat = 200.0
    var cameraRect: CGRect {
        let x = cameraNode.position.x - size.width/2 + (size.width - playableRect.width)/2
        let y = cameraNode.position.y - size.height/2 + (size.height - playableRect.height)/2
        return CGRect(x: x, y: y, width: playableRect.width, height: playableRect.height)
    }
    
    
    
    
    //move sprite with velocity
    private func move(sprite: SKSpriteNode, velocity: CGPoint) {
        //move sprite points/sec X fraction of seconds since last update, the vector
        let amountToMove = velocity * CGFloat(dt)
        //print("AMount to move: \(amountToMove)")
        //add vector to sprites new position
        sprite.position += amountToMove
    }
    
    func loseCats() {
        //trqck cats lost
        var loseCount = 0
        enumerateChildNodes(withName: "train") { node, stop in
            //find random offset from cat's current position
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            //move cat to random spot
            node.name = ""
            node.run(
                SKAction.sequence([ SKAction.group([
                SKAction.rotate(byAngle: π*4, duration: 1.0), SKAction.move(to: randomSpot, duration: 1.0), SKAction.scale(to: 0, duration: 1.0)
                ]),SKAction.removeFromParent() ]))
            //update cat's removed count
            loseCount += 1
            if loseCount >= 2 {
                stop[0] = true
            }
        }
    }
    
    private func moveZombieToward(location: CGPoint) {
        let offset = location - zombie.position
        let direction = offset.normalized()
        startZombieAnimation()
        velocity = direction * zombieMovePointsPerSec
      }
    
    func sceneTouched(touchLocation: CGPoint) {
        lastTouchLocation = touchLocation
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
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiaNSPERSEC: CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiaNSPERSEC * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(min: playableRect.minY + enemy.size.height/2, max: playableRect.maxY - enemy.size.height/2))
        addChild(enemy)
    
        let actionMove = SKAction.moveTo(x: -enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func startZombieAnimation() {
        if zombie.action(forKey: "animation") == nil {
            zombie.run(SKAction.repeatForever(zombieAnimation), withKey: "animation")
        }
    }
    
    func zombieHit(enemey: SKSpriteNode) {
        //enemey.removeFromParent()
        if zombieIsInvincible == false {
            zombieIsInvincible = true
            let blinkTimes = 10.0
            let blinkDuration = 3.0
            let blinkAction = SKAction.customAction(withDuration: blinkDuration) { node, elapsedTime in
                let slice = blinkDuration / blinkTimes
                let remainder = Double(elapsedTime).truncatingRemainder(
                    dividingBy: slice)
                    node.isHidden = remainder > slice / 2
            }
            let setHidden = SKAction.run() { [weak self] in
                self?.zombie.isHidden = false
                self?.zombieIsInvincible = false
            }
        
            zombie.run(SKAction.sequence([blinkAction, setHidden]))
            run(enemyCollisionSound)
            loseCats()
            zombieLives -= 1
        }
        
    }
    func zombieHit(cat: SKSpriteNode) {
        //cat.removeFromParent()
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1.0)
        cat.zRotation = 0
        cat.run(SKAction.colorize(with: SKColor.green, colorBlendFactor: 1.0, duration: 0.2))
        
        zombie.zPosition = 100
        
        run(catCollisionSound)
        
    }
    
    func moveTrain() {
        var trainCount = 0
        var targetPosition = zombie.position
        enumerateChildNodes(withName: "train") { node, stop in if !node.hasActions() {
            let actionDuration = 0.3
            let offset = targetPosition - node.position
            let direction = offset.normalized()
            let amountToMovePerSec = direction * self.catMovePerSecond
            let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
            let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration)
            node.run(moveAction) }
        targetPosition = node.position
            trainCount += 1
        }
        
        if trainCount >= 15 && !gameOver {
            gameOver = true
            print("You Win!")
            gameOverTransition()
        }
    }
    
    func gameOverTransition() {
        //1
        var gameOverScene: GameOverScene
        if zombieLives <= 0 && gameOver {
            gameOverScene = GameOverScene(size: size, won: false)
        }
        else {
            gameOverScene = GameOverScene(size: size, won: true)
        }
        gameOverScene.scaleMode = scaleMode
        //2
        let revel = SKTransition.flipHorizontal(withDuration: 0.5)
        //2.5
        backgroundMusicPlayer.stop()
        //3
        view?.presentScene(gameOverScene, transition: revel)

    }
    
    func checkCollisions() {
        var hitsCats: [SKSpriteNode] = []
        enumerateChildNodes(withName: "cat") { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.zombie.frame) {
            hitsCats.append(cat)
            }
        }
        for cat in hitsCats {
            zombieHit(cat: cat)
        }
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 20).intersects(self.zombie.frame) {
            hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            zombieHit(enemey: enemy)
        }
    }
    
    func spawnCat() {
        //create cat with random spawn spot
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(x: CGFloat.random(min: playableRect.minX, max: playableRect.maxX), y: CGFloat.random(min: playableRect.minY, max: playableRect.maxY))
        cat.setScale(0)
        addChild(cat)
        //scale cat to existence then out.
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        //let wait = SKAction.wait(forDuration: 5.0)
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        //let waitWiggle = SKAction.repeat(fullWiggle, count: 10)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count:10)
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.run(SKAction.sequence(actions))
        
    }
    
    func stopZombieAnimation() {
        zombie.removeAction(forKey: "animation")
    }
    
    func moveCamera() {
        let backgroundVelocity = CGPoint(x: cameraMovePointPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        
        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < self.cameraRect.origin.x {
                background.position = CGPoint(x: background.position.x + background.size.width*2, y: background.position.y)
            }
        }
    }
    
    func backgroundNode() -> SKSpriteNode{
        // create background node
        print("start background node")
        let backgroudNode = SKSpriteNode()
        backgroudNode.anchorPoint = CGPoint.zero
        backgroudNode.name = "background"
        print("background node created")
        //add first background to background node
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroudNode.addChild(background1)
        print("first background added")
        
        //add second background next to first
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroudNode.addChild(background2)
        print("second background added")
        
        //set size of background node to the size of the two backgrounds
        backgroudNode.size = CGSize(width: background1.size.width + background2.size.width, height: background1.size.height)
        print("size of background set returning background")
        
        return backgroudNode
    }

    
    
    //overrides
    override init(size: CGSize) {
        
        
        let maxAspectRatio:CGFloat = 2.16 // max aspect ratio
        let playableHeight = size.width / maxAspectRatio // playable heiht is height of scene / max aspect ration
        let playableMargin = (size.height-playableHeight)/2.0 // want the margin so subtract playable height from scene height
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight) // make the playable rectangle
        var textures: [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
            textures.append(textures[2])
            textures.append(textures[1])
        
        zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
            
    
        super.init(size: size) // call initilizer of super class
      }

      required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // must override requiredNSCoder
      }

    
    override func didMove(to view: SKView) {
        //print("in game before background set")
        backgroundColor = SKColor.black
        //set background sprirte
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            background.zPosition = -1
            addChild(background)
        }
       //addChild(background)
        //set zombie
        zombie.anchorPoint = CGPoint.zero
        zombie.zPosition = 1
        zombie.position = CGPoint(x: 400, y: 400)
        
        //add nodes
        //addChild(background)
        addChild(zombie)
        //zombie.run(SKAction.repeatForever(zombieAnimation))
        
        //debugDrawPlayableArea()
        //keep spawning catlady and cats
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run { [weak self] in self?.spawnEnemy()}, SKAction.wait(forDuration: 2.0)])))
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run() { [weak self] in self?.spawnCat()}, SKAction.wait(forDuration: 1.0)])))
        playBackgroundMusic(filename: "backgroundMusic.mp3")
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        
        
    } //end didmovetp
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        }
        else {
            dt = 0
        }
        lastUpdateTime = currentTime
        //print("\(dt*1000) milliseconds since last update)")
        
        if let lastTouchLocation = lastTouchLocation {
            let diff = lastTouchLocation - zombie.position
            if diff.length() <= zombieMovePointsPerSec * CGFloat(dt) {
                zombie.position = lastTouchLocation
                velocity = CGPoint.zero
                stopZombieAnimation()
            }
            else {
                move(sprite: zombie, velocity: velocity)
                rotate(sprite: zombie, direction: velocity, rotateRadiaNSPERSEC: zombieRotateRadiansPerSec)
            }
        }
        //move(sprite: zombie, velocity: velocity)
        //rotate(sprite: zombie, direction: velocity)
        
        boundsCheckZombie()
        //checkCollisions()
        moveTrain()
        moveCamera()
        //print("Game update")
        
        if zombieLives <= 0 && !gameOver {
            gameOver = true
            print("You Lose")
            gameOverTransition()
        }
    } //end update
    
    override func didEvaluateActions() {
        checkCollisions()
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
