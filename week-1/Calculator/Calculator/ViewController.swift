//
//  ViewController.swift
//  Calculator
//
//  Created by miinx on 26/01/2015.
//  Copyright (c) 2015 Miinx. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var display: UILabel!
	@IBOutlet weak var historyDisplay: UILabel!
	
	var operandStack = Array<Double>()
	var inputStack = Array<String>()
	var userIsInTheMiddleOfTypingANumber = false
	let mathConstants = ["π": M_PI]
	
	/* This displayValue: Double? property is for #4 in Extra Credit section... 
		Reckon there's gotta be a better way, feels yuck
	 */
	var displayValue: Double? {
		get {
			if let dt = NSNumberFormatter().numberFromString(display.text!) {
				return dt.doubleValue
			} else {
				return 0
			}
		}
		set {
			if let nv = newValue {
				display.text = "\(nv)"
			} else {
				display.text = "0"
			}
			userIsInTheMiddleOfTypingANumber = false
		}
	}
	
	var historyDisplayValue: String {
		return "\n".join(inputStack)
	}
	
	@IBAction func clear() {
		operandStack.removeAll()
		inputStack.removeAll()
		display.text = "0"
		historyDisplay.text = "0"
	}
	
	@IBAction func enter() {
		updateStacks(true)
	}
	
	@IBAction func appendDigit(sender: UIButton) {
		var digit = sender.currentTitle!
		if userIsInTheMiddleOfTypingANumber {
			if digit == "." && display.text!.rangeOfString(".") != nil  {
				return
			}
			display.text = display.text! == "0" ? digit : display.text! + digit
		} else {
			display.text = digit
			userIsInTheMiddleOfTypingANumber = true
		}
	}

	@IBAction func removeLastDigit() {
		if display.text! == "0" {
			return
		}
		display.text = dropLast(display.text!)
		if countElements(display.text!) == 0 {
			display.text = "0"
		}
	}
	
	@IBAction func changeSign() {
		if userIsInTheMiddleOfTypingANumber == false {
			updateStacks(true)
		}
		let sign = Array(display.text!).first!
		display.text = sign == "-" ? dropFirst(display.text!) : "-" + display.text!
	}
	
	@IBAction func enterConstant(sender: UIButton) {
		if userIsInTheMiddleOfTypingANumber	{
			updateStacks(true)
		}
		display.text = "\(mathConstants[sender.currentTitle!]!)"
		updateStacks(true)
	}
	
	@IBAction func operate(sender: UIButton) {
		let operation = sender.currentTitle!
		inputStack.append(operation)
		
		if userIsInTheMiddleOfTypingANumber {
			updateStacks(true)
		}
		
		if inputStack.last != "=" && inputStack.count != 0 {
			removeEqualsFromInputStack()
			inputStack.append("=")
			historyDisplay.text = historyDisplayValue
		}
		
		switch operation {
		case "×": performOperation { $0 * $1 }
		case "÷": performOperation { $1 / $0 }
		case "+": performOperation { $0 + $1 }
		case "−": performOperation { $1 - $0 }
		case "√": performOperation { sqrt($0) }
		case "sin": performOperation { sin($0) }
		case "cos": performOperation { cos($0) }
		default: break
		}
		
	}
	
	func performOperation(operation: (Double, Double) -> Double) {
		if operandStack.count >= 2 {
			displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
			updateStacks(false)
		}
	}
	
	func performOperation(operation: Double -> Double) {
		if operandStack.count >= 1 {
			displayValue = operation(operandStack.removeLast())
			updateStacks(false)
		}
	}

	func updateStacks(updateHistory: Bool) {
		userIsInTheMiddleOfTypingANumber = false
		operandStack.append(displayValue!)
		
		if updateHistory {
			removeEqualsFromInputStack()
			inputStack.append(truncateValue(displayValue!))
			historyDisplay.text = historyDisplayValue
		}
		
		println("operandStack = \(operandStack)")
	}
	
	func truncateValue(val: Double) -> String {
		let desiredFormat = val%1 == 0 ? "%.0f" : "%.3f"
		return String(format: desiredFormat, displayValue!)
	}
	
	func removeEqualsFromInputStack() {
		inputStack = inputStack.filter({$0 != "="})
	}
	
}

