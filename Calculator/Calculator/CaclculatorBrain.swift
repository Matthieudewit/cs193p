//
//  CaclculatorBrain.swift
//  Calculator
//
//  Created by Vojta Molda on 2/11/15.
//  Copyright (c) 2015 Vojta Molda. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var opStack = [Op]()
    private var knownOps = [String:Op]()

    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                    opStack = newOpStack
                }
            }
        }
    }
    
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }

    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+",  +))
        learnOp(Op.BinaryOperation("-") {$1 - $0})
        learnOp(Op.UnaryOperation("±") { -1 * $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
    }
    
    private func evaluate(var currentOps: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !currentOps.isEmpty {
            let op = currentOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, currentOps)
            case .UnaryOperation(_, let operation):
                let (result, remainingOps) = evaluate(currentOps)
                if let operand = result {
                    return (operation(operand), remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let (result1, remainingOps1) = evaluate(currentOps)
                if let operand1 = result1 {
                    let (result2, remainingOps2) = evaluate(remainingOps1)
                    if let operand2 = result2 {
                        return (operation(operand1, operand2), remainingOps2)
                    }
                }
            }
        }
        return (nil, currentOps)
    }
    
    func evaluate() -> Double? {
        let (result, remainingOps) = evaluate(opStack)
        println("\(opStack) = \(result!) with \(remainingOps) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
}