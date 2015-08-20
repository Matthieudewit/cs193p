//
//  ViewController.swift
//  Calculator
//
//  Created by Vojta Molda on 1/26/15.
//  Copyright (c) 2015 Vojta Molda. All rights reserved.
//

import UIKit

extension UILabel {
    
    var value: Double? {
        get {
            return NSNumberFormatter().numberFromString(self.text!) as? Double
        }
        set {
            self.text = newValue != nil ? "\(newValue!)" : " "
        }
    }
}

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
        if userIsInTheMiddleOfTypingANumber && display.value != nil {
            display.value = -display.value!
        } else {
            operate(sender)
        }
    }

    @IBAction func pushConstant(sender: UIButton) {
        let constant = sender.currentTitle!
        enter()
        display.text = constant
        brain.pushOperation(constant)
        history.text = brain.description
    }

    @IBAction func pushMemory(sender: UIButton) {
        let variable = sender.currentTitle!
        enter()
        display.text = variable
        brain.pushVariable(variable)
        history.text = brain.description
    }
    
    @IBAction func setMemory(sender: UIButton) {
        var variable = sender.currentTitle!
        variable.removeAtIndex(variable.startIndex)
        userIsInTheMiddleOfTypingANumber = false
        if let displayValue = display.value {
            brain.variableValues[variable] = displayValue
            display.text = brain.text
            history.text = brain.description+"="
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        enter()
        brain.pushOperation(operation)
        display.text = brain.text
        history.text = brain.description+"="
    }
    
    @IBAction func undo() {
        if userIsInTheMiddleOfTypingANumber {
            if countElements(display.text!) > 1 {
                display.text = dropLast(display.text!)
            } else {
                userIsInTheMiddleOfTypingANumber = false
                display.value = 0
            }
        } else {
            brain.pop()
            display.value = 0
            history.text = brain.description
        }
    }

    @IBAction func clear() {
        userIsInTheMiddleOfTypingANumber = false
        brain.clearAll()
        display.value = 0
        history.text = ""
    }

    @IBAction func enter() {
        if userIsInTheMiddleOfTypingANumber && display.value != nil {
            brain.pushOperand(display.value!)
            history.text = brain.description
        }
        userIsInTheMiddleOfTypingANumber = false
    }

    var operandStack = Array<Double>()
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        println("operandStack = \(operandStack)")
    }
    
    func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
        }
    }

}

