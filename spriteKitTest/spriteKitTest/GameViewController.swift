//
//  GameViewController.swift
//  spriteKitTest
//
//  Created by Roman Yarmoliuk on 28.12.2022.
//

import UIKit
import SpriteKit
import GameplayKit

struct BitMasks {
    static let player: UInt32 = 1
    static let star: UInt32 = 2
    static let enemy: UInt32 = 4
    static let bonus: UInt32 = 8
    static let shield: UInt32 = 16
    static let heart: UInt32 = 32
    static let protection: UInt32 = 64
}


class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = MyGameScene(size: self.view.frame.size)
        let skView = view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = true
        skView.showsPhysics = false
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFit
        skView.presentScene(scene)
               
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
