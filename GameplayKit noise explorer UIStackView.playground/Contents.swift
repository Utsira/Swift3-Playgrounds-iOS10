/*:
 # GameplayKit Noise Explorer
 
 ## A UIKit playground interactions demo
 
 ### Requirements
 
 This is a Swift 3 Playground that runs on either:
 
 + An iPad running iOS 10
 + A Mac running Xcode 8 (runs on either OS X El Capitan or MacOS Sierra)
 
 ### UIKit in Playgrounds
 
 Since Xcode 7.3 (and now, with the Swift Playgrounds App on the iPad in iOS 10), Swift Playgrounds have been able to receive user interactions. This playground handles touch events and gestures with a subclass of UIView.
 
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
import SpriteKit
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

class NoiseGenerator{
    
    var frequency: Double = 0.0014
    var octaveCount: Int = 4
    var persistence: Double = 1.4
    var lacunarity: Double = 3.8

    private var _noiseSource: GKNoiseSource!
    private var noiseSource: GKNoiseSource {return _noiseSource}
    private var noise: GKNoise?
    private var noiseMap: GKNoiseMap?
    
    private let size = vector_double2(600, 600)
    private var translation = vector_double3(0,0,0)
    
    init(_ source: GKNoiseSource) {
        _noiseSource = source
    }
    
    func panImage(delta: vector_double3){
        translation += delta //store the cumulative translation so that when the noise is re-generated, the view remains consistent
        noise?.move(by: delta)
    }
    
    func update() {
        noise = GKNoise(noiseSource: noiseSource, gradientColors: [0: #colorLiteral(red: 0.6823074818, green: 0.08504396677, blue: 0.06545677781, alpha: 1), 0.1: #colorLiteral(red: 0.9346159697, green: 0.6284804344, blue: 0.1077284366, alpha: 1), 0.2: #colorLiteral(red: 0.9672742486, green: 0.8225458264, blue: 0.4772382379, alpha: 1), 0.4: #colorLiteral(red: 0.4028071761, green: 0.7315050364, blue: 0.2071235478, alpha: 1), 0.6: #colorLiteral(red: 0.1991284192, green: 0.6028449535, blue: 0.9592232704, alpha: 1), 0.8: #colorLiteral(red: 0.1142767668, green: 0.3181744218, blue: 0.4912756383, alpha: 1), 0.9: #colorLiteral(red: 0.1603052318, green: 0, blue: 0.8195188642, alpha: 1), 1: #colorLiteral(red: 0.8100712299, green: 0.1511939615, blue: 0.4035313427, alpha: 1) ] )
        noise?.move(by: translation)
    }
    
    func cgImage() -> CGImage {
        noiseMap = GKNoiseMap(noise: noise!, size: size, origin: vector_double2(100, 100), sampleCount: vector_int2(Int32(size.x) / 4, Int32(size.y) / 4), seamless: false)
        return SKTexture(noiseMap: noiseMap!).cgImage()
    }
}

/*: 
 Noise subclasses essentially just handle casting `noiseSource` to the correct sub-type
 
 TO-DO: Investigate if there's a less verbose way of handling the need for different sub-classes of noise
 */

class BillowNoiseGenerator: NoiseGenerator {
    init(){
        super.init(GKBillowNoiseSource(frequency: 0.0012, octaveCount: 4, persistence: 0.2, lacunarity: 4.6, seed: 437))
    }
    override var noiseSource: GKBillowNoiseSource {
        return super.noiseSource as! GKBillowNoiseSource
    }
    override var frequency: Double {
        get { return noiseSource.frequency }
        set { noiseSource.frequency = newValue}
    }
    override var persistence: Double {
        get { return noiseSource.persistence }
        set { noiseSource.persistence = newValue }
    }
    override var lacunarity: Double {
        get { return noiseSource.lacunarity }
        set { noiseSource.lacunarity = newValue }
    }
    override var octaveCount: Int {
        get { return noiseSource.octaveCount }
        set { noiseSource.octaveCount = newValue }
    }
}

class RidgedNoiseGenerator: NoiseGenerator {
    init(){
        super.init(GKRidgedNoiseSource(frequency: 0.002, octaveCount: 4, lacunarity: 4.2, seed: 437))
    }
    override var noiseSource: GKRidgedNoiseSource {
        return super.noiseSource as! GKRidgedNoiseSource
    }
    override var frequency: Double {
        get { return noiseSource.frequency }
        set { noiseSource.frequency = newValue}
    }
    override var lacunarity: Double {
        get { return noiseSource.lacunarity }
        set { noiseSource.lacunarity = newValue }
    }
    override var octaveCount: Int {
        get { return noiseSource.octaveCount }
        set { noiseSource.octaveCount = newValue }
    }
}

class PerlinNoiseGenerator: NoiseGenerator {
    init(){
        super.init(GKPerlinNoiseSource(frequency: 0.0014, octaveCount: 4, persistence: 0.4, lacunarity: 4.2, seed: 437))
    }
    override var noiseSource: GKPerlinNoiseSource {
        return super.noiseSource as! GKPerlinNoiseSource
    }
    override var frequency: Double {
        get { return noiseSource.frequency }
        set { noiseSource.frequency = newValue}
    }
    override var persistence: Double {
        get { return noiseSource.persistence }
        set { noiseSource.persistence = newValue }
    }
    override var lacunarity: Double {
        get { return noiseSource.lacunarity }
        set { noiseSource.lacunarity = newValue }
    }
    override var octaveCount: Int {
        get { return noiseSource.octaveCount }
        set { noiseSource.octaveCount = newValue }
    }
}

/*: 
 `Interface` subclasses `UIView`
 
 Subclassing allows gesture recognizers and control targets to be set easily
 
 TO-DO: add programmatic constraints
 */

class Interface: UIView {
    let noiseImage: UIImageView
    
    let frequencyLabel: UILabel
    let frequencySlider: UISlider
    
    let persistenceSlider: UISlider
    let persistenceLabel: UILabel
    
    let lacunaritySlider: UISlider
    let lacunarityLabel: UILabel
    
    let octavesStepper: UIStepper
    let octavesLabel: UILabel
    
    override init(frame: CGRect) {
        // noise image view
        noiseImage = UIImageView(frame: frame)

        //sliders & labels
        let titleLabel = UILabel()
        titleLabel.text = "GameplayKit Noise Explorer"
        titleLabel.textAlignment = .center
        frequencySlider = UISlider() //frame: controlFrame)
        frequencyLabel = UILabel() //frame: controlFrame)
        persistenceSlider = UISlider() //frame: controlFrame)
        persistenceLabel = UILabel() //frame: controlFrame)
        lacunaritySlider = UISlider() //frame: controlFrame)
        lacunarityLabel = UILabel() //frame: controlFrame)
        
        //octave stepper to noise octaves
        octavesStepper = UIStepper()
        octavesLabel = UILabel() //frame: CGRect(x: 0, y: 0, width: controlFrame.width / 2, height: controlFrame.height))
        
        super.init(frame: frame)
        
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
        
        let freqPanel = verticalStack([frequencySlider, frequencyLabel])
        let persPanel = verticalStack([persistenceSlider, persistenceLabel])
        let lacuPanel = verticalStack([lacunaritySlider, lacunarityLabel])
        let octaPanel = verticalStack([octavesStepper, octavesLabel])
        
        let bottomPanel = UIStackView(arrangedSubviews: [freqPanel, persPanel, lacuPanel, octaPanel])
        bottomPanel.axis = .horizontal
        bottomPanel.alignment = .fill
        bottomPanel.distribution = .equalSpacing
        
        let frame = CGRect(x: 0, y: 0, width: frame.width, height: 140)
        
        let controlPanel = UIStackView(frame: frame.insetBy(dx: 10, dy: 10))
        controlPanel.addArrangedSubview(titleLabel)
        controlPanel.addArrangedSubview(segmentControl)
        controlPanel.addArrangedSubview(bottomPanel)
        controlPanel.axis = .vertical
        controlPanel.alignment = .fill
        controlPanel.distribution = .equalSpacing

        let frostedPanel = UIView(frame: frame)
        frostedPanel.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7521551724)
        frostedPanel.layer.cornerRadius = 15
        frostedPanel.addSubview(controlPanel)
        
        self.addSubview(frostedPanel)
        self.addSubview(noiseImage)
        
        self.bringSubview(toFront: frostedPanel)
    }
    
    func verticalStack(_ arrangedSubviews: [UIView]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: arrangedSubviews)
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
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
            noiseGenerator = PerlinNoiseGenerator()
            persistenceSlider.isEnabled = true
        case 1:
            noiseGenerator = BillowNoiseGenerator()
            persistenceSlider.isEnabled = true
        case 2:
            noiseGenerator = RidgedNoiseGenerator()
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//: Gesture recognizer delegate

extension Interface: UIGestureRecognizerDelegate {
    func panImage(recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self)
        let delta: vector_double3
        if recognizer.numberOfTouches() < 2 {
            // pan around the image with one touch (nb translate X and Z components)
            delta = vector_double3(Double(-translation.x), 0, Double(translation.y))
        } else {
            // with two finger vertical pan, animate the noise, moving "through" it effectively (Y component)
            delta = vector_double3(0, Double(translation.y) / 2, 0)
        }
        noiseGenerator.panImage(delta: delta)
        updateImage()
    }
}


var noiseGenerator: NoiseGenerator

let frame = CGRect(x: 0, y: 0, width: 688, height: 600)
PlaygroundPage.current.liveView = Interface(frame: frame)
