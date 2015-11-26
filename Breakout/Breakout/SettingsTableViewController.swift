//
//  SettingsTableViewController.swift
//  Breakout
//
//  Created by Vojta Molda on 8/1/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var brickRowsStepper: UIStepper!
    @IBOutlet weak var brickRowsStepperLabel: UILabel!
    @IBOutlet weak var brickColumnsStepper: UIStepper!
    @IBOutlet weak var brickColumnsStepperLabel: UILabel!

    @IBOutlet weak var ballSizeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var ballStartAngleSpreadSlider: UISlider!
    struct BallSizeSegmentedControl {
        static var Small = (SegmentIndex: 0, Size: CGFloat(15.0))
        static var Medium = (SegmentIndex: 1, Size: CGFloat(25.0))
        static var Large = (SegmentIndex: 2, Size: CGFloat(40.0))
    }

    @IBOutlet weak var gameContinueAfterGameOverSwitch: UISwitch!

    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        brickRowsStepper.value = Double(AppDelegate.Settings.Brick.Rows)
        brickRowsStepperLabel.text = "\(AppDelegate.Settings.Brick.Rows)"
        brickColumnsStepper.value = Double(AppDelegate.Settings.Brick.Columns)
        brickColumnsStepperLabel.text = "\(AppDelegate.Settings.Brick.Columns)"

        if AppDelegate.Settings.Ball.Size <= BallSizeSegmentedControl.Small.Size {
            ballSizeSegmentedControl.selectedSegmentIndex = BallSizeSegmentedControl.Small.SegmentIndex
        } else if BallSizeSegmentedControl.Large.Size <= AppDelegate.Settings.Ball.Size {
            ballSizeSegmentedControl.selectedSegmentIndex = BallSizeSegmentedControl.Large.SegmentIndex
        } else {
            ballSizeSegmentedControl.selectedSegmentIndex = BallSizeSegmentedControl.Medium.SegmentIndex
        }
        
        gameContinueAfterGameOverSwitch.on = AppDelegate.Settings.Game.ContinueAfterGameOver
    }

    // MARK: - Settings value change handling

    @IBAction func brickRowsStepperValueChanged(sender: UIStepper) {
        let numRows = Int(sender.value)
        brickRowsStepperLabel.text = "\(numRows)";
        AppDelegate.Settings.Brick.Rows = numRows;
    }

    @IBAction func brickColumnsStepperValueChanged(sender: UIStepper) {
        let numColumns = Int(sender.value)
        brickColumnsStepperLabel.text = "\(numColumns)";
        AppDelegate.Settings.Brick.Columns = numColumns;
    }

    @IBAction func ballSizeSegmentedControlValueChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case BallSizeSegmentedControl.Small.SegmentIndex:
            AppDelegate.Settings.Ball.Size = BallSizeSegmentedControl.Small.Size
        case BallSizeSegmentedControl.Medium.SegmentIndex:
            AppDelegate.Settings.Ball.Size = BallSizeSegmentedControl.Medium.Size
        case BallSizeSegmentedControl.Large.SegmentIndex:
            AppDelegate.Settings.Ball.Size = BallSizeSegmentedControl.Large.Size
        default:
            AppDelegate.Settings.Ball.Size = BallSizeSegmentedControl.Medium.Size
        }
    }

    @IBAction func ballStartAngleSpreadSliderValueChanged(sender: UISlider) {
        AppDelegate.Settings.Ball.StartSpreadAngle = CGFloat(sender.value)
    }

    @IBAction func gameContinueAfterGameOverValueChanged(sender: UISwitch) {
        AppDelegate.Settings.Game.ContinueAfterGameOver = sender.on
    }

}
