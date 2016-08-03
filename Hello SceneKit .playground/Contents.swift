/*:
 # Hello SceneKit
 
 A quick demo of SceneKit, including the new physics-based rendering.
 
 Requires either:
 
 + iPad Playgrounds iOS 10 beta 4+ 
 + or Xcode beta 8
 
 NB when running in Xcode, you need to explicitly set the size of the view (see lines 104-105). Also PBR (physics based rendering) material properties don't show up (because Xcode iOS Simulator isn't backed by Metal?)
 
 */

import SceneKit
import SpriteKit // we're just using SpriteKit to create a quick noise texture
import PlaygroundSupport // needed to create the live view

let scene = SCNScene()
// create the text geometry
let hello = SCNText(string: "Hello\nworld!", extrusionDepth: 9)
hello.chamferRadius = 0.5
hello.flatness = 0.05
hello.font = UIFont(name: "Superclarendon-Black", size: 12)
let helloNode = SCNNode(geometry: hello)

/*: 
 ## Positioning the text geometry
 
 SCNText geometries have their origin in the lower-left corner.
 We want to move the pivot point of the text geometry to its centre.
 
 First, we get the bounding box of the geometry, expressed as two SCNVector3 vectors, describing the distance from the pivot point to the lower-left-back corner and upper-right-front corner respectively
 */
var scnMin = SCNVector3Zero // this will hold distance from pivot to lower-left-back...
var scnMax = SCNVector3Zero // distance from pivot to upper-right-front
helloNode.__getBoundingBoxMin(&scnMin, max: &scnMax) // pass min and max as in-out parameters. in beta 4 getBoundingBox now has 2 underscores in its method name?

/*:
 SCNVector3 vectors do not come with `+ - * /` operators as standard. A common approach in Swift is to write SCNvector3 operators. Instead, here we'll bridge to simd, which does handle `+ - *` operators (though not scalar `/` ). simd is imported by SceneKit and SpriteKit.
 
 We need to move the pivot by half the total length - the current position of the pivot.
 
 ```
 halfTotalLength = (min + max) * 0.5 
 // nb scalar / not supported
 pivotPosition = min
 
 translation = (( min + max) * 0.5 ) - min 
 == (max - min) * 0.5
 ```

 */
let min = SCNVector3ToFloat3(scnMin)
let max = SCNVector3ToFloat3(scnMax)
let translation = (max - min) * 0.5
helloNode.pivot = SCNMatrix4MakeTranslation(translation.x, translation.y, translation.z)
 
//helloNode.scale = SCNVector3(0.2, 0.2, 0.2)
scene.rootNode.addChildNode(helloNode)

// The cube will be an underscore for the "Hello"
let cube = SCNNode(geometry: SCNBox(width: 30, height: 2, length: 8, chamferRadius: 0.5))
cube.position = SCNVector3(-4, 3, 0)
scene.rootNode.addChildNode(cube)

/*: 
 ## Add materials
 
 Set up two materials with physics-based rendering (PBR). Note that the PBR properties won't show up when running the playground in Xcode (I think because PBR requires Metal, and the inline iOS Simulator is backed by OpenGL, not Metal). If you want to experiment with PBR on the Mac, you need to have MacOS Sierra installed, and set up a new Playground as a MacOS Playground and port this code over.
 */
let dullMat = SCNMaterial()
dullMat.diffuse.contents = #colorLiteral(red: 0.7602152824, green: 0.7601925135, blue: 0.7602053881, alpha: 1)
let metalMat = SCNMaterial()
metalMat.diffuse.contents = #colorLiteral(red: 1.0, green: 0.498039215803146, blue: 0.756862759590149, alpha: 1.0)

dullMat.lightingModelName = SCNLightingModelPhysicallyBased
dullMat.roughness.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
dullMat.metalness.contents = #colorLiteral(red: 0.1956433058, green: 0.2113749981, blue: 0.2356699705, alpha: 1)

metalMat.lightingModelName = SCNLightingModelPhysicallyBased
metalMat.roughness.contents = #colorLiteral(red: 0.5296475887, green: 0.5296317339, blue: 0.5296407342, alpha: 1)
//add some noise to the metal texture using SpriteKit. You could really go to town with the new GameplayKit noise features
metalMat.metalness.contents = SKTexture(noiseWithSmoothness: 0.8, size: CGSize(width: 500, height: 500), grayscale: true).cgImage()

cube.geometry?.materials = [dullMat]
// SCNText geometries have up to 5 materials: front, back, sides, front champfer, back champfer
// Apply the metallic texture to only the front face and front champfers:
hello.materials = [metalMat, dullMat, dullMat, metalMat, dullMat]

let light = SCNLight()
light.type = SCNLightTypeOmni
let lightNode = SCNNode()
lightNode.light = light
lightNode.position = SCNVector3(8,12,15)
scene.rootNode.addChildNode(lightNode)

/*:
 ## Set up the live view
 
 In Xcode on the Mac, you have to supply a size for the view. On iPad, this isn't necessary
 */

let view = SCNView() //iPad version
//let view = SCNView(frame: CGRect(x: 0, y: 0, width: 400, height: 600)) //Xcode version
view.allowsCameraControl = true
view.autoenablesDefaultLighting = true
view.showsStatistics = true
view.scene = scene
view.backgroundColor = #colorLiteral(red: 0.0588235296308994, green: 0.180392161011696, blue: 0.24705882370472, alpha: 1.0)
PlaygroundPage.current.liveView = view



