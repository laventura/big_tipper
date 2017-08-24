//
//  SettingsViewController.swift
//  BigTipper
//
//  Created by Atul Acharya on 8/23/17.
//  Copyright © 2017 Atul Acharya. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tipControl: UISegmentedControl!
    
    @IBOutlet weak var slider: UISlider!

    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = UIColor(red: 91/255.0, green: 184/255.0, blue: 90/255.0, alpha: 1.0)
        
        // 1 - 
        let defaults = UserDefaults.standard
        
        if let selectedIndex = defaults.value(forKey: "selectedIndex") as? Int {
            tipControl.selectedSegmentIndex = selectedIndex
        } else {
            tipControl.selectedSegmentIndex = 1 // 18%
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.updatePreferredContentSizeWithTraitCollection(self.traitCollection)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        // When the current trait collection changes (e.g. the device rotates),
        // update the preferredContentSize.
        self.updatePreferredContentSizeWithTraitCollection(newCollection)
    }
    
    // Update its preferredContentSize
    func updatePreferredContentSizeWithTraitCollection(_ traitCollection: UITraitCollection) {
        
        self.preferredContentSize = CGSize(width: self.view.bounds.size.width,
                                           height: traitCollection.verticalSizeClass == .compact ? 270 : 400)
        
        // Dragging this slider updates
        // the preferredContentSize of this view controller in real time.
        //
        // Update the slider with appropriate min/max values and reset the
        // current value to reflect the changed preferredContentSize.
        self.slider.maximumValue = Float(self.preferredContentSize.height)
        self.slider.minimumValue = 220.0
        self.slider.value = self.slider.maximumValue
    }
    
    
    // MARK: - Actions
    
    @IBAction func tipRateChanged(_ sender: UISegmentedControl) {
        // when tip rate changed, fire a notification
        
        // 1 - 
        let selectedIndex   = tipControl.selectedSegmentIndex
        let selectedRate    = tipControl.titleForSegment(at: selectedIndex)
        
        // 2 - save tip rate to UserDefaults
        let defaults = UserDefaults.standard
        defaults.set(selectedIndex, forKey: "selectedIndex")
        defaults.set(selectedRate, forKey: "selectedRate")
        defaults.synchronize()
        
        // 3 -  notification data -- Only the index is sent!
        let notificationData: [String:Int] = ["selectedIndex": selectedIndex]
        // 4 - send notification
        NotificationCenter.default.post(name: SETTINGS_CHANGED_NOTIFICATION,
                                        object: self,
                                        userInfo: notificationData)
        
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        // print("Settings: Slider value changed to: \(sender.value)")
        // change the height of this View Controller
        self.preferredContentSize = CGSize(width: self.view.bounds.size.width,
                                           height: CGFloat(sender.value))
    }
    
    //| ----------------------------------------------------------------------------
    //! Action for unwinding from the presented view controller (C).
    //
    @IBAction func unwindToCustomPresentationSecondViewController(_ sender: UIStoryboardSegue) {
    }
    


}
