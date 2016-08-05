/*:
 # Playground Graffiti
 
 A simple 100-line, 2-class drawing app with a share pane.
 
 When running this code in Swift Playgrounds on the iPad, the share pane is live and fully functional! Tweet your doodles to the world. In Xcode Playgrounds however, the share pane actions crash the code.
 
 This code was inspired by a number of drawing app tutorials:
 
 + <https://www.raywenderlich.com/87899/make-simple-drawing-app-uikit-swift>
 
 + <http://merowing.info/2012/04/drawing-smooth-lines-with-cocos2d-ios-inspired-by-paper/>
 
 + <http://code.tutsplus.com/tutorials/smooth-freehand-drawing-on-ios--mobile-13164>
 
 Running in Playgrounds on an iPad Air 1, I had to experiment a bit to find a solution that created a smooth curve but still performed without too much latency. I found that drawing the curve to the background image every four points was the best trade-off. Add a viewer to the path to see how this works.
 
 */

import UIKit
import PlaygroundSupport

// operator overrides allowing us to do arithmetic with `CGPoint`

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

/*:
 A subclass of UIImageView that handles the drawing
 */

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
        path.lineCapStyle = .round //by starting with a round line style, the user can draw a dot with a single tap
        path.move(to: pos)
        points.append(pos)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let pos = touches.first!.location(in: self)
        points.append(pos)
        // wait until we have 4 points of a curve, plus the first point of the next curve
        if points.count > 4 {
            // move the end of the path to be between the final control point of tis curve, and the first control point of the next curve. THis smooths the path out:
            points[3] = (points[2] + points[4]) * 0.5
            path.lineCapStyle = .butt
            path.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2]) // add a viewer to the path here
            cacheImage()
            path.removeAllPoints()
            //The next curve's startpoint is this curve's end point
            path.move(to: points[3])
            // remove first 3 points
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
        if retainImage {
            // in order to draw on top of the image, we need to draw the existing image in
            image?.draw(in: self.frame)
            // draw the path
            #colorLiteral(red: 0.95686274766922, green: 0.658823549747467, blue: 0.545098066329956, alpha: 1.0).setStroke()
            path.stroke( with: .multiply, alpha: 0.7)
        }
        // and save the image
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }
    
    func clearImage(){
        path.removeAllPoints()
        // use the cacheImage function to wipe the image
        cacheImage(retainImage: false)
        setNeedsDisplay()
    }
}

/*:
 A subclass of UIViewController which sets up the navbar and its buttons
 */

class ViewController: UIViewController {
    let mainView = SketchView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Playground Graffiti"
        view = mainView
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareSheet))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: mainView, action: #selector(mainView.clearImage))
        
    }
    
    func shareSheet(sender: UIBarButtonItem){
        // these 3 lines plug us into the full iOS ecosystem!
        let action = UIActivityViewController(activityItems: [mainView.image!], applicationActivities: nil)
        action.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(action, animated: true, completion: nil)
    }
    
}

// ViewController is wrapped inside a NavigationViewController to get the nav bar, and space for a couple of buttons
PlaygroundPage.current.liveView = UINavigationController(rootViewController: ViewController())
