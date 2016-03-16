//
//  ViewController.swift
//  FlapyBird
//
//  Created by aga yosuke on 2016/03/09.
//  Copyright © 2016年 yosuke.aga. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ////SKViewの上にSKSceneがくる。詳しくは2.1
        /// SKViewに型を変換する ViewControllerに一つあるUIViewのようなもの
        let skView = self.view as! SKView
        
        skView.showsFPS = true
        
        skView.showsNodeCount = true
        
        
        let scene = GameScene(size:skView.frame.size)
        
        //SKSceneクラスを継承したGameSceneをSKViewに表示
        skView.presentScene(scene)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
        
    }

}

