import SpriteKit

public class PageControl: NSObject {
    weak var parentScene:SKScene?
    
    var contentNode:SKNode!
    
    var panGestureRecognizer:UIPanGestureRecognizer!
    var panGestureStartPoint:CGPoint!
    var panGestureStartContentPosition:CGPoint!
    
    var pageIndicatorNode:SKNode!
    var pageIndicators:[SKShapeNode]!
    
    var numberOfPages:Int!
    
    public var xMargin:CGFloat = 8.0
    public var radius:CGFloat = 8.0
    public var selectedColor = UIColor(red: 208.0/255.0, green: 208.0/255.0, blue: 208.0/255.0, alpha: 1.0)
    public var notSelectedColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1.0)
    public var yPosition:CGFloat = 30.0
    
    public init(scene:SKScene) {
        self.parentScene = scene
        contentNode = SKNode()
        parentScene?.addChild(contentNode)
    }
    
    public func addChild(_ node:SKNode) {
        contentNode!.addChild(node)
    }
    
    public func enable(numberOfPages:Int) {
        self.numberOfPages = numberOfPages
        
        addIndicator()
        addPanGestureRecognizer()
    }
    
    public func getSelectedPage() -> Int {
        return -1 * Int(floor((contentNode.position.x + parentScene!.size.width/2.0) / parentScene!.size.width))
    }
    
    public func willMove(from view: SKView) {
        if panGestureRecognizer != nil {
            view.removeGestureRecognizer(panGestureRecognizer)
        }
    }
    
    public func handleTouch(touch: UITouch) -> Bool {
        let location = touch.location(in: pageIndicatorNode!)
        let touchMargin:CGFloat = xMargin / 2.0
        for i in 0...pageIndicators!.count - 1 {
            let indicator = pageIndicators![i]
            let indicatorTouchRect = CGRect(x:indicator.frame.origin.x - touchMargin,
                                            y:indicator.frame.origin.y - touchMargin,
                                            width:indicator.frame.width + touchMargin * 2.0,
                                            height:indicator.frame.height + touchMargin * 2.0)
            if indicatorTouchRect.contains(location) {
                let point = CGPoint(x:-1.0 * CGFloat(i) * parentScene!.size.width,
                                    y:contentNode!.position.y)
                contentNode!.run(SKAction.move(to: point, duration:0.2),
                                 completion: { [weak self] in
                                    self?.pageStateDidChange()
                                })
                return true
            }
        }
        return false
    }
    
    private func addIndicator() {
        pageIndicatorNode = SKNode()
        pageIndicators = [SKShapeNode]()
        let unusedCircleNode = SKShapeNode(circleOfRadius: radius)
        let pageIndicatorWidth = unusedCircleNode.frame.width * CGFloat(numberOfPages) + CGFloat(numberOfPages - 1) * xMargin
        let pageIndicatorHeight = unusedCircleNode.frame.height
        let selectedPage = getSelectedPage()
        for i in 0...numberOfPages - 1 {
            let pageCircle = SKShapeNode(circleOfRadius: radius)
            if i == selectedPage {
                pageCircle.fillColor = selectedColor
            }
            else {
                pageCircle.fillColor = notSelectedColor
            }
            pageCircle.strokeColor = pageCircle.fillColor
            pageCircle.position = CGPoint(x: (pageCircle.frame.size.width * CGFloat(i)) + (xMargin * CGFloat(i)) + (pageCircle.frame.size.width/2.0), y:0.0)
            pageIndicatorNode.addChild(pageCircle)
            pageIndicators.append(pageCircle)
        }
        pageIndicatorNode.position = CGPoint(x:parentScene!.frame.midX - pageIndicatorWidth/2.0, y:yPosition + pageIndicatorHeight/2.0)
        parentScene?.addChild(pageIndicatorNode)
    }
    
    private func addPanGestureRecognizer() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PageControl.handlePanGesture(recognizer:)))
        parentScene?.view?.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc public func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.began {
            panGestureStartPoint = parentScene?.convertPoint(fromView: recognizer.location(in: recognizer.view))
            panGestureStartContentPosition = contentNode.position
        }
        else if recognizer.state == UIGestureRecognizerState.changed {
            if panGestureStartPoint != nil {
                let touchPoint = parentScene?.convertPoint(fromView: recognizer.location(in: recognizer.view))
                let velocity = recognizer.velocity(in: recognizer.view!)
                let slideMultiplier = abs(velocity.x) / 35000
                let newPosition = boundContentNode(point: CGPoint(x: contentNode.position.x - (panGestureStartPoint.x - touchPoint!.x) + (velocity.x * slideMultiplier),
                    y: contentNode!.position.y))
                if abs(newPosition.x - panGestureStartContentPosition.x) < parentScene!.size.width * 1.4 {
                    contentNode!.position = newPosition
                }
                panGestureStartPoint = touchPoint
            }
        }
        else if recognizer.state == UIGestureRecognizerState.ended {
            panGestureStartPoint = nil
            panGestureStartContentPosition = nil
            let page = getSelectedPage()
            let point = CGPoint(x:-1.0 * CGFloat(page) * parentScene!.size.width, y:contentNode!.position.y)
            let moveTo = SKAction.move(to: point, duration:0.2)
            contentNode!.run(moveTo)
            pageStateDidChange()
        }
    }
    
    private func pageStateDidChange() {
        let selectedPage = getSelectedPage()
        for i in 0...pageIndicators!.count - 1 {
            let circle = pageIndicators![i]
            if i == selectedPage {
                circle.fillColor = selectedColor
            }
            else {
                circle.fillColor = notSelectedColor
            }
            circle.strokeColor = circle.fillColor
        }
    }
    
    private func boundContentNode(point:CGPoint) -> CGPoint {
        if point.x > 0.0 {
            return CGPoint(x:0.0, y:point.y)
        }
        let lowerBound = -1.0 * CGFloat(numberOfPages - 1) * parentScene!.size.width
        if point.x < lowerBound {
            return CGPoint(x:lowerBound, y:point.y)
        }
        return point
    }
}
