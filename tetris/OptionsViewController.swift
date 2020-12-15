//
//  OptionsViewController.swift
//  EID: wl8779
//  Course: CS371L
//
//  Created by user174376 on 7/9/20.
//  Copyright © 2020 top. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {

    @IBOutlet weak var tickLbl: UILabel!
    @IBOutlet weak var tickSlider: UISlider!
    @IBOutlet weak var pauseSegCtrl: UISegmentedControl!
    @IBOutlet weak var tapsSegCtrl: UISegmentedControl!
    @IBOutlet weak var mirrorSegCtrl: UISegmentedControl!
    
    var tickValue = Mino.tickRate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let font: [NSAttributedString.Key : Any] =
            [.font : UIFont(name: "HelveticaNeue-Italic", size: 20)!]
        pauseSegCtrl.setTitleTextAttributes(font, for: .normal)
        tapsSegCtrl.setTitleTextAttributes(font, for: .normal)
        mirrorSegCtrl.setTitleTextAttributes(font, for: .normal)
        
        tickLbl.text = String(format: "%.1f", tickValue)
        tickSlider.value = Float(Mino.tickRate)
        pauseSegCtrl.selectedSegmentIndex = PlayViewController.pausingEnabled ? 0 : 1
        tapsSegCtrl.selectedSegmentIndex = PlayViewController.tapsToPause - 1
        mirrorSegCtrl.selectedSegmentIndex = PlayViewController.isMirrored ? 0 : 1
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Mino.tickRate = tickValue
        PlayViewController.pausingEnabled = pauseSegCtrl.selectedSegmentIndex == 0
        PlayViewController.tapsToPause = tapsSegCtrl.selectedSegmentIndex + 1
        PlayViewController.isMirrored = mirrorSegCtrl.selectedSegmentIndex == 0
    }
    
    @IBAction func tickChanged(_ sender: UISlider) {
        tickValue = Double(round(sender.value / 0.1) * 0.1)
        sender.value = Float(tickValue)
        tickLbl.text = String(format: "%.1f", tickValue)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
