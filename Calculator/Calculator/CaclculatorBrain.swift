//
//  CaclculatorBrain.swift
//  Calculator
//
//  Created by Vojta Molda on 2/11/15.
//  Copyright (c) 2015 Vojta Molda. All rights reserved.
//

import Foundation

class CalculatorBrain: CustomStringConvertible {
    
    fileprivate enum Op: CustomStringConvertible {
        case operand(Double)
        case variable(String)
        case constant(String,
                value: Double)
        case unaryOperation(String,
                evaluate: (Double) -> Double,
                reportError: ((Double) -> String?)?)
        case binaryOperation(String,
                precedence: Int,
                evaluate: (Double, Double) -> Double,
                reportError: ((Double, Double) -> String?)?)
        
        var description: String {
            get {
                switch self {
                case .operand(let operand):
                    return "\(operand)"
                case .variable(let variable):
                    return variable
                case .constant(let constant, _):
                    return constant
                case .unaryOperation(let symbol, _, _):
                    return symbol
                case .binaryOperation(let symbol, _, _, _):
                    return symbol
                }
            }
        }
    }
    enum ValueOrError: CustomStringConvertible {
        case value(Double)
        case error(String)
      
        var description: String {
            get {
                switch self {
                case .value(let value):
                    return "\(value)"
                case .error(let error):
                    return error
                }
            }
        }
    }
    
    fileprivate var opStack = [Op]()
    fileprivate var knownOps = [String:Op]()
    
    var variableValues = [String:Double]()
    var text: String {
        return self.evaluateAndReportErrors().description
    }
    var description: String {
        get {
            var returnDesc = ""
            var returnOps = opStack
            repeat {
                let (additionalDesc, additionalOps) = describe(returnOps)
                returnDesc = returnDesc.isEmpty ? additionalDesc : additionalDesc+", "+returnDesc
                returnOps = additionalOps
            } while !returnOps.isEmpty
            return returnDesc
        }
    }
    var descriptionOfLastTerm: String {
        get {
            let (description, _) = describe(opStack)
            return description
        }
    }
    var program: AnyObject {
        get {
            return opStack.map { $0.description } as AnyObject
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NumberFormatter().number(from: opSymbol)?.doubleValue {
                        newOpStack.append(.operand(operand))
                    } else {
                        newOpStack.append(.variable(opSymbol))
                    }
                    opStack = newOpStack
                }
            }
        }
    }

    init() {
        func learnOp(_ op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.constant("π",
                value: M_PI))
        learnOp(Op.unaryOperation("±",
                evaluate: { -$0 },
                reportError: nil))
        learnOp(Op.unaryOperation("sin",
                evaluate: { sin($0) },
                reportError: nil))
        learnOp(Op.unaryOperation("cos",
                evaluate: { cos($0) },
                reportError: nil))
        learnOp(Op.unaryOperation("√",
                evaluate: { sqrt($0) },
                reportError: { op1 in op1 < 0.0 ? "Square root of negative value!" : nil }))
        learnOp(Op.binaryOperation("×",
                precedence: 150,
                evaluate: { $1*$0 },
                reportError: nil))
        learnOp(Op.binaryOperation("÷",
                precedence: 150,
            evaluate: { $1/$0 },
            reportError: { op1, op2 in op1 == 0.0 ? "Division by zero!" : nil }))
        learnOp(Op.binaryOperation("+",
                precedence: 140,
                evaluate: { $1+$0 },
                reportError: nil))
        learnOp(Op.binaryOperation("−",
                precedence: 140,
                evaluate: { $1-$0 },
                reportError: nil))
    }
    
    private func describe(_ currentOps: [Op], currentOpPrecedence: Int = 0) -> (description: String, remainingOps: [Op]) {
        var currentOps = currentOps
        if !currentOps.isEmpty {
            let op = currentOps.removeLast()
            switch op  {
            case .operand:
                return (op.description, currentOps)
            case .variable:
                return (op.description, currentOps)
            case .constant:
                return (op.description, currentOps)
            case .unaryOperation:
                let (operandDesc, remainingOps) = describe(currentOps)
                return ( op.description+"("+operandDesc+")", remainingOps)
            case .binaryOperation(_, let precedence, _, _):
                let (operandDesc1, remainingOps1) = describe(currentOps, currentOpPrecedence: precedence)
                let (operandDesc2, remainingOps2) = describe(remainingOps1, currentOpPrecedence: precedence)
                if precedence < currentOpPrecedence {
                  return ("("+operandDesc2+op.description+operandDesc1+")", remainingOps2)
                } else {
                  return (operandDesc2+op.description+operandDesc1, remainingOps2)
                }
            }
        }
        return ("?", currentOps)
    }
    
    private func evaluate(_ currentOps: [Op]) -> (result: Double?, remainingOps: [Op]) {
        var currentOps = currentOps
        if !currentOps.isEmpty {
            let op = currentOps.removeLast()
            switch op {
            case .operand(let operand):
                return (operand, currentOps)
            case .variable(let variable):
                return (variableValues[variable], currentOps)
            case .constant(_, let value):
                return (value, currentOps)
            case .unaryOperation(_, let operation, _):
                let (result, remainingOps) = evaluate(currentOps)
                if let operand = result {
                    return (operation(operand), remainingOps)
                }
            case .binaryOperation(_, _, let operation, _):
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
    
    private func evaluateAndReportErrors(_ currentOps: [Op]) -> (result: ValueOrError, remainingOps: [Op]) {
        var currentOps = currentOps
        if !currentOps.isEmpty {
            let op = currentOps.removeLast()
            switch op {
            case .operand(let operand):
                return (ValueOrError.value(operand), currentOps)
            case .variable(let variable):
                if let value = variableValues[variable] {
                    return (ValueOrError.value(value), currentOps)
                } else {
                    return (ValueOrError.error("Variable not defined!"), currentOps)
                }
            case .constant(_, let value):
                return (ValueOrError.value(value), currentOps)
            case .unaryOperation(_, let operation, let reportError):
                var value: Double
                let (result, remainingOps) = evaluateAndReportErrors(currentOps)
                switch (result) {
                case .error:
                    return (result, remainingOps)
                case .value(let tmp):
                    value = tmp
                }
                if let error = reportError?(value) {
                    return (ValueOrError.error(error), currentOps)
                } else {
                    return (ValueOrError.value(operation(value)), remainingOps)
                }
            case .binaryOperation(_, _, let operation, let reportError):
                var value1: Double, value2 :Double
                let (result1, remainingOps1) = evaluateAndReportErrors(currentOps)
                switch result1 {
                case .error:
                    return (result1, remainingOps1)
                case .value(let tmp):
                    value1 = tmp
                }
                let (result2, remainingOps2) = evaluateAndReportErrors(remainingOps1)
                switch result2 {
                case .error:
                    return (result2, remainingOps2)
                case .value(let tmp):
                    value2 = tmp
                }
                if let error = reportError?(value1, value2) {
                   return (ValueOrError.error(error), currentOps)
                } else {
                   return (ValueOrError.value(operation(value1, value2)), remainingOps2)
                }
            }
        }
        return (ValueOrError.error("Not enough operands!"), currentOps)
    }
    
    func evaluate() -> Double? {
        let (result, remainingOps) = evaluate(opStack)
        print("\(opStack) = \(result ?? 0) with \(remainingOps) left over")
        if result != nil {
            if result!.isNaN || result!.isInfinite {
                return nil
            }
        }
        return result
    }
    
    func evaluateAndReportErrors() -> ValueOrError {
        let (result, remainingOps) = evaluateAndReportErrors(opStack)
        print("\(opStack) = \(result) with \(remainingOps) unevaluated")
        return result
    }

    func evaluateOperand(_ operand: Double) -> Double? {
        pushOperand(operand)
        return evaluate()
    }

    func evaluateOperandAndReportErrors(_ operand: Double) -> ValueOrError {
        pushOperand(operand)
        return evaluateAndReportErrors()
    }
    
    func evaluateVariable(_ variable: String) -> Double? {
        pushVariable(variable)
        return evaluate()
    }

    func evaluateVariable(_ variable: String) -> ValueOrError {
        pushVariable(variable)
        return evaluateAndReportErrors()
    }
    
    func evaluateOperation(_ symbol: String) -> Double? {
        pushOperation(symbol)
        return evaluate()
    }
    
    func evaluateOperationAndReportErrors(_ symbol: String) -> ValueOrError {
        pushOperation(symbol)
        return evaluateAndReportErrors()
    }
    
    func pushOperand(_ operand: Double) {
        opStack.append(Op.operand(operand))
    }
    
    func pushVariable(_ variable: String) {
        opStack.append(Op.variable(variable))
    }
    
    func pushOperation(_ symbol: String) {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
    }
    
    func pop() {
        opStack.removeLast()
    }

    func clearOpStack() {
        opStack.removeAll(keepingCapacity: true)
    }
    
    func clearAll() {
        clearOpStack()
        variableValues.removeAll(keepingCapacity: true)
    }
}
