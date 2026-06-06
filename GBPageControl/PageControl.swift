import SpriteKit

public class PageControl: NSObject {
    weak var parentScene:SKScene?
    
    var contentNode:SKNode = SKNode()
    
    var panGestureRecognizer:UIPanGestureRecognizer?
    var panGestureStartPoint:CGPoint?
    var panGestureStartContentPosition:CGPoint?
    
    var pageIndicatorNode:SKNode?
    var pageIndicators:[SKShapeNode] = []
    
    var numberOfPages:Int = 0
    
    public var xMargin:CGFloat = 8.0
    public var radius:CGFloat = 8.0
    public var selectedColor = UIColor(red: 208.0/255.0, green: 208.0/255.0, blue: 208.0/255.0, alpha: 1.0)
    public var notSelectedColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1.0)
    public var yPosition:CGFloat = 30.0
    
    public init(scene:SKScene) {
        self.parentScene = scene
        super.init()
        parentScene?.addChild(contentNode)
    }
    
    public func addChild(_ node:SKNode) {
        contentNode.addChild(node)
    }
    
    public func enable(numberOfPages:Int) {
        self.numberOfPages = numberOfPages
        
        addIndicator()
        addPanGestureRecognizer()
    }
    
    public func getSelectedPage() -> Int {
        guard let parentScene = parentScene else { return 0 }
        return -1 * Int(floor((contentNode.position.x + parentScene.size.width/2.0) / parentScene.size.width))
    }
    
    public func willMove(from view: SKView) {
        if let panGestureRecognizer = panGestureRecognizer {
            view.removeGestureRecognizer(panGestureRecognizer)
        }
    }
    
    public func handleTouch(touch: UITouch) -> Bool {
        guard let pageIndicatorNode = pageIndicatorNode, let parentScene = parentScene else { return false }
        let location = touch.location(in: pageIndicatorNode)
        let touchMargin:CGFloat = xMargin / 2.0
        for i in 0..<pageIndicators.count {
            let indicator = pageIndicators[i]
            let indicatorTouchRect = CGRect(x:indicator.frame.origin.x - touchMargin,
                                            y:indicator.frame.origin.y - touchMargin,
                                            width:indicator.frame.width + touchMargin * 2.0,
                                            height:indicator.frame.height + touchMargin * 2.0)
            if indicatorTouchRect.contains(location) {
                let point = CGPoint(x:-1.0 * CGFloat(i) * parentScene.size.width,
                                    y:contentNode.position.y)
                contentNode.run(SKAction.move(to: point, duration:0.2),
                                 completion: { [weak self] in
                                    self?.pageStateDidChange()
                                })
                return true
            }
        }
        return false
    }
    
    private func addIndicator() {
        guard let parentScene = parentScene else { return }
        let newPageIndicatorNode = SKNode()
        pageIndicatorNode = newPageIndicatorNode
        pageIndicators = [SKShapeNode]()
        let unusedCircleNode = SKShapeNode(circleOfRadius: radius)
        let pageIndicatorWidth = unusedCircleNode.frame.width * CGFloat(numberOfPages) + CGFloat(numberOfPages - 1) * xMargin
        let pageIndicatorHeight = unusedCircleNode.frame.height
        let selectedPage = getSelectedPage()
        for i in 0..<numberOfPages {
            let pageCircle = SKShapeNode(circleOfRadius: radius)
            if i == selectedPage {
                pageCircle.fillColor = selectedColor
            }
            else {
                pageCircle.fillColor = notSelectedColor
            }
            pageCircle.strokeColor = pageCircle.fillColor
            pageCircle.position = CGPoint(x: (pageCircle.frame.size.width * CGFloat(i)) + (xMargin * CGFloat(i)) + (pageCircle.frame.size.width/2.0), y:0.0)
            newPageIndicatorNode.addChild(pageCircle)
            pageIndicators.append(pageCircle)
        }
        newPageIndicatorNode.position = CGPoint(x:parentScene.frame.midX - pageIndicatorWidth/2.0, y:yPosition + pageIndicatorHeight/2.0)
        parentScene.addChild(newPageIndicatorNode)
    }
    
    private func addPanGestureRecognizer() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(PageControl.handlePanGesture(recognizer:)))
        panGestureRecognizer = recognizer
        if let parentScene = parentScene, let view = parentScene.view {
            view.addGestureRecognizer(recognizer)
        }
    }
    
    @objc public func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        guard let parentScene = parentScene, let view = recognizer.view else { return }

        if recognizer.state == UIGestureRecognizerState.began {
            panGestureStartPoint = parentScene.convertPoint(fromView: recognizer.location(in: view))
            panGestureStartContentPosition = contentNode.position
        }
        else if recognizer.state == UIGestureRecognizerState.changed {
            if let panGestureStartPoint = panGestureStartPoint, let panGestureStartContentPosition = panGestureStartContentPosition {
                let touchPoint = parentScene.convertPoint(fromView: recognizer.location(in: view))
                let velocity = recognizer.velocity(in: view)
                let slideMultiplier = abs(velocity.x) / 35000
                let newPosition = boundContentNode(point: CGPoint(x: contentNode.position.x - (panGestureStartPoint.x - touchPoint.x) + (velocity.x * slideMultiplier),
                    y: contentNode.position.y))
                if abs(newPosition.x - panGestureStartContentPosition.x) < parentScene.size.width * 1.4 {
                    contentNode.position = newPosition
                }
                self.panGestureStartPoint = touchPoint
            }
        }
        else if recognizer.state == UIGestureRecognizerState.ended {
            panGestureStartPoint = nil
            panGestureStartContentPosition = nil
            let page = getSelectedPage()
            let point = CGPoint(x:-1.0 * CGFloat(page) * parentScene.size.width, y:contentNode.position.y)
            let moveTo = SKAction.move(to: point, duration:0.2)
            contentNode.run(moveTo)
            pageStateDidChange()
        }
    }
    
    private func pageStateDidChange() {
        let selectedPage = getSelectedPage()
        for i in 0..<pageIndicators.count {
            let circle = pageIndicators[i]
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
        guard let parentScene = parentScene else { return point }
        let lowerBound = -1.0 * CGFloat(numberOfPages - 1) * parentScene.size.width
        if point.x < lowerBound {
            return CGPoint(x:lowerBound, y:point.y)
        }
        return point
    }
}
