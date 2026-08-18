import SpriteKit

public class PageControl: NSObject {
    weak var parentScene: SKScene?
    
    var contentNode: SKNode
    
    var pageIndicatorNode: SKNode
    var pageIndicators: [SKShapeNode]
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    var panGestureStartPoint: CGPoint!
    var panGestureStartContentPosition: CGPoint!
    
    var numberOfPages: Int = 0
    
    public var xMargin: CGFloat = 8.0
    public var radius: CGFloat = 8.0
    public var selectedColor = UIColor(red: 108.0/255.0, green: 108.0/255.0, blue: 108.0/255.0, alpha: 1.0)
    public var notSelectedColor = UIColor(red: 208.0/255.0, green: 208.0/255.0, blue: 208.0/255.0, alpha: 1.0)
    public var yPosition: CGFloat = 30.0
    
    public init(scene: SKScene) {
        self.parentScene = scene
        
        contentNode = SKNode()
        scene.addChild(contentNode)
        
        pageIndicatorNode = SKNode()
        pageIndicators = [SKShapeNode]()
        scene.addChild(pageIndicatorNode)
    }
    
    public func addChild(_ node: SKNode) {
        contentNode.addChild(node)
    }
    
    public func enable(numberOfPages: Int) {
        self.numberOfPages = numberOfPages
        
        addIndicator()
        addPanGestureRecognizer()
    }
    
    public func getSelectedPage() -> Int {
        guard let parentScene = parentScene else { return 0 }
        return -1 * Int(floor((contentNode.position.x + parentScene.size.width/2.0) / parentScene.size.width))
    }
    
    public func willMove(from view: SKView) {
        guard let panGestureRecognizer = panGestureRecognizer else { return }
        view.removeGestureRecognizer(panGestureRecognizer)
    }
    
    public func handleTouch(touch: UITouch) -> Bool {
        guard let parentScene = parentScene else { return false }
        
        let location = touch.location(in: pageIndicatorNode)
        let touchMargin:CGFloat = xMargin / 2.0
        for i in 0..<pageIndicators.count {
            let indicator = pageIndicators[i]
            let indicatorTouchRect = CGRect(x: indicator.frame.origin.x - touchMargin,
                                            y: indicator.frame.origin.y - touchMargin,
                                            width: indicator.frame.width + touchMargin * 2.0,
                                            height: indicator.frame.height + touchMargin * 2.0)
            if indicatorTouchRect.contains(location) {
                let point = CGPoint(x: -1.0 * CGFloat(i) * parentScene.size.width,
                                    y: contentNode.position.y)
                contentNode.run(SKAction.move(to: point, duration:0.2),
                                completion: { [weak self] in
                    guard let self = self else { return }
                    self.pageStateDidChange()
                })
                return true
            }
        }
        return false
    }
    
    private func addIndicator() {
        guard let parentScene = parentScene else { return }
        
        pageIndicatorNode.removeAllChildren()
        pageIndicators.removeAll()
        
        let diameter = radius * 2.0
        let pageIndicatorWidth = diameter * CGFloat(numberOfPages) + CGFloat(numberOfPages - 1) * xMargin
        let pageIndicatorHeight = diameter
        let selectedPage = getSelectedPage()
        for i in 0..<numberOfPages{
            let pageCircle = SKShapeNode(circleOfRadius: radius)
            pageCircle.fillColor = i == selectedPage ? selectedColor : notSelectedColor
            pageCircle.strokeColor = pageCircle.fillColor
            pageCircle.position = CGPoint(x: (diameter * CGFloat(i)) + (xMargin * CGFloat(i)) + (diameter/2.0), y:0.0)
            pageIndicatorNode.addChild(pageCircle)
            pageIndicators.append(pageCircle)
        }
        
        pageIndicatorNode.position = CGPoint(x: parentScene.frame.midX - pageIndicatorWidth/2.0,
                                             y: yPosition + pageIndicatorHeight/2.0)
    }
    
    private func addPanGestureRecognizer() {
        guard let parentScene = parentScene else { return }
        guard let view = parentScene.view else { return }
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(PageControl.handlePanGesture(recognizer:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc public func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        guard let parentScene = parentScene else { return }
        
        if recognizer.state == .began {
            panGestureStartPoint = parentScene.convertPoint(fromView: recognizer.location(in: recognizer.view))
            panGestureStartContentPosition = contentNode.position
        }
        else if recognizer.state == .changed && panGestureStartPoint != nil {
            let touchPoint = parentScene.convertPoint(fromView: recognizer.location(in: recognizer.view))
            let velocity = recognizer.velocity(in: recognizer.view!)
            let slideMultiplier = abs(velocity.x) / 35000
            let newPosition = boundContentNode(point: CGPoint(x: contentNode.position.x - (panGestureStartPoint.x - touchPoint.x) + (velocity.x * slideMultiplier),
                                                              y: contentNode.position.y))
            if abs(newPosition.x - panGestureStartContentPosition.x) < parentScene.size.width * 1.4 {
                contentNode.position = newPosition
            }
            panGestureStartPoint = touchPoint
        }
        else if recognizer.state == .ended {
            panGestureStartPoint = nil
            panGestureStartContentPosition = nil
            let page = getSelectedPage()
            let point = CGPoint(x: -1.0 * CGFloat(page) * parentScene.size.width,
                                y: contentNode.position.y)
            let moveTo = SKAction.move(to: point, duration: 0.2)
            contentNode.run(moveTo)
            pageStateDidChange()
        }
    }
    
    private func pageStateDidChange() {
        let selectedPage = getSelectedPage()
        for i in 0..<pageIndicators.count {
            let circle = pageIndicators[i]
            circle.fillColor = i == selectedPage ? selectedColor : notSelectedColor
            circle.strokeColor = circle.fillColor
        }
    }
    
    private func boundContentNode(point: CGPoint) -> CGPoint {
        if point.x > 0.0 {
            return CGPoint(x: 0.0, y: point.y)
        }
        
        let lowerBound = -1.0 * CGFloat(numberOfPages - 1) * parentScene!.size.width
        if point.x < lowerBound {
            return CGPoint(x:lowerBound, y:point.y)
        }
        
        return point
    }
}
