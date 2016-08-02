
import SpriteKit
import PlaygroundSupport

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += ( left: inout CGPoint, right: CGPoint) {
    left = left + right
}

let degree = CGFloat(M_PI_2) / 90

class GameScene: SKScene {
    var selectedNode: SKNode?
    var shakeAction: SKAction?
    
    override init(size: CGSize) {
        
        let text = SKLabelNode(text: "Drag me 🤖")
        text.fontColor = #colorLiteral(red: 0.854901969432831, green: 0.250980406999588, blue: 0.47843137383461, alpha: 1.0)
        text.position = CGPoint(x: size.width / 2, y: size.height/2)
        let sprite = SKSpriteNode(color: #colorLiteral(red: 0.854901969432831, green: 0.250980406999588, blue: 0.47843137383461, alpha: 1.0), size: CGSize(width: 30, height: 30))
        sprite.position = CGPoint(x: 100, y: 100)
        super.init(size: size)
        makeShakeAction()
        addChild(text)
        addChild(sprite)
    }
    
    func makeShakeAction(){
        var sequence = [SKAction]()
        for _ in 0..<10 {
            let shake = CGFloat(drand48() * 2) + 1
            let shake2 = CGFloat(drand48() * 2) + 1
            let duration = 0.08 // + (drand48() * 0.14)
            let antiClockwise = SKAction.group([
                SKAction.rotate(byAngle: degree * shake, duration: duration),
                SKAction.moveBy(x: shake, y: shake2, duration: duration)
            ])
            let clockWise = SKAction.group([
                SKAction.rotate(byAngle: degree * shake * -2, duration: duration * 2),
                SKAction.moveBy(x: shake * -2, y: shake2 * -2, duration: duration * 2)
            ])
            sequence += [antiClockwise, clockWise, antiClockwise]
        }
        
        
        shakeAction = SKAction.repeatForever(SKAction.sequence(sequence))
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let positionInScene = touch?.location(in: self) else {return}
        
        if let touchedNode = self.nodes(at: positionInScene).first {
            selectedNode = touchedNode
            selectedNode?.run(shakeAction!, withKey: "shake")
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let translationInScene = touch.location(in: self) - touch.previousLocation(in: self)
        if let selected = selectedNode {
            selected.position += translationInScene
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if selectedNode != nil {
            selectedNode?.removeAction(forKey: "shake")
            selectedNode = nil
        }
    }
}


let frame = CGRect(x: 0, y: 0, width: 400, height: 600)
let view = SKView(frame: frame) //GameView(frame: frame)
let scene = GameScene(size: frame.size)
view.presentScene(scene)
PlaygroundPage.current.liveView = view
