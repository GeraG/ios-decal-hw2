//
//  ViewController.swift
//  SwiftCalc
//
//  Created by Zach Zeleznick on 9/20/16.
//  Copyright © 2016 zzeleznick. All rights reserved.
//

import UIKit
extension String {
    /*
     let string = "Hello,World!"
     string.substring(from: 1, to: 7)gets you: ello,Wo
     string.substring(to: 7)gets you: Hello,Wo
     string.substring(from: 3)gets you: lo,World!
     string.substring(from: 1, length: 4)gets you: ello
     string.substring(length: 4, to: 7)gets you: o,Wo
    */
    
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.characters.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end > 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start > 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.characters.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return self[startIndex ..< endIndex]
    }
    
    func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }
    
    func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }
    
    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length
        }
        
        return self.substring(from: from, to: end)
    }
    
    func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        
        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return self.substring(from: start, to: to)
    }
}

class ViewController: UIViewController {
    // MARK: Width and Height of Screen for Layout
    var w: CGFloat!
    var h: CGFloat!
    

    // IMPORTANT: Do NOT modify the name or class of resultLabel.
    //            We will be using the result label to run autograded tests.
    // MARK: The label to display our calculations
    var resultLabel = UILabel()
    
    // Done: This looks like a good place to add some data structures.
    //       One data structure is initialized below for reference.
    // TODO: Add support for "%" decimal operator
    // TODO: Reset calculations when "=" is pressed, or resume calculation when "=", then "+" is pressed.
    var sign = 1
    var resultSign = 1
    var inputText = ["+"]
    var resultString = "+0"
    var previousOperator = ""
    var currentOperator = ""
    var readyToCalculate = false
    
    func resetCalculatorValues() {
        resultSign = 1
        resultString = "+0"
        previousOperator = ""
        currentOperator = ""
        resetInputText()
    }
    func resetInputText() {
        sign = 1
        inputText = ["+"]
        readyToCalculate = false
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        w = view.bounds.size.width
        h = view.bounds.size.height
        navigationItem.title = "Calculator"
        // IMPORTANT: Do NOT modify the accessibilityValue of resultLabel.
        //            We will be using the result label to run autograded tests.
        resultLabel.accessibilityValue = "resultLabel"
        makeButtons()
        // Do any additional setup here.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Done: A method to update your data structure(s) would be nice.
    //       Modify this one or create your own.
    func updateInputText(_ content: String) {
        if (inputText.count < 7) || ((sign == 1) && (inputText.count < 8)) {
            inputText.append(content)
            readyToCalculate = true
        }
    }
    
    func updateSign() {
        if currentOperator == "+/-" && inputText.count < 2 {
            resultSign *= -1
            if resultSign == 1 {
                resultString = "+\(resultString.substring(from: 1))"
            } else {
                resultString = "-\(resultString.substring(from: 1))"
            }
            updateResultLabel(resultString)
        } else if (currentOperator == "+/-" && inputText.count < 8) {
            sign *= -1
            if sign == 1 {
                inputText[0] = "+"
            } else {
                inputText[0] = "-"
            }
            updateResultLabel(inputText.joined())
        }
    }
    
    // Done: Ensure that resultLabel gets updated.
    //       Modify this one or create your own.
    func updateResultLabel(_ content: String) {
        if (inputText.count < 2 && previousOperator != "") {
            // let intResult = Int(Double(content)!) // cast to Double?, unwrap, then to Int
            // let doubleResult = Double(content)!
            let intResult = (content as NSString).integerValue // better way of casting than comments above
            let doubleResult = (content as NSString).doubleValue
            if doubleResult == Double(intResult) {
                resultLabel.text = String(intResult)
            } else {
                // resultLabel.text = String(content.characters.dropFirst())
                resultLabel.text = String(doubleResult)
            }
        } else if ((sign == 1 && inputText.count >= 2) || (resultSign == 1 && inputText.count < 2)) {
            resultLabel.text = String(content.characters.dropFirst())
        } else {
            resultLabel.text = content
        }
    }
    
    
    // Done: A calculate method with no parameters, scary!
    //       Modify this one or create your own.
    func calculate() -> String {
        if inputText.count < 2 {
            return resultString
        }
        let inputString = inputText.joined()
        
        let intInputString = Int(inputString) // wrapped Int
        let intResultString = Int(resultString) // wrapped Int
        resultSign = 1
        
        // Don't perform int division when operator is "/", instead perform double division.
        if previousOperator != "/" && intInputString != nil && intResultString != nil {
            let intResult = intCalculate(firstOperand: intResultString!, secondOperand: intInputString!, operation: previousOperator)
            let stringIntCalcResult = String(intResult)
            if intResult < 0 {
                resultSign = -1
                return stringIntCalcResult // negative sign already there
            }
            return "+\(stringIntCalcResult)" // add positive sign
        }
        
        // Done: Perform error checking, return 0 if error
        let doubleInputString = Double(inputString) // wrapped Int
        let doubleResultString = Double(resultString) // wrapped Int
        if doubleInputString == nil || doubleResultString == nil {
            return "0"
        }
        let doubleResult = calculate(firstOperand: resultString, secondOperand: inputString, operation: previousOperator)
        let stringDoubleCalcResult = String(doubleResult)
        if doubleResult < 0 {
            resultSign = -1
            return stringDoubleCalcResult // negative sign already there
        }
        return "+\(stringDoubleCalcResult)" // add positive sign
    }
    
    // Done: A simple calculate method for integers.
    //       Modify this one or create your own.
    func intCalculate(firstOperand: Int, secondOperand:Int, operation: String) -> Int {
        let a = firstOperand
        let b = secondOperand
        var result: Int = 0
        switch operation {
        // case "/":            // Not using integer division
        //    result = a / b
        case "*":
            result = a * b
        case "-":
            result = a - b
        case "+":
            result = a + b
        default:
            result = a + b
        }
        return result
    }
    
    // Done: A general calculate method for doubles
    //       Modify this one or create your own.
    func calculate(firstOperand: String, secondOperand:String, operation: String) -> Double {
        let firstOp = Double(firstOperand) // wrapped Double
        let secondOp = Double(secondOperand) // wrapped Double
        var result: Double = 0
        if firstOp != nil && secondOp != nil {
            let a = firstOp!
            let b = secondOp!
            switch operation {
            case "/":
                result = a / b
            case "*":
                result = a * b
            case "-":
                result = a - b
            case "+":
                result = a + b
            default:
                result = a + b
            }
        }
        return result
    }
    
    // REQUIRED: The responder to a number button being pressed.
    func numberPressed(_ sender: CustomButton) {
        updateInputText(sender.content)
        updateResultLabel(inputText.joined())
//        guard Int(sender.content) != nil else { return }
//        print("The number \(sender.content) was pressed")
        // Fill me in!
    }
    
    // REQUIRED: The responder to an operator button being pressed.
    func operatorPressed(_ sender: CustomButton) {
        let operation = sender.content
        currentOperator = operation
        
        switch operation {
        case "C":
            resetCalculatorValues()
            updateResultLabel(resultString)
        case "+/-":
            updateSign() // also updates result label
        case "/", "*", "-", "+", "=":
            if readyToCalculate {
                resultString = calculate()
                resetInputText()
                updateResultLabel(resultString)
            }
            if (operation != "=") {
                previousOperator = currentOperator
            }
        default:
            updateResultLabel(inputText.joined())
        }
//        guard Int(sender.content) != nil else { return }
//        print("The number \(sender.content) was pressed")
        // Fill me in!
    }
    
    // REQUIRED: The responder to a number or operator button being pressed.
    func buttonPressed(_ sender: CustomButton) {
        updateInputText(sender.content)
        updateResultLabel(inputText.joined())
       // Fill me in!
    }
    
    // IMPORTANT: Do NOT change any of the code below.
    //            We will be using these buttons to run autograded tests.
    
    func makeButtons() {
        // MARK: Adds buttons
        let digits = (1..<10).map({
            return String($0)
        })
        let operators = ["/", "*", "-", "+", "="]
        let others = ["C", "+/-", "%"]
        let special = ["0", "."]
        
        let displayContainer = UIView()
        view.addUIElement(displayContainer, frame: CGRect(x: 0, y: 0, width: w, height: 160)) { element in
            guard let container = element as? UIView else { return }
            container.backgroundColor = UIColor.black
        }
        displayContainer.addUIElement(resultLabel, text: "0", frame: CGRect(x: 70, y: 70, width: w-70, height: 90)) {
            element in
            guard let label = element as? UILabel else { return }
            label.textColor = UIColor.white
            label.font = UIFont(name: label.font.fontName, size: 60)
            label.textAlignment = NSTextAlignment.right
        }
        
        let calcContainer = UIView()
        view.addUIElement(calcContainer, frame: CGRect(x: 0, y: 160, width: w, height: h-160)) { element in
            guard let container = element as? UIView else { return }
            container.backgroundColor = UIColor.black
        }

        let margin: CGFloat = 1.0
        let buttonWidth: CGFloat = w / 4.0
        let buttonHeight: CGFloat = 100.0
        
        // MARK: Top Row
        for (i, el) in others.enumerated() {
            let x = (CGFloat(i%3) + 1.0) * margin + (CGFloat(i%3) * buttonWidth)
            let y = (CGFloat(i/3) + 1.0) * margin + (CGFloat(i/3) * buttonHeight)
            calcContainer.addUIElement(CustomButton(content: el), text: el,
            frame: CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)) { element in
                guard let button = element as? UIButton else { return }
                button.addTarget(self, action: #selector(operatorPressed), for: .touchUpInside)
            }
        }
        // MARK: Second Row 3x3
        for (i, digit) in digits.enumerated() {
            let x = (CGFloat(i%3) + 1.0) * margin + (CGFloat(i%3) * buttonWidth)
            let y = (CGFloat(i/3) + 1.0) * margin + (CGFloat(i/3) * buttonHeight)
            calcContainer.addUIElement(CustomButton(content: digit), text: digit,
            frame: CGRect(x: x, y: y+101.0, width: buttonWidth, height: buttonHeight)) { element in
                guard let button = element as? UIButton else { return }
                button.addTarget(self, action: #selector(numberPressed), for: .touchUpInside)
            }
        }
        // MARK: Vertical Column of Operators
        for (i, el) in operators.enumerated() {
            let x = (CGFloat(3) + 1.0) * margin + (CGFloat(3) * buttonWidth)
            let y = (CGFloat(i) + 1.0) * margin + (CGFloat(i) * buttonHeight)
            calcContainer.addUIElement(CustomButton(content: el), text: el,
            frame: CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)) { element in
                guard let button = element as? UIButton else { return }
                button.backgroundColor = UIColor.orange
                button.setTitleColor(UIColor.white, for: .normal)
                button.addTarget(self, action: #selector(operatorPressed), for: .touchUpInside)
            }
        }
        // MARK: Last Row for big 0 and .
        for (i, el) in special.enumerated() {
            let myWidth = buttonWidth * (CGFloat((i+1)%2) + 1.0) + margin * (CGFloat((i+1)%2))
            let x = (CGFloat(2*i) + 1.0) * margin + buttonWidth * (CGFloat(i*2))
            calcContainer.addUIElement(CustomButton(content: el), text: el,
            frame: CGRect(x: x, y: 405, width: myWidth, height: buttonHeight)) { element in
                guard let button = element as? UIButton else { return }
                button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            }
        }
    }

}
