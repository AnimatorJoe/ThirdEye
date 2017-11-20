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

class VisualSupportViewController: VisionViewController {
    
    @IBOutlet var guessLabel: UILabel!
    @IBOutlet var captureButton: UIButton!
    @IBOutlet var blurEffect: UIVisualEffectView!
    @IBOutlet var identificationView: UIView!
    @IBOutlet var identificationText: UILabel!
    @IBOutlet var loadIndicator: UIActivityIndicatorView!
    
    var effect: UIVisualEffect!
    
    let synth = AVSpeechSynthesizer()
    
    let currentModel = RecognitionModel.microsoftAnalyze
    var identificationPending = false
    
    var captureSession = AVCaptureSession()
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var capturedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Entering Visual Support View")
        
        setBlur()
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
    
    // Setup Blur Effect
    func setBlur() {
        effect = blurEffect.effect
        blurEffect.effect = nil
    }
    
    // Show Identification
    func showIdentificationView() {
        
        self.view.addSubview(identificationView)
        identificationView.center = self.view.center
        
        identificationView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        identificationView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.blurEffect.effect = self.effect
            
            self.identificationView.alpha = 1
            self.identificationView.transform = CGAffineTransform.identity
        }
        
        captureButton.isEnabled = false
        
    }
    
    // Hide or Dismiss Identification
    func hideIdentificationView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.identificationView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.identificationView.alpha = 0
            
            self.blurEffect.effect = nil
            
        }) { (success:Bool) in
            self.identificationView.removeFromSuperview()
        }
        
        captureButton.isEnabled = true
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !identificationPending && blurEffect.effect != nil{
            hideIdentificationView()
        } else if identificationPending && blurEffect.effect != nil {
            identificationPending = false
            hideIdentificationView()
        }
    }
    
    // Make a request
    @IBAction func makeRequest(_ sender: Any) {
        if identificationPending {return}
        
        captureButton.flash()
        showIdentificationView()
        
        identificationPending = true
        self.guessLabel.text = "Pending..."
        self.identificationText.isHidden = true
        self.loadIndicator.startAnimating()
        self.loadIndicator.isHidden = false
        
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension VisualSupportViewController: AVCapturePhotoCaptureDelegate {
    
    // When a photo is captured
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            capturedImage = UIImage(data: imageData)
        }
        
        // Analyze Image
        let analyzeImage = CognitiveServices.sharedInstance.analyzeImage
        analyzeImage.delegate = self
        
        let visualFeatures: [AnalyzeImage.AnalyzeImageVisualFeatures] = [.Categories, .Description, .Faces, .ImageType, .Color, .Adult]
        let requestObject: AnalyzeImageRequestObject = (capturedImage!, visualFeatures)
        
        do {
            // Read in Result
            try analyzeImage.analyzeImageWithRequestObject(requestObject, completion: { (response) in
                DispatchQueue.main.async(execute: {
                    if self.identificationPending {
                        self.guessLabel.text = response?.descriptionText
                        self.identificationText.text = response?.descriptionText
                        self.identificationText.isHidden = false
                        self.loadIndicator.stopAnimating()
                        self.loadIndicator.isHidden = true
                        self.identificationPending = false
                    }
                })
            })
        } catch {
            self.guessLabel.text = "An Error Occured"
            self.identificationText.text = "An Error Occured"
            self.identificationPending = false
        }
        
    }
}

extension VisionViewController: AnalyzeImageDelegate {
    // Analyze Image Delegate Protocal Function
    func finnishedGeneratingObject(_ analyzeImageObject: AnalyzeImage.AnalyzeImageObject) {
        print(analyzeImageObject)
    }
 }
