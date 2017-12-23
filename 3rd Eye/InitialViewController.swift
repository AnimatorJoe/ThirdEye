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
    @IBOutlet var beginButton: UIButton!
    
    var isInitiallyShown = true
    var elementsLoaded = false
    
    var currentUserMode = UserMode.visualSupport
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isInitiallyShown {
            // Perform an action that will only be done once
            isInitiallyShown = false
            
            let _ = "Welcom to Visualize".speak()
            
            UIView.animate(withDuration: 1, animations: {
                self.welcomeLabel.alpha = 1
                
            }, completion: { (val) in

                let _ = "Tap Anywhere to Begin".speak()
                
                UIView.animate(withDuration: 0.4, animations: {
                    
                    self.userModeButton.alpha = 1
                    self.beginButton.alpha = 1
                    
                }, completion: { (val) in
                    self.elementsLoaded = true
                })
            })
        }
        
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
        if !elementsLoaded {return}
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        beginButton(self)
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
