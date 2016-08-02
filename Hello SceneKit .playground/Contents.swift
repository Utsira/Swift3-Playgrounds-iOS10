
import SceneKit
import SpriteKit
import PlaygroundSupport
let pi2 = Float(M_PI_2)

let scene = SCNScene()
let hello = SCNText(string: "Hello\nworld!", extrusionDepth: 9)
hello.chamferRadius = 0.5
hello.flatness = 0.05
hello.font = UIFont(name: "Superclarendon-Black", size: 12)
let helloNode = SCNNode(geometry: hello)
var min = SCNVector3Zero
var max = SCNVector3Zero
helloNode.__getBoundingBoxMin(&min, max: &max)
print(min,max)
 helloNode.position = SCNVector3((max.x - min.x) * -0.5, (max.y - min.y) * -0.5, 0) 
//helloNode.scale = SCNVector3(0.2, 0.2, 0.2)
scene.rootNode.addChildNode(helloNode)


let cube = SCNNode(geometry: SCNBox(width: 30, height: 2, length: 8, chamferRadius: 0.5))
cube.position = SCNVector3(-4, 3, 0)
scene.rootNode.addChildNode(cube)
let mat = SCNMaterial()

 mat.lightingModelName = SCNLightingModelPhysicallyBased
mat.roughness.contents = UIColor.lightGray()
mat.metalness.contents = SKTexture(noiseWithSmoothness: 0.8, size: CGSize(width: 500, height: 500), grayscale: true).cgImage()  //UIColor.darkGray()
    
 mat.diffuse.contents = #colorLiteral(red: 1.0, green: 0.498039215803146, blue: 0.756862759590149, alpha: 1.0)  
cube.geometry?.materials = [mat] 
hello.materials = [mat]

 let light = SCNLight()
light.type = SCNLightTypeOmni
 let lightNode = SCNNode()
 lightNode.light = light
 lightNode.position = SCNVector3(8,12,15)
 scene.rootNode.addChildNode(lightNode)
 
let view = SCNView() 
view.allowsCameraControl = true
view.autoenablesDefaultLighting = true
view.showsStatistics = true
view.scene = scene
view.backgroundColor = #colorLiteral(red: 0.0588235296308994, green: 0.180392161011696, blue: 0.24705882370472, alpha: 1.0)
PlaygroundPage.current.liveView = view



