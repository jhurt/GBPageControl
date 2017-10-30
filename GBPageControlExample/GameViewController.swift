//
//  GameViewController.swift
//  GBPageControlExample
//
//  Created by Jason Hurt on 12/12/15.
//  Copyright (c) 2015 Jason Hurt. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
}
