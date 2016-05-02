//
//  ViewController.swift
//  Dynamics
//
//  Created by Eugene on 5/1/16.
//  Copyright © 2016 Tulusha.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var resetButton: UIButton?
    @IBOutlet var addButton: UIButton?
    
    var boxes: [UIView]?
    
    var animator: UIDynamicAnimator?
    var gravity: UIGravityBehavior?
    var collision: UICollisionBehavior?
    var attachment: UIAttachmentBehavior?
    var itemBehavior: UIDynamicItemBehavior?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.boxes = []
        self.animator = UIDynamicAnimator(referenceView: self.view)
        
        addRandomBox()
    }
    
    @IBAction func resetBoxes() {
        for box in self.boxes! {
            box.removeFromSuperview()
        }
        self.boxes?.removeAll()
        
        addRandomBox()
    }
    
    @IBAction func addRandomBox() {
        let color = UIColor.randomColor()
        let length:CGFloat = 50.0 + CGFloat(arc4random_uniform(60))
        let frame = CGRectMake(CGRectGetMidX(self.view.frame) - length/2.0, CGRectGetMidY(self.view.frame) - length/2.0, length, length)
        addBox(color, frame)
    }
    
    private func addBox(color: UIColor, _ frame:CGRect) {
        self.animator?.removeAllBehaviors()
        
        let box = UIView()
        box.backgroundColor = color
        box.frame = frame
        self.view.addSubview(box)
        self.boxes?.append(box)
        
        self.gravity = UIGravityBehavior(items: self.boxes!)
        self.animator!.addBehavior(self.gravity!)
        
        self.collision = UICollisionBehavior(items: self.boxes!)
        self.collision!.translatesReferenceBoundsIntoBoundary = true
        self.animator!.addBehavior(self.collision!)
        
        self.itemBehavior = UIDynamicItemBehavior(items: self.boxes!)
        self.itemBehavior!.angularResistance = 0
        self.itemBehavior!.elasticity = 0.3
        self.animator!.addBehavior(self.itemBehavior!)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanning(_:)))
        box.addGestureRecognizer(panGesture)
        
        self.view.bringSubviewToFront(resetButton!)
        self.view.bringSubviewToFront(addButton!)
    }
    
    @objc private func handlePanning(gesture:UIPanGestureRecognizer) {
        let location = gesture.locationInView(self.view)
        let boxLocation = gesture.locationInView(gesture.view)
        
        switch gesture.state {
            case .Began:
                self.animator!.removeBehavior(self.gravity!)
                let offset = UIOffsetMake(boxLocation.x - CGRectGetMidX(gesture.view!.bounds), boxLocation.y - CGRectGetMidY(gesture.view!.bounds))
                self.attachment = UIAttachmentBehavior(item: gesture.view!, offsetFromCenter: offset, attachedToAnchor: location)
                self.animator!.addBehavior(self.attachment!);
                break
                
            case .Changed:
                self.attachment!.anchorPoint = location
                break
            case .Ended:
                self.itemBehavior?.addLinearVelocity(gesture.velocityInView(self.view), forItem: gesture.view!)
                self.animator!.removeBehavior(self.attachment!)
                self.animator!.addBehavior(self.gravity!)
                break
            default: break
        }
    }
}

extension UIColor {
    static func randomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
}

