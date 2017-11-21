//
//  Model.swift
//  3rd Eye
//
//  Created by Joseph Jin on 11/16/17.
//  Copyright © 2017 WestlakeAPC. All rights reserved.
//

import Foundation

enum RecognitionModel {
    enum CoreMLModel {
        case inceptionv3
        case resnet50
        case vgg16
    }
    
    case coreML(CoreMLModel)
    case microsoftAnalyze, microsoftOCR, aws
}

enum VoiceModel {
    case native, aws, watson
}
