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
    
    var userIsInTheMiddleOfTypingANumber = false
    var operandStack = Array<Double>()

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        switch digit {
        case "π":
            if userIsInTheMiddleOfTypingANumber { enter() }
            displayValue = M_PI
        case ".":
            if display.text!.rangeOfString(digit) != nil { return }
            fallthrough
        default:
            display.text = userIsInTheMiddleOfTypingANumber ? display.text! + digit : digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }

    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if operation == "±" {
            if userIsInTheMiddleOfTypingANumber {
                displayValue = -1.0 * displayValue!
            }
        }
        if userIsInTheMiddleOfTypingANumber { enter() }
        history.text! += operation + "|"
        switch operation {
        case "×": performOperation({ (op1: Double, op2:Double) -> Double in return op2 * op1 })
        case "÷": performOperation({ (op1, op2) in return op2 / op1 })
        case "+": performOperation({ $1 + $0 })
        case "−": performOperation() { $1 - $0 }
        case "√": performOperation { sqrt($0) }
        case "sin": performOperation { sin($0) }
        case "cos": performOperation { cos($0) }
        default: break
        }
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTypingANumber { return }
        if countElements(display.text!) > 1 {
            display.text = dropLast(display.text!)
        } else {
            userIsInTheMiddleOfTypingANumber = false
            display.text = "0"
        }
    }

    @IBAction func clear() {
        userIsInTheMiddleOfTypingANumber = false
        operandStack = [];
        display.text = "0";
        history.text = "";
        displayValue = 0;
    }

    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        history.text! += display.text! + "|"
        println("operandStack = \(operandStack)")
    }
    
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
        }
    }
    
    func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
        }
    }

    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!) as? Double
        }
        set {
            userIsInTheMiddleOfTypingANumber = false
            display.text = "\(newValue)"
            enter()
        }
    }

}

