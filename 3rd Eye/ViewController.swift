//
//  ViewController.swift
//  3rd Eye
//
//  Created by Joseph Jin on 10/5/17.
//  Copyright © 2017 WestlakeAPC. All rights reserved.
//

import UIKit
import AVKit
import Vision
import Toast_Swift

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet var guessLabel: UILabel!
    let synth = AVSpeechSynthesizer()
    var requestedIdentification = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.makeToast("Tap to Request and Identification", duration: 5, position: .center)
        setCameraAccess()
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
        
        view.addSubview(guessLabel)
        
        
        // Extractiong and analysing image
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    // Called everytime camera updates frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //print("Capturing frame at \(Date())")
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: VGG16().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            DispatchQueue.main.async {
                self.guessLabel.text = """
                    Guess: \(firstObservation.identifier)
                    Confidence: \(firstObservation.confidence * 100)%
                """
                if (firstObservation.confidence * 100 > 70 && self.requestedIdentification){
                    let speech = AVSpeechUtterance(string: firstObservation.identifier)
                    speech.rate = 0.25
                    speech.pitchMultiplier = 0.25
                    speech.volume = 0.75
                
                    self.synth.speak(speech)
                    self.requestedIdentification = false
                }
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        requestedIdentification = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

