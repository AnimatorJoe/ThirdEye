//
//  VisualSupportViewController.swift
//  3rd Eye
//
//  Created by Joseph Jin on 11/19/17.
//  Copyright © 2017 WestlakeAPC. All rights reserved.
//

import UIKit
import AVKit
import Vision
import Toast_Swift

class DeveloperModeViewController: VisualSupportViewController {
    
    var inceptionV3 = Inceptionv3()
    var resnet50 = Resnet50()
    var VGG16Model = VGG16()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUserMode = .developer
        currentModel = .microsoftVision
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissIDView(self)
    }
}

// Processing Request (Image conversion + prediction happens here)
extension DeveloperModeViewController {
    
    // Converting Image
    func convertImageForCoreML(_ image: UIImage, toSize side: Int) -> CVPixelBuffer {
        
        // Resize Image and Store it in newImage
        UIGraphicsBeginImageContextWithOptions(CGSize(width: side, height: side), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: side, height: side))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Convert newImage into a CVPixelBuffer
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        /*guard (status == kCVReturnSuccess) else {
         print("R.I.P.")
         return nil
         }*/
        
        // Converting Data into a CGContext
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
        
        // Rendering the Image
        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        //imageView.image = newImage
        
        return pixelBuffer!
        
    }
    
    // When a photo is captured
    override func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if currentModel == .microsoftVision || currentModel == .microsoftCharacterRecognition {
            super.photoOutput(output, didFinishProcessingPhoto: photo, error: nil)
            return
        }
        
        showIdentificationView()
        
        var requestImage = UIImage()
        
        if let imageData = photo.fileDataRepresentation() {
            capturedImage = UIImage(data: imageData)
            requestImage = capturedImage!
        }
        
        // Freeze Camera View
        analyzedImage.image = self.capturedImage
        
        UIView.animate(withDuration: 0.4) {
            self.analyzedImage.alpha = 1
        }
        
        
        // Process Based on Current User Mode
        switch currentModel {
        // For Inceptionv3
        case .inceptionv3:
            print("Run inceptionv3")
            // Calling MLModel to Predict Image
            guard let prediction = try? inceptionV3.prediction(image: convertImageForCoreML(requestImage, toSize: 299)) else {
                return
            }
            
            if requestImage == capturedImage {
                self.reportAnswer(withAnswer: prediction.classLabel)
            }
            
        // For Resnet50
        case .resnet50:
            print("Run resnet 50")
            // Calling MLModel to Predict Image
            guard let prediction = try? resnet50.prediction(image: convertImageForCoreML(requestImage, toSize: 224)) else {
                return
            }
            
            if requestImage == capturedImage {
                self.reportAnswer(withAnswer: prediction.classLabel)
            }
            
        // For VGG16
        case .vgg16:
            print("Run VGG16")
            // Calling MLModel to Predict Image
            guard let prediction = try? VGG16Model.prediction(image: convertImageForCoreML(requestImage, toSize: 224)) else {
                return
            }
            
            if requestImage == capturedImage {
                self.reportAnswer(withAnswer: prediction.classLabel)
            }
            
        default:
            print("Invalid User Mode")
        }
        
    }
}
