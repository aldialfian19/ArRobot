//
//  ViewController.swift
//  ArRobot
//
//  Created by Rinaldi Alfian on 06/11/22.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var robotEntity: Entity?
    var toyEntity: Entity?
    var startEntity: Entity?
    
    var moveToLocation: Transform = Transform()
    var moveDuration: Double = 3.00
    

    var currentPos: SIMD3<Float>?
    
    var a1position: SIMD3<Float>?
    var a2position: SIMD3<Float>?
    var a3position: SIMD3<Float>?
    var b1position: SIMD3<Float>?
    var b2position: SIMD3<Float>?
    var b3position: SIMD3<Float>?
    var c1position: SIMD3<Float>?
    var c2position: SIMD3<Float>?
    var c3position: SIMD3<Float>?

    var floorEntitya1: Entity?
    var floorEntitya2: Entity?
    var floorEntitya3: Entity?
    var floorEntityb1: Entity?
    var floorEntityb2: Entity?
    var floorEntityb3: Entity?
    var floorEntityc1: Entity?
    var floorEntityc2: Entity?
    var floorEntityc3: Entity?
    
    var a1pos: SIMD3<Float> = simd_float3(x: 0, y: 0, z: 0)
    var a2pos: SIMD3<Float> = simd_float3(x: 0.2, y: 0, z: 0)
    var a3pos: SIMD3<Float> = simd_float3(x: 0.4, y: 0, z: 0)
    var b1pos: SIMD3<Float> = simd_float3(x: 0, y: 0, z: 0.2)
    var b2pos: SIMD3<Float> = simd_float3(x: 0.2, y: 0, z: 0.2)
    var b3pos: SIMD3<Float> = simd_float3(x: 0.4, y: 0, z: 0.2)
    var c1pos: SIMD3<Float> = simd_float3(x: 0, y: 0, z: 0.4)
    var c2pos: SIMD3<Float> = simd_float3(x: 0.2, y: 0, z: 0.4)
    var c3pos: SIMD3<Float> = simd_float3(x: 0.4, y: 0, z: 0.4)
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // start and initialize
        startARSession()
        
        //load 3d model
        robotEntity = try! Entity.load(named: "robot")
        toyEntity = try! Entity.load(named: "toy")
        startEntity = try! Entity.load(named: "merah")
        
        
        floorEntitya1 = try! Entity.load(named: "floor")
        floorEntitya2 = try! Entity.load(named: "floor")
        floorEntitya3 = try! Entity.load(named: "floor")
        floorEntityb1 = try! Entity.load(named: "floor")
        floorEntityb2 = try! Entity.load(named: "floor")
        floorEntityb3 = try! Entity.load(named: "floor")
        floorEntityc1 = try! Entity.load(named: "floor")
        floorEntityc2 = try! Entity.load(named: "floor")
        floorEntityc3 = try! Entity.load(named: "floor")
        
        
        
        
        //Tap detector
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
        
        //add button
        createdButton()
        
        move(direction: "")
        
        checkPoint()
        
        
        
    }
    //MARK: -Object Placement methods
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        
        //Tap location (2D Point) di layar
        let tapLocation = recognizer.location(in: arView)
        
        // mengubah titik 2D di layar menjadi titik 3D di reality
        let result = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        
        // if plane detected
        if let firstResult = result.first {
//            print("\(firstResult)")
            
            // 3D position (detect koordinat x,y,z)
            let worldPos = simd_make_float3(firstResult.worldTransform.columns.3)
//            print("world\(worldPos)")
            
//            print("\(a2pos)")
            a1position = (startEntity?.position)!
            a2position = ((startEntity?.position)! + a2pos)
            a3position = ((startEntity?.position)! + a3pos)
            b1position = ((startEntity?.position)! + b1pos)
            b2position = ((startEntity?.position)! + b2pos)
            b3position = ((startEntity?.position)! + b3pos)
            c1position = ((startEntity?.position)! + c1pos)
            c2position = ((startEntity?.position)! + c2pos)
            c3position = ((startEntity?.position)! + c3pos)
            
            
            // Place object
            placeObject(object: robotEntity!, position: worldPos)
            placeObject(object: toyEntity!, position: worldPos + simd_float3 (x: 0.2, y: 0, z: 0))
            placeObject(object: startEntity!, position: worldPos)
            
            placeObject(object: floorEntitya1!, position: worldPos + a1pos)
            placeObject(object: floorEntitya2!, position: worldPos + a2pos)
            placeObject(object: floorEntitya3!, position: worldPos + a3pos)
            placeObject(object: floorEntityb1!, position: worldPos + b1pos)
            placeObject(object: floorEntityb2!, position: worldPos + b2pos)
            placeObject(object: floorEntityb3!, position: worldPos + b3pos)
            placeObject(object: floorEntityc1!, position: worldPos + c1pos)
            placeObject(object: floorEntityc2!, position: worldPos + c2pos)
            placeObject(object: floorEntityc3!, position: worldPos + c3pos)
            
            // Move Object
            move(direction: "")
            
            toyAnimation()
            
        }
    }
    
    func startARSession() {
        
        arView.automaticallyConfigureSession = true
        
        //Plane detection
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        
//        arView.debugOptions = .showAnchorGeometry
        arView.session.run(configuration)
        
    }
    
    func placeObject(object:Entity, position: SIMD3<Float>) {
        
        // 1. create anchor at 3D pos
        let objectAnchor = AnchorEntity(world: position)
        
        // 2. Tie model to anchor
        objectAnchor.addChild(object)
        
        // 3. Anchor to scene
        arView.scene.addAnchor(objectAnchor)
    }
    
    //MARK: -Object movement
    
    func move (direction: String) {
        
        let robotPos = robotEntity?.position
    
        
        switch direction {
            
            
            case "forward":
            
            if robotPos == startEntity?.position {
                moveToLocation.translation = (robotEntity?.transform.translation)! + simd_float3 (x: 0, y: 0, z: 20)
                robotEntity?.move(to: moveToLocation, relativeTo: robotEntity, duration: moveDuration)
                robotEntity?.position = b1position!
                walkAnimation(moveDuration: moveDuration)

            }else if robotPos == b1position {
                moveToLocation.translation = (robotEntity?.transform.translation)! + simd_float3 (x: 0, y: 0, z: 20)
                robotEntity?.move(to: moveToLocation, relativeTo: robotEntity, duration: moveDuration)
                robotEntity?.position = c1position!
                walkAnimation(moveDuration: moveDuration)
            }else {
                print("no move")
            }
            
            
            
            //walking animation
//            walkAnimation(moveDuration: moveDuration)
            
            case "back":
            //move
            moveToLocation.translation = (robotEntity?.transform.translation)! + simd_float3 (x: 0, y: 0, z: -20)
            robotEntity?.move(to: moveToLocation, relativeTo: robotEntity, duration: moveDuration)

            //walking animation
            walkAnimation(moveDuration: moveDuration)
            
            case "left":
            //create sudut berputar
            if robotPos == startEntity?.position {
                let rotateAngle = simd_quatf(angle: GLKMathDegreesToRadians(90), axis: SIMD3(x: 0, y: 1, z: 0))
                robotEntity?.setOrientation(rotateAngle, relativeTo: robotEntity)
                
                moveToLocation.translation = (robotEntity?.transform.translation)! + simd_float3 (x: 0, y: 0, z: 20)
                robotEntity?.move(to: moveToLocation, relativeTo: robotEntity, duration: moveDuration)
                robotEntity?.position = a2position!
                walkAnimation(moveDuration: moveDuration)

            }else if robotPos == b1position {
                let rotateAngle = simd_quatf(angle: GLKMathDegreesToRadians(90), axis: SIMD3(x: 0, y: 1, z: 0))
                robotEntity?.setOrientation(rotateAngle, relativeTo: robotEntity)
                
                moveToLocation.translation = (robotEntity?.transform.translation)! + simd_float3 (x: 0, y: 0, z: 20)
                robotEntity?.move(to: moveToLocation, relativeTo: robotEntity, duration: moveDuration)
                robotEntity?.position = b2position!
                walkAnimation(moveDuration: moveDuration)
                
            }else if robotPos == c1position {
                let rotateAngle = simd_quatf(angle: GLKMathDegreesToRadians(90), axis: SIMD3(x: 0, y: 1, z: 0))
                robotEntity?.setOrientation(rotateAngle, relativeTo: robotEntity)
                
                moveToLocation.translation = (robotEntity?.transform.translation)! + simd_float3 (x: 0, y: 0, z: 20)
                robotEntity?.move(to: moveToLocation, relativeTo: robotEntity, duration: moveDuration)
                robotEntity?.position = c2position!
                walkAnimation(moveDuration: moveDuration)
            }else {
                print("no move")
            }
            
//            let rotateAngle = simd_quatf(angle: GLKMathDegreesToRadians(90), axis: SIMD3(x: 0, y: 1, z: 0))
//            robotEntity?.setOrientation(rotateAngle, relativeTo: robotEntity)
//            walkAnimation(moveDuration: moveDuration)
            
            case "right":
            //create sudut berputar
            let rotateAngle = simd_quatf(angle: GLKMathDegreesToRadians(90), axis: SIMD3(x: 0, y: 1, z: 0))
            robotEntity?.setOrientation(rotateAngle, relativeTo: robotEntity)
            
        default:
            print("No Movement")
            
        }
    }
    
    func walkAnimation(moveDuration: Double) {
        
        //USDZ Animation
        if let robotAnimation = robotEntity?.availableAnimations.first {
            
            //Play the animation
            robotEntity?.playAnimation(robotAnimation.repeat(duration: moveDuration), transitionDuration: 0.5, startsPaused: false)
            
        }else {
            print("No Animation Available")
        }
    }
    
    func toyAnimation(){
        toyEntity?.availableAnimations.forEach{
            toyEntity?.playAnimation($0.repeat())
        }
    }
    
    func checkPoint(){
        let cek = (startEntity?.position)! + simd_float3(x: 0, y: 0, z: 0.2)
        print("a2cek\(cek)")
        print("ini \((robotEntity?.position)!)")
        
        if (robotEntity?.position)! == cek{
            print("Get Point")
        }else {
            print("No Point")
            
            // 12<x>10
        }
    }
    
    //MARK: -Create Button
    
    func createdButton() {
        
        let maju = UIButton(type: .system)
        maju.frame = CGRect(x: 0, y: 300, width: 80, height: 50)
        maju.backgroundColor = .blue
        maju.setTitle("maju", for: .normal)
        maju.addTarget(self, action: #selector(majuAction), for: .touchUpInside)
        
        let mundur = UIButton(type: .system)
        mundur.frame = CGRect(x: 90, y: 300, width: 80, height: 50)
        mundur.backgroundColor = .blue
        mundur.setTitle("mundur", for: .normal)
        mundur.addTarget(self, action: #selector(mundurAction), for: .touchUpInside)
        
        let kiri = UIButton(type: .system)
        kiri.frame = CGRect(x: 180, y: 300, width: 80, height: 50)
        kiri.backgroundColor = .blue
        kiri.setTitle("kiri", for: .normal)
        kiri.addTarget(self, action: #selector(kiriAction), for: .touchUpInside)
        
        let kanan = UIButton(type: .system)
        kanan.frame = CGRect(x: 270, y: 300, width: 80, height: 50)
        kanan.backgroundColor = .blue
        kanan.setTitle("kanan", for: .normal)
        kanan.addTarget(self, action: #selector(kananAction), for: .touchUpInside)
        
        
        
        self.view.addSubview(maju)
        self.view.addSubview(mundur)
        self.view.addSubview(kiri)
        self.view.addSubview(kanan)
    }
    
    @objc func majuAction(sender: UIButton!) {
        
        move(direction: "forward")
        checkPoint()
        print("maju")
    }
    @objc func mundurAction(sender: UIButton!) {
        move(direction: "mundur")
        
    }
    @objc func kiriAction(sender: UIButton!) {
        move(direction: "left")
        checkPoint()
        print("kiri")
        // tambah array kiri ke action
    }
    @objc func kananAction(sender: UIButton!) {
        move(direction: "right")
        checkPoint()
        print("kanan")
    }
}


