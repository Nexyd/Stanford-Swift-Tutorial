//
//  FaceView.swift
//  FaceIt
//
//  Created by Daniel Morato on 09/10/2017.
//  Copyright © 2017 Dani's Swift Test. All rights reserved.
//

import UIKit

@IBDesignable
class FaceView: UIView {

    @IBInspectable
    var scale: CGFloat = 0.9 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var eyesOpen: Bool = false { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var color: UIColor = UIColor.red { didSet { setNeedsDisplay() } }
    
    @objc func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer)
    {
        switch pinchRecognizer.state {
            case .changed, .ended:
                scale *= pinchRecognizer.scale
                pinchRecognizer.scale = 1
            default:
                break
        }
    }
    
    // 1.0 is full smile and -1.0 is full frown
    @IBInspectable
    var mouthCurvature: Double = -0.5
    
    private var skullRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    private var skullCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private enum Eye {
        case left
        case right
    }
    
    private struct Ratios {
        static let skullRadiusToEyeOffset:   CGFloat = 3
        static let skullRadiusToEyeRadius:   CGFloat = 10
        static let skullRadiusToMouthWidth:  CGFloat = 1
        static let skullRadiusToMouthHeight: CGFloat = 3
        static let skullRadiusToMouthOffset: CGFloat = 3
    }
    
    private func buildPath(center: CGPoint, radius: CGFloat, clockwise direction: Bool) -> UIBezierPath
    {
        let path = UIBezierPath(arcCenter: center, radius: radius,
            startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: direction)
        
        path.lineWidth = lineWidth
        return path
    }
    
    private func pathForEye(_ eye: Eye) -> UIBezierPath
    {
        func centerOfEye(_ eye: Eye) -> CGPoint {
            let eyeOffset = skullRadius / Ratios.skullRadiusToEyeOffset
            var eyeCenter = skullCenter
            eyeCenter.y -= eyeOffset
            eyeCenter.x += ((eye == .left) ? -1 : 1) * eyeOffset
            return eyeCenter
        }
        
        let eyeRadius = skullRadius / Ratios.skullRadiusToEyeRadius
        let eyeCenter = centerOfEye(eye)
        
        let path: UIBezierPath
        if eyesOpen {
            path = buildPath(center: eyeCenter, radius: eyeRadius, clockwise: true)
        } else {
            path = UIBezierPath()
            path.move(to: CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
            path.addLine(to: CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
            path.lineWidth = lineWidth
        }
        
        return path
    }
    
    private func pathForMouth() -> UIBezierPath
    {
        let mouthWidth  = skullRadius / Ratios.skullRadiusToMouthWidth
        let mouthHeight = skullRadius / Ratios.skullRadiusToMouthHeight
        let mouthOffset = skullRadius / Ratios.skullRadiusToMouthOffset
        
        let mouthRect = CGRect(
            x: skullCenter.x - mouthWidth / 2,
            y: skullCenter.y + mouthOffset,
            width:  mouthWidth,
            height: mouthHeight
        )
        
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.midY)
        let end   = CGPoint(x: mouthRect.maxX, y: mouthRect.midY)
        
        let startingPoint = CGPoint(x: start.x + mouthRect.width / 3, y: start.y + smileOffset)
        let endingPoint = CGPoint(x: end.x - mouthRect.width / 3,   y: end.y + smileOffset)
        
        let path = UIBezierPath()//rect: mouthRect)
        path.lineWidth = lineWidth
        path.move(to: start)
        path.addCurve(to: end,
            controlPoint1: startingPoint,
            controlPoint2: endingPoint)
        
        return path
    }
    
    override func draw(_ rect: CGRect) {
        color.set()
        buildPath(center: skullCenter, radius: skullRadius, clockwise: false).stroke()
        pathForEye(.left).stroke()
        pathForEye(.right).stroke()
        pathForMouth().stroke()
    }
}
