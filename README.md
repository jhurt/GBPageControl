# GBPageControl

A page control for use in [SpriteKit](https://developer.apple.com/spritekit/) games written in Swift.

This control is used in:
- [Gridblock](https://apps.apple.com/us/app/gridblock/id1025368240)
- [Mad Wordz](https://apps.apple.com/us/app/mad-wordz/id6740180922)
- [Boltage](https://apps.apple.com/us/app/boltage/id1287442521)
- [Gravblock](https://apps.apple.com/us/app/gravblock/id1074030694)

|             Demo        	  											      |
|-----------------------------------------------------------------------------|
|![Demo](https://pub-39f4c17997e744b687ee111e7494fcf3.r2.dev/GBPageControlExample.gif)|


## Motivation

Using a UIPageControl in a SpriteKit game is complex.
GBPageControl provides a SpriteKit based page control for you to use in your games with less complexity.

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
    for i in 0..<4 {
        let node = SKShapeNode(circleOfRadius: 10)
        node.strokeColor = .blue
        let x = size.width / 2.0 + size.width * CGFloat(i)
        let y = size.height / 2.0
        node.position = CGPoint(x: x, y: y)
        pageControl.addChild(node)
    }
}
```

* Call `pageControl.handleTouch` in `touchesBegan`:
```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    if pageControl.handleTouch(touch: touch) {
        // no op, page control handled it
    }
    else {
        // handle touch in your game scene
    }
}
```

* Call `pageControl.willMoveFromView` in `willMoveFromView`:
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
