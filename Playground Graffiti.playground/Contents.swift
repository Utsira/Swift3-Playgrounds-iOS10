//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

class SketchView: UIImageView {
    var path = UIBezierPath()
    var points = [CGPoint]()
    
    init(){
        super.init(frame: CGRect.zero) 
        path.lineWidth = 5
        isUserInteractionEnabled = true
        contentMode = .redraw
        backgroundColor = #colorLiteral(red: 0.062745101749897, green: 0.0, blue: 0.192156866192818, alpha: 1.0)
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let pos = touches.first!.location(in: self)
        path.lineCapStyle = .round
        path.move(to: pos)
        points.append(pos)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let pos = touches.first!.location(in: self)
        points.append(pos)
        if points.count > 4 {
            points[3] = (points[2] + points[4]) * 0.5
            path.lineCapStyle = .butt
            path.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
            cacheImage()
            path.removeAllPoints()
            path.move(to: points[3])
            points.removeFirst(3)
            setNeedsDisplay()
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        path.addLine(to: touches.first!.location(in: self))
        cacheImage()
        path.removeAllPoints()
        points.removeAll()
        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func cacheImage(retainImage: Bool = true){
        UIGraphicsBeginImageContext(self.frame.size)
        let context = UIGraphicsGetCurrentContext()!
        if retainImage {
            image?.draw(in: self.frame)
            #colorLiteral(red: 0.95686274766922, green: 0.658823549747467, blue: 0.545098066329956, alpha: 1.0).setStroke()
            path.stroke( with: .multiply, alpha: 0.7)
        }
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
    }
    
    func clearImage(){
        path.removeAllPoints()
        cacheImage(retainImage: false)
        setNeedsDisplay()
    }
}

class ViewController: UIViewController {
    let mainView = SketchView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Playground Graffiti"
        view = mainView
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareSheet ))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: mainView, action: #selector(mainView.clearImage))
            /*
        mainView.isUserInteractionEnabled = true
        
        mainView.contentMode = .redraw
 mainView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
 */
    }
    
    func shareSheet(sender: UIBarButtonItem){
        let action = UIActivityViewController(activityItems: [mainView.image!], applicationActivities: nil)
        action.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(action, animated: true, completion: nil)
    }
    
}

PlaygroundPage.current.liveView = UINavigationController(rootViewController: ViewController())
