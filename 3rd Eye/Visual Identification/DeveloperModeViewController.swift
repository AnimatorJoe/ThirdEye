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

class DeveloperModeViewController: VisionViewController{
    
    @IBOutlet var guessLabel: UILabel!
    let synth = AVSpeechSynthesizer()
    var identificationRequested = false
    var requestToast: UIView!
    
    let currentModel = RecognitionModel.microsoftAnalyze
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Entering Developer View")
        setCameraAccess()
        view.addSubview(guessLabel)
        promptForRequest()
    }
    
    // Set up camera access
    func setCameraAccess() {
        
        // Set up capture session
        let captureSession = AVCaptureSession()
        //captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        // Show camera input to view
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        
        view.layer.addSublayer(previewLayer)
        
        // Extractiong and analysing image
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    // Called everytime camera updates frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if currentModel == RecognitionModel.coreML(.resnet50) {
            
            
            if !identificationRequested { return }
            
            //print("Capturing frame at \(Date())")
            
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
            
            let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
                guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
                
                // Obtain best guess
                guard let firstObservation = results.first else { return }
                
                print(firstObservation.identifier, firstObservation.confidence)
                
                // Present Guess
                DispatchQueue.main.async {
                    if (firstObservation.confidence * 100 > 50 && self.identificationRequested){
                        self.guessLabel.text = """
                        Guess: \(firstObservation.identifier)
                        Confidence: \(firstObservation.confidence * 100)%
                        """
                        
                        print("Say: \(firstObservation.identifier)")
                        
                        let _ = firstObservation.identifier.speak()
                        
                        self.promptForRequest()
                        
                    }
                }
                
            }
            
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        }
        
    }
    
    // Ask for a reuqest
    func promptForRequest() {
        self.identificationRequested = false
        do {
            requestToast = try self.view.toastViewForMessage("Tap to Request an Identification", title: nil, image: nil, style: ToastManager.shared.style)
        } catch {
            return
        }
        
        self.view.showToast(requestToast, duration: 5, position: .center, completion: nil)
    }
    
    // When a Request in Made
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.synth.isSpeaking || identificationRequested {return}
        
        identificationRequested = true
        self.guessLabel.text = "Requesting..."
        
        self.view.hideToast(requestToast)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



