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
    @IBOutlet var chooseNewModel: UIButton!
    @IBOutlet var blurEffect: UIVisualEffectView!
    @IBOutlet var identificationView: UIView!
    @IBOutlet var identificationText: UILabel!
    @IBOutlet var loadIndicator: UIActivityIndicatorView!
    @IBOutlet var analyzedImage: UIImageView!
    @IBOutlet var modeButtons: [UIButton]!
    
    
    var effect: UIVisualEffect!
    
    let synth = AVSpeechSynthesizer()
    
    var currentModel = RecognitionModel.microsoftAnalyze
    
    let ocr = CognitiveServices.sharedInstance.ocr
    
    var identificationPending = false
    var showingResultView = false
    var showingModelOptions = false
    
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
        analyzedImage.alpha = 0
    }
    
    // Show Model Options
    @IBAction func changeUserMode(_ sender: Any) {
        if identificationPending || showingResultView { return }
        
        if !showingModelOptions {
            let _ = "Select a mode".speak()
        }
        
        modeButtons.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                
                if button.alpha == 0 {
                    button.alpha = 1
                    self.showingModelOptions = true
                } else if button.alpha == 1 {
                    button.alpha = 0
                    self.showingModelOptions = false
                }
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // When Selecting New Model
    @IBAction func modeSelected(_ sender: Any) {
        guard let option = (sender as! UIButton).currentTitle, let model = RecognitionModel(rawValue: option) else {
            return
        }
        
        let _ = "Switching to \(option)".speak()
        currentModel = model
        changeUserMode(self)
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
        
        showingResultView = true
        captureButton.isEnabled = false
        chooseNewModel.isEnabled = false
        
    }
    
    // Hide or Dismiss Identification
    func hideIdentificationView() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.identificationView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.identificationView.alpha = 0
            
            self.analyzedImage.alpha = 0
            
            self.blurEffect.effect = nil
            
        }) { (success:Bool) in
            self.identificationView.removeFromSuperview()
        }
        
        showingResultView = false
        captureButton.isEnabled = true
        chooseNewModel.isEnabled = true
    }
    
    @IBAction func dismissIDView(_ sender: Any) {
        if !identificationPending && showingResultView {
            hideIdentificationView()
        } else if identificationPending && showingResultView {
            let _ = "Identification cancelled".speak()
            identificationPending = false
            hideIdentificationView()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !showingResultView {
            makeRequest(self)
        } else {
            dismissIDView(self)
        }
    }
    
    // Make a request
    @IBAction func makeRequest(_ sender: Any) {
        if identificationPending {return}
        
        if sender as? UIButton == captureButton {
            captureButton.flash()
        }
        
        if showingModelOptions {
            changeUserMode(self)
        }
        
        identificationPending = true
        self.guessLabel.text = "Pending..."
        self.identificationText.isHidden = true
        self.loadIndicator.startAnimating()
        self.loadIndicator.isHidden = false
        
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    // Exit View
    @IBAction func exitView(_ sender: Any) {
        let _ = "Exiting camera view".speak()
        
        self.dismiss(animated: true) {
            self.identificationPending = false
            self.captureSession.stopRunning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension VisualSupportViewController: AVCapturePhotoCaptureDelegate {
    
    // When a photo is captured
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        let _ = "Identifying".speak()
        
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
            
        // For current mode as Analyze Image
        case .microsoftAnalyze:
            
            // Analyze Image
            let analyzeImage = CognitiveServices.sharedInstance.analyzeImage
            analyzeImage.delegate = self
            
            let visualFeatures: [AnalyzeImage.AnalyzeImageVisualFeatures] = [.Categories, .Description, .Faces, .ImageType, .Color, .Adult]
            let requestObject: AnalyzeImageRequestObject = (capturedImage!, visualFeatures)
            
            do {
                // Read in Result
                try analyzeImage.analyzeImageWithRequestObject(requestObject, completion: { (response) in
                    DispatchQueue.main.async(execute: {
                        
                        if self.identificationPending && requestImage.isEqual(self.capturedImage) {
                            
                            if response?.descriptionText == "" {
                                let _ = "No object identified".speak()
                            }
                            
                            self.guessLabel.text = response?.descriptionText
                            self.identificationText.text = response?.descriptionText
                            self.identificationText.isHidden = false
                            self.loadIndicator.stopAnimating()
                            self.loadIndicator.isHidden = true
                            self.identificationPending = false
                            
                            let _ = response?.descriptionText?.speak()
                            
                        } else {
                            print("Dismissing Response \(Date()) + \(response!.descriptionText!)")
                        }
                    })
                })
            } catch {
                self.guessLabel.text = "An Error Occured"
                self.identificationText.text = "An Error Occured"
                self.identificationPending = false
            }

        // For current mode as OCR
        case .microsoftOCR:
            print("Run OCR")
            let resizedImage = requestImage.resized(withPercentage: 0.25)
            
            let requestObject: OCRRequestObject = (resource: UIImagePNGRepresentation(resizedImage!)!, language: .English, detectOrientation: true)
            
            print("Resized Image Size \(String(describing: resizedImage?.size.width)) X \(String(describing: resizedImage?.size.height))")
            
            try! ocr.recognizeCharactersWithRequestObject(requestObject, completion: { (response) in
                if (response != nil){
                    if self.identificationPending && requestImage.isEqual(self.capturedImage) {
                        
                        let text = self.ocr.extractStringFromDictionary(response!)
                        
                        if text == "" {
                            let _ = "No text identified".speak()
                        }
                        
                        self.guessLabel.text = text
                        self.identificationText.text = text
                        self.identificationText.isHidden = false
                        self.loadIndicator.stopAnimating()
                        self.loadIndicator.isHidden = true
                        self.identificationPending = false
                        
                        let _ = text.speak()
                        
                    } else {
                        print("Dismissing Response \(Date()) + \(response!.description)")
                    }
                }
            })
            
        default:
            print("Invalid User Mode")
        }
        
    }
}

