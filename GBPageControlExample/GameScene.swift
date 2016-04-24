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
    override func didMoveToView(view: SKView) {
        addBackground()
        pageControl = PageControl(scene: self)
        addContent()
        pageControl.enable(4)
    }
    
    override func willMoveFromView(view: SKView) {
        pageControl.willMoveFromView(view)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if pageControl.handleTouch(touch) {
                //no op
            }
            else {
                //handle touch
            }
        }
    }
    
    func addBackground() {
        let background = SKShapeNode(rect: CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height))
        background.fillColor = UIColor.whiteColor()
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
