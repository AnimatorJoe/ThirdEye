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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.performSegue(withIdentifier: "bringToCameraView", sender: nil)
    }
    
    @IBAction func beginButton(_ sender: Any) {
        self.performSegue(withIdentifier: "bringToCameraView", sender: nil)
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
