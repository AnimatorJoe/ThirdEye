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

class VisualSupportViewController: VisionViewController, AVCapturePhotoCaptureDelegate{
    
    @IBOutlet var guessLabel: UILabel!
    let synth = AVSpeechSynthesizer()
    var requestToast: UIView!
    
    let currentModel = RecognitionModel.microsoftAnalyze
    var identificationRequested = false
    
    var captureSession = AVCaptureSession()
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var capturedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Entering Visual Support View")
        
        setupCaptureSession()
        startSession()
    }
    
    // Setup Capture Session
    func setupCaptureSession(){
        // Create Session
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        // Choose Device
        let deciveDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        let devices = deciveDiscoverySession.devices
        
        var backCamera: AVCaptureDevice?
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            }
        }
        
        // Set Input and Output
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: backCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
        
        // Set up preview layer
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = .resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = .portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    // Start Session
    func startSession(){
        captureSession.startRunning()
    }
    
    // Make a request
    @IBAction func makeRequest(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    // When a photo is captured
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            capturedImage = UIImage(data: imageData)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
