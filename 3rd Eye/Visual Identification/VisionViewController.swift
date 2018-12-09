//
//  VisionViewController.swift
//  3rd Eye
//
//  Created by Joseph Jin on 11/19/17.
//  Copyright © 2017 WestlakeAPC. All rights reserved.
//

import UIKit
import AVKit
import Vision

class VisionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension VisionViewController: AnalyzeImageDelegate {
    // Analyze Image Delegate Protocal Function
    func finnishedGeneratingObject(_ analyzeImageObject: AnalyzeImage.AnalyzeImageObject) {
        //print(analyzeImageObject)
    }
}
