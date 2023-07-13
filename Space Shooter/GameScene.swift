//
//  GameScene.swift
//  Space Shooter
//
//  Created by Jason Castillo on 1/7/17.
//  Copyright © 2017 Jason Castillo. All rights reserved.
//

import SpriteKit
import GameplayKit

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var levelNumber = 0
    
    let player = SKSpriteNode (imageNamed: "Spaceship")
    
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    enum gameState{
        case preGame //when the game state is before the start of the game
        case inGame //when the game state is is during the game
        case afterGame //when the game is after the game
        
    }
    
    var currentGameState = gameState.preGame
    
    struct PhysicsCategories{
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b0001
        static let Missile : UInt32 = 0b0010
        static let Enemy1 : UInt32 = 0b0100
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max-min) + min
    }
    
    var gameArea: CGRect
    
    override init(size: CGSize){
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playablewidth = size.height / maxAspectRatio
        let margin = (size.width - playablewidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playablewidth, height: size.height)
        
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0...1{
        //Setting Background
       let background = SKSpriteNode (imageNamed: "stars")
        background.size = self.size
        background.anchorPoint = CGPoint(x: 0.5, y: 0)
        background.position = CGPoint(x: self.size.width/2, y: self.size.height*CGFloat(i))
        background.zPosition = 0
        background.name = "Background"
        self.addChild(background)
        }
        
        //Setting spaceship
        player.setScale(0.5)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy1
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.85, y:self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height*0.9, duration: 0.3)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
        
        
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let faceInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(faceInAction)
        
        
    }
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        }
        else{
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
            
        }
        
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "Background"){
            
            background, stop in
            
            if self.currentGameState == gameState.inGame{
            background.position.y -= amountToMoveBackground
            }
            if background.position.y < -self.size.height{
                background.position.y += self.size.height * 2
            }
            
        }
        
    }
    
    func startGame(){
        
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOnToScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOnToScreenAction, startLevelAction])
        player.run(startGameSequence)
        
    }
    func loseALife(){
        
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUP = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUP, scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0{
            runGameOver()
        }
    }
    
    func addScore(){
        
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50{
            startNewLevel()
        }
        
    }
    
    func runGameOver(){
      
        currentGameState = gameState.afterGame
        
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "Missile"){
            missile, stop in
            
            missile.removeAllActions()
            
        }
        
        self.enumerateChildNodes(withName: "EnemyA"){
            enemy, stop in
            enemy.removeAllActions()
        }
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene,changeSceneAction])
        self.run(changeSceneSequence)

    }
    func changeScene(){
        
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let mytransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: mytransition)
        }
    
     func didBegin(_ contact: SKPhysicsContact){
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy1{
            //if the player hits the enemy
            
            if body1.node != nil {
            spawnExplosion(body1.node!.position)
            }
            
            if body2.node != nil {
            spawnExplosion(body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
        }
        if body1.categoryBitMask == PhysicsCategories.Missile && body2.categoryBitMask == PhysicsCategories.Enemy1 && (body2.node?.position.y)! < self.size.height{
            //if the missile has hit the enemy
            
            addScore()
            
            if body2.node != nil {
            spawnExplosion(body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            
        }
    }
    
    func spawnExplosion(_ spawnPosition: CGPoint){
        
        let explosion = SKSpriteNode (imageNamed: "explosion-1")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([scaleIn,fadeOut, delete])
        
        explosion.run(explosionSequence)
    }
    
    func startNewLevel(){
        
        
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber{
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default:
            levelDuration = 0.5
            print("Cannot find level info")
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: 1)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")

    }
    
func firemissile() {
    
    let missile = SKSpriteNode (imageNamed: "missile")
    missile.name = "Missle"
    missile.setScale(0.1)
    missile.position = player.position
    missile.zPosition = 1
    missile.physicsBody = SKPhysicsBody(rectangleOf: missile.size)
    missile.physicsBody!.affectedByGravity = false
    missile.physicsBody!.categoryBitMask = PhysicsCategories.Missile
    missile.physicsBody!.collisionBitMask = PhysicsCategories.None
    missile.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy1
    self.addChild(missile)
    
    let moveMissile = SKAction.moveTo(y: self.size.height + missile.size.height, duration: 1)
    let deleteMissile = SKAction.removeFromParent()
    let sequenceMissile = SKAction.sequence([moveMissile,deleteMissile])
    
    missile.run(sequenceMissile)
    
    
    }
    
    func spawnEnemy(){
        
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "Enemy")
        enemy.name = "EnemyA"
        enemy.setScale(0.5)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy1
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Missile
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy,deleteEnemy, loseALifeAction])
        
        if currentGameState == gameState.inGame{
            enemy.run(enemySequence)
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.preGame{
            startGame()
        }
        
        else if currentGameState == gameState.inGame{
           
            
            let shoot = SKAction.run(firemissile)
            let waitToShoot = SKAction.wait(forDuration: 0.5)
            let shootSequence = SKAction.sequence([waitToShoot, shoot])
            let shootForever = SKAction.repeatForever(shootSequence)
            self.run(shootForever)
            //firemissile()
                
                
               // i += 1
            }
        }    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeAllActions()
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            let previousTouch = touch.previousLocation(in: self)
            
            let amountDraggedx = pointOfTouch.x - previousTouch.x
            let amountDraggedy = pointOfTouch.y - previousTouch.y
            
            if currentGameState == gameState.inGame{
                player.position.x += amountDraggedx
                player.position.y += amountDraggedy
            }
            
            
            if player.position.x > gameArea.maxX - player.size.width/2{
                player.position.x = gameArea.maxX - player.size.width/2
            }
            if player.position.x < gameArea.minX + player.size.width/2{
                player.position.x = gameArea.minX + player.size.width/2
            }
            
            if player.position.y > gameArea.maxY - player.size.width/2{
                player.position.y = gameArea.maxY - player.size.width/2
            }
            if player.position.y < gameArea.minY + player.size.width/2{
                player.position.y = gameArea.minY + player.size.width/2
            }
        }
    }
}

