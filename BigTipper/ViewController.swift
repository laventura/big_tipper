//
//  ViewController.swift
//  BigTipper
//
//  Created by Atul Acharya on 8/23/17.
//  Copyright © 2017 Atul Acharya. All rights reserved.
//

import UIKit

let SETTINGS_CHANGED_NOTIFICATION = Notification.Name("Settings.Changed.Notification")


class ViewController: UIViewController {
    
    // MARK: - Props
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalBillLabel: UILabel!
    @IBOutlet weak var tipControl: UISegmentedControl!
    
    @IBOutlet weak var splitValueLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    let formatter = NumberFormatter()
    
    // Various Tip Rates
    let tipRate = [ 0.15, 0.18,
                    0.2, 0.22, 0.25]
    
    var currentTipRate = 0.18
    
    // number of people in the party to split
    let pickerData = [
        1, 2, 3, 4, 5,
        6, 7, 8, 9, 10,
        11, 12, 13, 14, 15,
        16, 17, 18, 19, 20,
        21, 22, 23, 24, 25,
        26, 27, 28, 29, 30]
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // currency formatting
        formatter.numberStyle = .currency
        formatter.locale = NSLocale.current
        
        // Notification - listen to change in Settings

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.settingsChangedNotification(notification:)),
                                               name: SETTINGS_CHANGED_NOTIFICATION,
                                               object: nil)
        
        // get Defaults from stored Defaults
        let defaults = UserDefaults.standard
        
        if let selectedIndex = defaults.value(forKey: "selectedIndex") as? Int,
            let selectedRate = defaults.value(forKey: "selectedRate") as? String
        {
            tipControl.selectedSegmentIndex = selectedIndex
            print("selected rate: \(selectedRate)")
        } else {
            tipControl.selectedSegmentIndex = 1 // 18% tip
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set text attribs
        configUI()
        
        // picker view delegate / source
        pickerView.dataSource   = self
        pickerView.delegate     = self
        
        currentTipRate = tipRate[tipControl.selectedSegmentIndex]
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: SETTINGS_CHANGED_NOTIFICATION,
                                                  object: nil)
    }
    
    // CONFIG 
    func configUI()
    {
        // TODO
    }

    
    // MARK: - Actions
    @IBAction func tipRateChanged(sender: UISegmentedControl) {
        // get current tip rate
        currentTipRate = tipRate[tipControl.selectedSegmentIndex]
        
        // perform calculation
        doCalculateSplit()
    }
    
    @IBAction func onTapGesture(_ sender: UITapGestureRecognizer) {
        // disable keyboard
        view.endEditing(true)
    
    }
    
    @IBAction func billChanged(_ sender: UITextField) {
        // trigger bill calculation
        doCalculateSplit()
    }

    // Segue to SettingsVC
    @IBAction func onSettingsClicked(_ sender: UIBarButtonItem) {
        // TODO -- segue or create a new VC
        print("settings clicked!")
        
        let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController")
        
        // presentationVC
        let presentationController = AACustomPresentationController(presentedViewController: settingsVC!, presenting: self)
        // set transitioning delegate
        settingsVC!.transitioningDelegate = presentationController
        // do segue
        self.present(settingsVC!,
                     animated: true) { 
                        let _ = presentationController
        }
    }
    
    // MARK: - Calculations
    // Calculate Tip
    func doCalculateSplit()
    {
        // 
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        
        let numPeople = selectedRow < 0 ? 1 : pickerData[selectedRow]
        
        calculateTipForSplit(numPeople: numPeople)
    }
    
    // Calculate Tip, Total Bill and Split between Number of People
    func calculateTipForSplit(numPeople: Int)
    {
        // TODO
        let bill = Double(billField.text!) ?? 0
        
        let tip  = bill * currentTipRate
        
        let total = tip + bill
        
        let perPersonSplit = total / Double(numPeople)
        
        tipLabel.text = formatter.string(from: tip as NSNumber) // tip
        totalBillLabel.text = formatter.string(from: total as NSNumber) // total Bill
        splitValueLabel.text = formatter.string(from: perPersonSplit as NSNumber)
        
    }
    
    // MARK: - Notification
    // When Tip Rate is changed in Settings
    func settingsChangedNotification(notification: Notification) {
        
        if let theIndex = notification.userInfo?["selectedIndex"] as? Int {
            tipControl.selectedSegmentIndex = theIndex
            
            // run calculation again
            tipRateChanged(sender: tipControl)
        }
    }

}

// MARK: - Picker View
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource
{
    // Data Source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // Delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerData[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let numPeople = pickerData[row]
        calculateTipForSplit(numPeople: numPeople)
    }
    
} // extension
