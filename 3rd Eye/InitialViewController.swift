//
//  InitialViewController.swift
//  3rd Eye
//
//  Created by Joseph Jin on 10/8/17.
//  Copyright © 2017 WestlakeAPC. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var userModeButton: UIButton!
    
    var currentUserMode = UserMode.visualSupport
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Change Mode
    @IBAction func changeMode(_ sender: Any) {
        switch currentUserMode {
        case .visualSupport:
            currentUserMode = .developer
            userModeButton.setTitle("Enter as Developer", for: UIControlState.normal)
            break
        case .developer:
            currentUserMode = .visualSupport
            userModeButton.setTitle("Enter as Visually Impared", for: UIControlState.normal)
            break
        default:
            print("Error Switching Modes")
        }
    }
    
    @IBAction func beginButton(_ sender: Any) {
        switch currentUserMode {
        case .visualSupport:
            self.performSegue(withIdentifier: "bringToVisualSupportView", sender: nil)
            break
        case .developer:
            self.performSegue(withIdentifier: "bringToDeveloperView", sender: nil)
            break
        default:
            print("[InitialViewController] Invalid user mode")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
