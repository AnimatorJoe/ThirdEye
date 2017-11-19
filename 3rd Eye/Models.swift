//
//  Model.swift
//  3rd Eye
//
//  Created by Joseph Jin on 11/16/17.
//  Copyright © 2017 WestlakeAPC. All rights reserved.
//

import Foundation

enum RecognitionModel {
    case coreMLInceptionv3, coreMLResnet50, coreMLVGG16, microsoftAnalyze, microsoftOCR, aws
}

enum VoiceModel {
    case native, aws, watson
}
