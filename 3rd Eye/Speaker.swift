//
//  Speaker.swift
//  3rd Eye
//
//  Created by Joseph Jin on 12/8/18.
//  Copyright © 2018 WestlakeAPC. All rights reserved.
//

import Foundation
import AVFoundation

class Speaker {
    
    static let audioSession = AVAudioSession.sharedInstance()
    
    static var speechSynthesizer = AVSpeechSynthesizer()
    
    static let defaultVoice = AVSpeechSynthesisVoice(language: "en-US")
    
    static func speak(_ text: String) {
        
        try! audioSession.setCategory(AVAudioSessionCategoryPlayback)
        try! audioSession.setActive(true)
        
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = defaultVoice
        
        speechSynthesizer.speak(speechUtterance)
        
    }
    
    static func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
}
