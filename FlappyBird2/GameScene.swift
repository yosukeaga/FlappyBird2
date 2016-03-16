//
//  GameScene.swift
//  FlapyBird
//
//  Created by aga yosuke on 2016/03/11.
//  Copyright © 2016年 yosuke.aga. All rights reserved.
//

import SpriteKit

class GameScene: SKScene , SKPhysicsContactDelegate{

    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    
    
    let birdCategory: UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1
    let wallCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    let itemCategory: UInt32 = 1 << 4
    
    var score = 0
    var itemScore = 0
    let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var itemScoreLabelNode:SKLabelNode!
    var item:SKShapeNode!
    
    
    override func didMoveToView(view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
        physicsWorld.contactDelegate = self
        
        backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.75, blue: 0.9, alpha: 1)
        
    //インスタンス生成
        scrollNode = SKNode()
    //func setGround,setCloud等の中身をsrollNode=addChild(sprite)でscrollNodeに入れたものをaddChildでGameSceneに表示
    //addChildはaddSubViewのようなもの
        addChild(scrollNode)
        
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        
        
        
   
        
        
        
        setGround()
        setCloud()
        setupWall()
        setupBird()
        setupScoreLabel()
        
        
    }
    
    
    func setGround(){
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        
        //1画面に必要な地面の枚数　iphone6の場合、W375、groundのW340 割ると1.102941176＝1.102941176倍したgroundが必要。
        //2+1.1=3.1 3.1枚のgroundがの画像が隙間を埋めるために必要　W340 W340 W340
        let needNumber =  2 + (frame.size.width / groundTexture.size().width)
        
        
        let moveGround = SKAction.moveByX(-groundTexture.size().width, y: 0, duration: 5)
        let resetGround = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0)
        let repeatScrollGround = SKAction.repeatActionForever(SKAction.sequence([moveGround, resetGround]))
    
        for var i:CGFloat = 0; i < needNumber; ++i {
            let sprite = SKSpriteNode(texture: groundTexture)
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: i * sprite.size.width, y: groundTexture.size().height / 2)
            
            sprite.runAction(repeatScrollGround)
            
            sprite.physicsBody = SKPhysicsBody(rectangleOfSize: groundTexture.size())
            
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            sprite.physicsBody?.dynamic = false
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setCloud(){
    
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let needCloudNumber = 2.0 + (size.width / cloudTexture.size().width)
        
        let moveCloud = SKAction.moveByX(-cloudTexture.size().width, y: 0, duration: 20)
        let resetCloud = SKAction.moveByX( cloudTexture.size().width, y: 0, duration: 0)
        let repeatScrollCloud = SKAction.repeatActionForever(SKAction.sequence([moveCloud, resetCloud]))
        
        for var i:CGFloat = 0; i < needCloudNumber; ++i {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100 // 一番後ろになるようにする
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: i * sprite.size.width, y: size.height - cloudTexture.size().height / 2)
            
            // スプライトにアニメーションを設定する
            sprite.runAction(repeatScrollCloud)
            
            // スプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    func setupWall(){
        ///wallTexture400 frame.size.height667
        let wallTexture = SKTexture(imageNamed: "wall")
        //Linearは画質優先
        wallTexture.filteringMode = SKTextureFilteringMode.Linear
        //iphone6で455
        let movingDistance = CGFloat(frame.size.width + wallTexture.size().width * 2)
        let moveWall = SKAction.moveByX(-movingDistance, y: 0, duration: 4)
        let removeWall = SKAction.removeFromParent()
        //順にアクションを実行している。順がポイント！
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        let createWallAnimation = SKAction.runBlock({
            
           //SkNodeのwallインスタンスを作成する
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width * 2, y: 0)
            wall.zPosition = -50
            
            //333.5
            let center_y = self.frame.size.height / 2
            //166.75
            let random_y_range = self.frame.height / 4
            //50
            let under_wall_lowest_y = UInt32( center_y - wallTexture.size().height / 2 - random_y_range / 2)
            let random_y = arc4random_uniform( UInt32(random_y_range))
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            let slit_length = self.frame.size.height / 6
            
            //下側の壁の作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            wall.addChild(under)
            
            under.physicsBody = SKPhysicsBody(rectangleOfSize: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            under.physicsBody?.dynamic = false

       
            //上側の壁の作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            upper.physicsBody = SKPhysicsBody(rectangleOfSize: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            upper.physicsBody?.dynamic = false
            
            wall.addChild(upper)
            
            let scoreNode = SKNode()
                scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width / 2, y: self.frame.height / 2.0)
                scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: upper.size.width, height: self.frame.size.height))
                scoreNode.physicsBody?.dynamic = false
                scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
                scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            //itemの作成//////////////////////
            self.item = SKShapeNode(circleOfRadius: 20)
            self.item.fillColor = UIColor.redColor()
           // let textureB = SKTexture(imageNamed: "bird_a")
        //   self.item = SKSpriteNode(texture: textureB)
                self.item.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 5, height: 5))
                self.item.position = CGPoint(x: upper.size.width - self.bird.size.width * 4 , y: self.frame.size.height/2 )
                self.item.physicsBody?.dynamic = false
                self.item.physicsBody?.categoryBitMask = self.itemCategory
                self.item.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(self.item)
            
            
            
            
            wall.runAction(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        
        let waitAnimation = SKAction.waitForDuration(2)
        let repeatForeverAnimation = SKAction.repeatActionForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        runAction(repeatForeverAnimation)
    }
    
    func setupBird() {
    
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = SKTextureFilteringMode.Linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = SKTextureFilteringMode.Linear
        
        let textureAnimation = SKAction.animateWithTextures([birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatActionForever(textureAnimation)
        
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: 30, y: frame.size.height * 0.7)
        bird.zPosition = 100
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        bird.physicsBody?.allowsRotation = false
        
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | itemCategory
        
        bird.runAction(flap)
        addChild(bird)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if scrollNode.speed > 0{
            bird.physicsBody?.velocity = CGVector.zero
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 13))
        }else if bird.speed == 0 {
            restart()
        }
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        // ゲームオーバーのときは何もしない
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコア用の物体と衝突した
            
            score++
            scoreLabelNode.text = "Score:\(score)" // ←追加
            
            // ベストスコア更新か確認する
            var bestScore = userDefaults.integerForKey("BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)" // ←追加
                userDefaults.setInteger(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
       
            }else if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory{
            
            print("ItemScoreUp")
            itemScore++
            itemScoreLabelNode.text = "ItemScore:\(itemScore)"
            
            let soundAction:SKAction = SKAction.playSoundFileNamed("button03a.mp3", waitForCompletion: true)
            self.runAction(soundAction)
        
            contact.bodyA.node!.removeFromParent()
            
        }else{
            // 壁か地面と衝突した
            print("GameOver")
            
            // スクロールを停止させる
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotateByAngle(CGFloat(M_PI) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.runAction(roll, completion:{
                self.bird.speed = 0
            })
        }
        
 
    }
    
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.blackColor()
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 30)
        scoreLabelNode.zPosition = 100 // 一番手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.blackColor()
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        let bestScore = userDefaults.integerForKey("BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        itemScore = 0
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.blackColor()
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        itemScoreLabelNode.zPosition = 100
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        itemScoreLabelNode.text = "ItemScore:\(itemScore)"
        self.addChild(itemScoreLabelNode)
        
        
    }


  func restart(){
   
    score = 0
    scoreLabelNode.text = String("Score:\(score)") // ←追加
    
    itemScore = 0
    itemScoreLabelNode.text = String("ItemScore:\(itemScore)")
    
    bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
    bird.physicsBody?.velocity = CGVector.zero
    bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
    bird.zRotation = 0.0
    
    wallNode.removeAllChildren()
    
    bird.speed = 1
    scrollNode.speed = 1}
}