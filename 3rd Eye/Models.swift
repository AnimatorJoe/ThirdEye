//
//  Model.swift
//  3rd Eye
//
//  Created by Joseph Jin on 11/16/17.
//  Copyright © 2017 WestlakeAPC. All rights reserved.
//

import Foundation

enum RecognitionModel: String {
    
    case inceptionv3 = "Inceptionv3"
    case resnet50 = "Resnet50"
    case vgg16 = "VGG16"
    
    case microsoftAnalyze = "Analyze Objects"
    case microsoftOCR = "Analyze Text"
    case aws = "Amazon"
}

enum VoiceModel {
    case native, aws, watson
}
