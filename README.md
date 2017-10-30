# GBPageControl

A page control for use in [SpriteKit] (https://developer.apple.com/spritekit/) games written in Swift.
This control is used in [Gridblock] (https://itunes.apple.com/us/app/gridblock/id1025368240?ls=1&mt=8) and [Gridblock Gravity] (https://itunes.apple.com/us/app/gridblock-gravity/id1074030694?ls=1&mt=8) available in the App Store.

|             Demo        	  											      |
|-----------------------------------------------------------------------------|
|![Demo](https://s3-us-west-1.amazonaws.com/gb-page-control/GBPageControl.gif)|



## Motivation

Using a UIPageControl in a SpriteKit game is overly complex.
GBPageControl provides a SpriteKit based page control for you to use in your games.

## Getting Started

* Add the GBPageControl framework to your project.

* Declare a PageControl in your SKScene:
```swift
import GBPageControl

var pageControl:PageControl!
```

* Add the page control to the scene. Add any content that will be paged directly to the pageControl:
```swift
override func didMove(to view: SKView) {
    super.didMove(to: view)

    pageControl = PageControl(scene: self)
    addContent()
    pageControl.enable(numberOfPages: 4)
}

private func addContent() {
    for var i = 0; i < 4; i++ {
        let node = SKShapeNode(circleOfRadius: 10)
        node.strokeColor = .blue
        let x = self.size.width / 2.0 + self.size.width * CGFloat(i)
        let y = self.size.height / 2.0
        node.position = CGPoint(x:x, y:y)
        pageControl.addChild(node)
    }
}
```
* Make sure to call pageControl.handleTouch in touchesBegan:
```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first!
    if pageControl.handleTouch(touch: touch) {
        //no op
    }
    else {
        //handle touch
    }
}
```
* Don't forget to call pageControl.willMoveFromView in willMoveFromView:
```swift
override func willMove(from view: SKView) {
    super.willMove(from: view)

    pageControl.willMove(from: view)
}
```

## Customizable Properties

* xMargin - the margin between the page indicators

* radius - the radius of the page indicators

* selectedColor - the color of the currently selected page indicator

* notSelectedColor - the color of the unselected page indicator(s)

* yPosition - how far from the bottom of the screen the page indicators are displayed

## Example

See GBPageControlExample for a working example.

## License
This software is Open Source under the BSD license, see LICENSE.txt for details.
