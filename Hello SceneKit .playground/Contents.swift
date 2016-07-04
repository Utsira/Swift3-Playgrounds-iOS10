
import SceneKit
import PlaygroundSupport
let pi2 = Float(M_PI_2)

let view = SCNView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
view.allowsCameraControl = true
view.autoenablesDefaultLighting = true
let scene = SCNScene()
view.scene = scene
PlaygroundPage.current.liveView = view

let hello = SCNText(string: "Hello\nworld!", extrusionDepth: 3)
hello.chamferRadius = 0.2
//hello.flatness = 0.4
//hello.font = UIFont(name: "Damascus Bold", size: 8)
let helloNode = SCNNode(geometry: hello)
var min = SCNVector3Zero
var max = SCNVector3Zero
helloNode.getBoundingBoxMin(&min, max: &max)
print(min,max)
// helloNode.position = SCNVector3Zero //(0, 0, 0) //SCNVector3(max.x * -0.5, max.y * -0.5, 0)
//helloNode.scale = SCNVector3(0.2, 0.2, 0.2)
scene.rootNode.addChildNode(helloNode)

let camera = SCNNode()
camera.camera = SCNCamera()
camera.position = SCNVector3(16,12,40)

scene.rootNode.addChildNode(camera)

/*
 let torus = SCNNode(geometry: SCNTorus(ringRadius: 5, pipeRadius: 2))
 torus.eulerAngles = SCNVector3(pi2,0,0)
 scene.rootNode.addChildNode(torus)
 */
/*let light = SCNLight()
 light.type = SCNLightTypeOmni
 let lightNode = SCNNode()
 lightNode.light = light
 lightNode.position = SCNVector3(2,1,1)
 scene.rootNode.addChildNode(lightNode)
 */



