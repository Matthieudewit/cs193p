//
//  ViewController.swift
//  Calculator
//
//  Created by Vojta Molda on 1/26/15.
//  Copyright (c) 2015 Vojta Molda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var brain = CalculatorBrain()
    var userIsInTheMiddleOfTypingANumber = false

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        display.text = userIsInTheMiddleOfTypingANumber ? display.text! + digit : digit
        userIsInTheMiddleOfTypingANumber = true
    }

    @IBAction func appendPeriod(sender: UIButton) {
        if display.text!.rangeOfString(".") == nil {
            appendDigit(sender)
        }
    }
    
    @IBAction func appendSign(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber && displayValue != nil {
            displayValue = -displayValue!
            userIsInTheMiddleOfTypingANumber = true
        } else {
            operate(sender)
        }
    }

    @IBAction func pushConstant(sender: UIButton) {
        let constant = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber { enter() }
        display.text = constant
        brain.pushOperation(constant)
        history.text = brain.description
    }

    @IBAction func pushMemory(sender: UIButton) {
        let variable = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber { enter() }
        display.text = variable
        brain.pushVariable(variable)
        history.text = brain.description
    }
    
    @IBAction func setMemory(sender: UIButton) {
        var variable = sender.currentTitle!
        variable.removeAtIndex(variable.startIndex)
        if displayValue != nil {
            brain.variableValues[variable] = displayValue!
            displayValue = brain.evaluate()
            history.text = brain.description+"="
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber { enter() }
        displayValue = brain.evaluateOperation(operation)
        history.text = brain.description+"="
    }
    
    @IBAction func backspace() {
        if !userIsInTheMiddleOfTypingANumber { return }
        if countElements(display.text!) > 1 {
            display.text = dropLast(display.text!)
        } else {
            userIsInTheMiddleOfTypingANumber = false
            displayValue = 0
        }
    }

    @IBAction func clear() {
        userIsInTheMiddleOfTypingANumber = false
        brain.variableValues.removeAll(keepCapacity: true)
        history.text = "";
        brain.clear()
        displayValue = 0;
    }

    @IBAction func enter() {
        if displayValue != nil {
            displayValue = brain.evaluateOperand(displayValue!)
        }
        history.text = brain.description
    }

    var operandStack = Array<Double>()
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        println("operandStack = \(operandStack)")
    }
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            userIsInTheMiddleOfTypingANumber = false
            display.text = newValue != nil ? "\(newValue!)" : " "
        }
    }

}

