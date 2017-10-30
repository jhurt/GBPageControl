//
//  GameScene.swift
//  GBPageControlExample
//
//  Created by Jason Hurt on 12/12/15.
//  Copyright (c) 2015 Jason Hurt. All rights reserved.
//

import SpriteKit
import GBPageControl

var pageControl:PageControl!

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        addBackground()
        pageControl = PageControl(scene: self)
        addContent()
        pageControl.enable(numberOfPages: 4)
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        
        pageControl.willMove(from: view)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if pageControl.handleTouch(touch: touch) {
            //no op
        }
        else {
            //handle touch
        }
    }
    
    func addBackground() {
        let background = SKShapeNode(rect: CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height))
        background.fillColor = .white
        background.strokeColor = background.fillColor
        self.addChild(background)
    }
    
    private func addContent() {
        for i in 0 ..< 4 {
            let sprite = SKSpriteNode(imageNamed: String(format: "ship%d", i + 1))
            let x = self.size.width / 2.0 + self.size.width * CGFloat(i)
            let y = self.size.height / 2.0
            sprite.position = CGPoint(x:x, y:y)
            pageControl.addChild(sprite)
        }
    }
}
