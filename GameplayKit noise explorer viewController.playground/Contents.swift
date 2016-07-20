/*:
 # GameplayKit Noise Explorer
 
 ## A UIKit playground interactions demo
 
 ### Requirements
 
 This is a Swift 3 Playground that runs on either:
 
 + An iPad running iOS 10
 + A Mac running Xcode 8 (runs on either OS X El Capitan or MacOS Sierra as it runs in the iOS Simulator within Xcode Playgrounds)
 
 ### UIKit in Playgrounds
 
 Since Xcode 7.3 (and now, with the Swift Playgrounds App on the iPad in iOS 10), Swift Playgrounds have been able to receive user interactions. This playground handles touch events and gestures with a subclass of UIViewController.
 
 ### Noise Generation with GameplayKit in iOS 10
 
 In iOS 10 GameplayKit gains a series of noise generation classes. This **Noise Explorer** playground allows you to experiment with different settings for the 3 Perlin-derived noise classes, Perlin, Billow, and Ridged (nb GameplayKit also includes other types of noise, not featured here, such as Voronoi).
 
 ### Instructions for Noise Explorer
 
 + Choose a noise generator and experiment with the settings. Slider settings don't have an affect on the image until you release the slider.
 
 + Pan around the noise image with one finger (translating X and Z).
 
 + (iOS only) Pan vertically with 2 fingers to animate the noise by moving "through" it (translating Y).
 
 + Tip: The more octaves you add, the lower you'll need to set the frequency to be able to see the extra detail.
 
 + This playground just scratches the surface of GKNoise, there are many more options for manipulating the noise field, such as adding turbulence, transforming it in 3D space, applying various remapping effects, combining noise fields, and so on.
 */

import UIKit
import GameplayKit
import SpriteKit // needed to get an image from GKNoise
import PlaygroundSupport

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

//: The `NoiseGenerator` class handles the stages of the noise workflow
//:
//: GKNoiseSource → GKNoise → GKNoiseMap → SKTexture → CGImage
//:
//: It adds protocols to the various subclasses of GKNoiseSource to indicate what parameters they have without having to cast or use generics

protocol HasFreqency { var frequency: Double {get set} }
protocol HasLacunarity { var lacunarity: Double {get set} }
protocol HasOctaveCount { var octaveCount: Int { get set } }
typealias PerlinDerivedNoise = protocol<HasFreqency, HasLacunarity, HasOctaveCount>
protocol HasPersistence { var persistence: Double { get set } }
extension GKPerlinNoiseSource: PerlinDerivedNoise, HasPersistence {}
extension GKBillowNoiseSource: PerlinDerivedNoise, HasPersistence {}
extension GKRidgedNoiseSource: PerlinDerivedNoise {} //ridged noise lacks a persistence parameter

class NoiseGenerator{
    
    var frequency: Double {
        get { return noiseSource.frequency }
        set { noiseSource.frequency = newValue}
    }
    var lacunarity: Double {
        get { return noiseSource.lacunarity }
        set { noiseSource.lacunarity = newValue }
    }
    var octaveCount: Int {
        get { return noiseSource.octaveCount }
        set { noiseSource.octaveCount = newValue }
    }
    var persistence: Double { //we have to cast here, as ridged noise lacks persistence
        get {
            guard let source = noiseSource as? HasPersistence else {return 0}
            return source.persistence
        }
        set {
            guard var source = noiseSource as? HasPersistence else {return}
            source.persistence = newValue
        }
    }
    
    private var noiseSource: PerlinDerivedNoise 
    private var noise: GKNoise?
    private var noiseMap: GKNoiseMap?
    
    private let size = vector_double2(600, 600)
    private var translation = vector_double3(0,0,0)
    
    init(_ source: PerlinDerivedNoise) {
        noiseSource = source
    }
    
    func panImage(delta: vector_double3){
        translation += delta //store the cumulative translation so that when the noise is re-generated, the view remains consistent
        noise?.move(by: delta)
    }
    
    func update() {
        noise = GKNoise(noiseSource: noiseSource as! GKNoiseSource, gradientColors: [-1: #colorLiteral(red: 0.6823074818, green: 0.08504396677, blue: 0.06545677781, alpha: 1), -0.75: #colorLiteral(red: 0.9346159697, green: 0.6284804344, blue: 0.1077284366, alpha: 1), -0.5: #colorLiteral(red: 0.9672742486, green: 0.8225458264, blue: 0.4772382379, alpha: 1), -0.25: #colorLiteral(red: 0.4028071761, green: 0.7315050364, blue: 0.2071235478, alpha: 1), 0: #colorLiteral(red: 0.1991284192, green: 0.6028449535, blue: 0.9592232704, alpha: 1), 0.25: #colorLiteral(red: 0.1142767668, green: 0.3181744218, blue: 0.4912756383, alpha: 1), 0.5: #colorLiteral(red: 0.1603052318, green: 0, blue: 0.8195188642, alpha: 1), 1: #colorLiteral(red: 0.8100712299, green: 0.1511939615, blue: 0.4035313427, alpha: 1) ] )
        noise?.move(by: translation)
    }
    
    func cgImage() -> CGImage {
        noiseMap = GKNoiseMap(noise: noise!, size: size, origin: vector_double2(100, 100), sampleCount: vector_int2(Int32(size.x) / 4, Int32(size.y) / 4), seamless: false)
        return SKTexture(noiseMap: noiseMap!).cgImage()
    }
}

// Some factories that create noise types with good initial settings

func makePerlinNoise() -> NoiseGenerator {
    return NoiseGenerator( GKPerlinNoiseSource(frequency: 0.0014, octaveCount: 3, persistence: 0.4, lacunarity: 4.2, seed: 437) )
}

func makeBillowNoise() -> NoiseGenerator {
    return NoiseGenerator( GKBillowNoiseSource(frequency: 0.0012, octaveCount: 3, persistence: 0.2, lacunarity: 4.6, seed: 437) )
}

func makeRidgedNoise() -> NoiseGenerator {
    return NoiseGenerator( GKRidgedNoiseSource(frequency: 0.002, octaveCount: 3, lacunarity: 4.2, seed: 437) )
}

/*: 
 `Interface` subclasses `UIView`
 
 Subclassing allows gesture recognizers and control targets to be set easily
 
 */

func verticalStack(_ arrangedSubviews: [UIView]) -> UIStackView {
    let stack = UIStackView(arrangedSubviews: arrangedSubviews)
    stack.axis = .vertical
    stack.alignment = .fill
    stack.distribution = .fillEqually
    return stack
}

class ViewController: UIViewController {
    let mainView = UIStackView()
    
    let noiseImage = UIImageView()
    let controlPanel = UIStackView()
    
    var noiseGenerator: NoiseGenerator!
    
    let frequencyLabel = UILabel()
    let frequencySlider = UISlider()
    
    let persistenceSlider = UISlider()
    let persistenceLabel = UILabel()
    
    let lacunaritySlider = UISlider()
    let lacunarityLabel = UILabel()
    
    let octavesStepper = UIStepper()
    let octavesLabel = UILabel()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        title = "GameplayKit Noise Explorer"
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        // noise image view
        noiseImage.frame = view.frame
        // make the noise image expand to fill the main stack view
        noiseImage.setContentHuggingPriority(2, for: .vertical)
        
        //pan gesture for noise image
        noiseImage.isUserInteractionEnabled = true
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panImage))
        pan.delegate = self
        noiseImage.addGestureRecognizer(pan)
        
        //segmented control to switch noise types
        let noiseTypes = ["Perlin", "Billow", "Ridged"]
        let segmentControl = UISegmentedControl(items: noiseTypes)
        segmentControl.selectedSegmentIndex = 0
        segmentControl.center += CGPoint(x: 10, y: 5) //+= 5
        segmentControl.layer.cornerRadius = 10
        segmentControl.addTarget(self, action: #selector(setNoiseType), for: .valueChanged)
        
        setNoiseType(sender: segmentControl)
        
        //format sliders
        setSlider(slider: frequencySlider, label: frequencyLabel, min: 0.0001, max: 0.008, current: Float(noiseGenerator.frequency), labelSelector: #selector(frequencyLabelSet), sliderSelector: #selector(frequencySet))
        
        setSlider(slider: persistenceSlider, label: persistenceLabel, min: 0.2, max: 2, current: Float(noiseGenerator.persistence), labelSelector: #selector(persistenceLabelSet), sliderSelector: #selector(persistenceSet))
        
        setSlider(slider: lacunaritySlider, label: lacunarityLabel, min: 1, max: 6, current: Float(noiseGenerator.lacunarity), labelSelector: #selector(lacunarityLabelSet), sliderSelector: #selector(lacunaritySet))
        
        // configure octave stepper
        octavesStepper.minimumValue = 1
        octavesStepper.maximumValue = 6
        octavesStepper.isContinuous = false
        octavesStepper.value = Double(noiseGenerator.octaveCount)
        octavesStepper.addTarget(self, action: #selector(octavesSet), for: .valueChanged)
        octavesLabelSet()
        
        // layout UI elements within stack views
        // 4 vertical stacks for each controller + label
        let freqPanel = verticalStack([frequencySlider, frequencyLabel])
        let persPanel = verticalStack([persistenceSlider, persistenceLabel])
        let lacuPanel = verticalStack([lacunaritySlider, lacunarityLabel])
        let octaPanel = verticalStack([octavesStepper, octavesLabel])
        octaPanel.alignment = .center
        // 2 horizontal stacks that will be arranged side by side or one over the other
        let panelA = UIStackView(arrangedSubviews: [freqPanel, lacuPanel])
        let panelB = UIStackView(arrangedSubviews: [persPanel, octaPanel])
        panelA.alignment = .fill
        panelA.distribution = .fillEqually
        panelA.spacing = 8
        panelB.alignment = .fill
        panelB.distribution = .fillEqually
        panelB.spacing = 8
        // control panel is the stack whose alignment will switch axis depending on available horizontal screen space
        controlPanel.addArrangedSubview(panelA)
        controlPanel.addArrangedSubview(panelB)
        controlPanel.alignment = .fill
        controlPanel.distribution = .fillProportionally
        controlPanel.spacing = 8
        
        // finally, add these elements to the main vertical stack
        mainView.addArrangedSubview(segmentControl)
        mainView.addArrangedSubview(controlPanel)
        mainView.addArrangedSubview(noiseImage)
        
        mainView.axis = .vertical
        mainView.distribution = .fill
        mainView.alignment = .fill
        mainView.spacing = 8
        
        view.addSubview(mainView)
        
    }
    
    func setSlider(slider: UISlider, label: UILabel, min: Float, max: Float, current: Float, labelSelector: Selector, sliderSelector: Selector){
        slider.addTarget(self, action: labelSelector, for: .touchDragInside)
        slider.addTarget(self, action: sliderSelector, for: .valueChanged)
        slider.isContinuous = false
        slider.minimumValue = min
        slider.maximumValue = max
        slider.setValue(current, animated: true)
        label.textAlignment = .justified
        perform(labelSelector)
    }
    
    func updateImage(){
        noiseImage.image = UIImage(cgImage: noiseGenerator.cgImage())
    }
    
    func updateNoiseAndImage(){
        noiseGenerator.update()
        updateImage()
    }
    
    func setNoiseType(sender: UISegmentedControl){
        switch sender.selectedSegmentIndex {
        case 0:
            noiseGenerator = makePerlinNoise()
            persistenceSlider.isEnabled = true
        case 1:
            noiseGenerator = makeBillowNoise()
            persistenceSlider.isEnabled = true
        case 2:
            noiseGenerator = makeRidgedNoise()
            persistenceSlider.isEnabled = false //ridged noise has no persistence setting
        default:
            return
        }
        frequencySlider.setValue(Float(noiseGenerator.frequency), animated: true)
        persistenceSlider.setValue(Float(noiseGenerator.persistence), animated: true)
        lacunaritySlider.setValue(Float(noiseGenerator.lacunarity), animated: true)
        octavesStepper.value = Double(noiseGenerator.octaveCount)
        frequencyLabelSet()
        persistenceLabelSet()
        lacunarityLabelSet()
        octavesLabelSet()
        updateNoiseAndImage()
    }
    
    func octavesSet(sender: UIStepper){
        noiseGenerator.octaveCount = Int(sender.value)
        octavesLabelSet()
        updateNoiseAndImage()
    }
    
    func roundString(_ value: Float) -> String {
        return String(format: "%.4f", value)
    }
    
    func octavesLabelSet(){
        octavesLabel.text = "Octaves \(Int(octavesStepper.value))"
    }
    
    func persistenceLabelSet() {
        persistenceLabel.text = "Persistence \(roundString(persistenceSlider.value))"
    }
    
    func frequencyLabelSet() {
        frequencyLabel.text = "Frequency \(roundString(frequencySlider.value))"
    }
    
    func lacunarityLabelSet() {
        lacunarityLabel.text = "Lacunarity \(roundString(lacunaritySlider.value))"
    }
    
    func frequencySet(sender: UISlider){
        noiseGenerator.frequency = Double(sender.value)
        frequencyLabelSet()
        updateNoiseAndImage()
    }
    
    func persistenceSet(sender: UISlider){
        noiseGenerator.persistence = Double(sender.value)
        persistenceLabelSet()
        updateNoiseAndImage()
    }
    
    func lacunaritySet(sender: UISlider){
        noiseGenerator.lacunarity = Double(sender.value)
        lacunarityLabelSet()
        updateNoiseAndImage()
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        
        let top = topLayoutGuide.length
        let bottom = bottomLayoutGuide.length
        print(view.frame) //add an observer here and select list to see the different frame sizes
        mainView.frame = CGRect(x: 0, y: top, width: view.frame.width, height: view.frame.height - top - bottom).insetBy(dx: 10, dy: 10)  
        
        //reflexive layout of sliders
        if view.frame.width < 600 {
            controlPanel.axis = .vertical
        } else {
            controlPanel.axis = .horizontal
        }
        
    }
}


//: Gesture recognizer delegate

extension ViewController: UIGestureRecognizerDelegate {
    func panImage(recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: view)
        let delta: vector_double3
        if recognizer.numberOfTouches() < 2 {
            // pan around the image with one touch (nb translate X and Z components)
            delta = vector_double3(Double(-translation.x) / 2, 0, Double(translation.y) / 2) 
        } else {
            // with two finger vertical pan, animate the noise, moving "through" it effectively (Y component)
            delta = vector_double3(0, Double(translation.y) / 3, 0)
        }
        noiseGenerator.panImage(delta: delta)
        updateImage()
    }
}

let controller = ViewController()

PlaygroundPage.current.liveView = UINavigationController(rootViewController: controller)


