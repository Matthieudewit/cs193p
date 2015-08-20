//
//  CaclculatorBrain.swift
//  Calculator
//
//  Created by Vojta Molda on 2/11/15.
//  Copyright (c) 2015 Vojta Molda. All rights reserved.
//

import Foundation

class CalculatorBrain: Printable {
    
    private enum Op: Printable {
        case Operand(Double)
        case Variable(String)
        case Constant(String, () -> Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let variable):
                    return variable
                case .Constant(let constant, _):
                    return constant
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = [String:Op]()
    
    var variableValues = [String:Double]()
    var description: String {
        get {
            var returnDesc = ""
            var returnOps = opStack
            do {
                let (additionalDesc, additionalOps) = describe(returnOps)
                returnDesc = returnDesc.isEmpty ? additionalDesc : additionalDesc+", "+returnDesc
                returnOps = additionalOps
            } while !returnOps.isEmpty
            return returnDesc
        }
    }
    var program: AnyObject {
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

    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.Constant("π") {return M_PI})
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+",  +))
        learnOp(Op.BinaryOperation("−") {$1 - $0})
        learnOp(Op.UnaryOperation("±") { -$0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
    }
    
    private func describe(var currentOps: [Op]) -> (description: String, remainingOps: [Op]) {
        if !currentOps.isEmpty {
            let op = currentOps.removeLast()
            switch op  {
            case .Operand:
                return (op.description, currentOps)
            case .Variable:
                return (op.description, currentOps)
            case .Constant:
                return (op.description, currentOps)
            case .UnaryOperation:
                let (operandDesc, remainingOps) = describe(currentOps)
                return ( op.description+"("+operandDesc+")", remainingOps)
            case .BinaryOperation:
                let (operandDesc1, remainingOps1) = describe(currentOps)
                let (operandDesc2, remainingOps2) = describe(remainingOps1)
                return ("("+operandDesc2+op.description+operandDesc1+")", remainingOps2)
            }
        }
        return ("?", currentOps)
    }
    
    private func evaluate(var currentOps: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !currentOps.isEmpty {
            let op = currentOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, currentOps)
            case .Variable(let variable):
                return (variableValues[variable], currentOps)
            case .Constant(_, let operation):
                return (operation(), currentOps)
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
        println("\(opStack) = \(result ?? 0) with \(remainingOps) left over")
        return result
    }

    func evaluateOperand(operand: Double) -> Double? {
        pushOperand(operand)
        return evaluate()
    }
    
    func evaluateVariable(variable: String) -> Double? {
        pushVariable(variable)
        return evaluate()
    }
    
    func evaluateOperation(symbol: String) -> Double? {
        pushOperation(symbol)
        return evaluate()
    }
    
    func pushOperand(operand: Double) {
        opStack.append(Op.Operand(operand))
    }
    
    func pushVariable(variable: String) {
        opStack.append(Op.Variable(variable))
    }
    
    func pushOperation(symbol: String) {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
    }
    
    func clear() {
        opStack.removeAll(keepCapacity: true)
    }
}