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

func charArrayToStringArray(charArray: [Character]) -> [String] {
    var stringArray = [String]()
    for c in charArray {
        stringArray.append(String(c))
    }
    return stringArray
}

func truncateCharArray(charArray: [Character], sizeLimit: Int) -> [String] {
    print(charArray)
    var stringArray = [String]()
    let decimalLocation = getDecimalLocation(charArray: charArray) // returns 0 if decimal not found
    var decimalCount = decimalLocation - 2
    if decimalLocation == 0 {
        // Ex. "+10.0" has decimal at location 3, 0 indexed, and has exponent 3 - 2 = 1, or e1, resulting in "+1.00e1"
        // Note the small exponent in the simplified example; exponent notation should only be used for larger numbers
        decimalCount = charArray.count - 2
    }
    
    if (String(charArray[charArray.count - 4]) == "e") {
        var newSizeLimit = sizeLimit - 4
        if (String(charArray[charArray.count - 2]) == "0") {
            newSizeLimit += 1
        }
        if (String(charArray[charArray.count - 3]) == "-") {
            newSizeLimit += 1
        }
        var counter = 0
        for c in charArray {
            if ((counter < newSizeLimit) && (String(c) != "e")) {
                stringArray.append(String(c))
                counter += 1
            }
        }
        stringArray.append("e")
        if (String(charArray[charArray.count - 3]) == "-") {
            stringArray.append("-")
        }
        if (String(charArray[charArray.count - 2]) == "0") {
            stringArray.append(String(charArray[charArray.count - 1]))
        } else {
            stringArray.append(String(charArray[charArray.count - 2]))
            stringArray.append(String(charArray[charArray.count - 1]))
        }
    } else if (charArray.count > sizeLimit) && ((decimalLocation == 0) || (decimalLocation > sizeLimit)) {
        // String(charArray[charArray.count - 3]) == "e" could be implied
        // if the number is larger than sizeLimit and (has no decimal or decimal is outside of sizeLimit)
        // if has no decimal or decimal is outside of sizeLimit
        let newSizeLimit = sizeLimit - 3 // exponent is a positive number, so omit "+" sign
        var counter = 0
        for c in charArray {
            if ((counter < newSizeLimit - 1) && (String(c) != "e")) { // -1 for the decimal point
                if counter == 2 {
                    stringArray.append(".") // don't incremet counter it's already accounted for in if statement
                }
                stringArray.append(String(c))
                counter += 1
            }
        }
        stringArray.append("e")
        if (decimalCount) > 10 {
            stringArray.append(String(((decimalCount) / 10) % 10))
        }
        stringArray.append(String((decimalCount) % 10))
        print(((charArray.count - 2) / 10) % 10)
        print((charArray.count - 2) % 10)
    } else {
        var counter = 0
        for c in charArray {
            if counter == sizeLimit {
                return stringArray
            }
            stringArray.append(String(c))
            counter += 1
        }
    }
    print(stringArray)
    return stringArray
}

func getDecimalLocation(charArray: [Character]) -> Int {
    // returns decimal index, otherwise return 0 if no decimal exists
    var i = 0
    for c in charArray {
        if String(c) == "." {
            return i
        }
        i += 1
    }
    return 0
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
    var inputSign = 1
    var resultSign = 1
    var inputText = ["+", "0"]
    var resultString = "+0"
    var previousOperator = ""
    var currentOperator = ""
    var errorOccured = false
    var alreadyCalculated = false
    var isFirstInput = true
    var isArithmeticOperator = false
    var hasDecimal = false
    var hasInput = false
    
    func resetCalculatorValues() {
        resultSign = 1
        resultString = "+0"
        previousOperator = ""
        currentOperator = ""
        errorOccured = false
        alreadyCalculated = false
        isFirstInput = true
        isArithmeticOperator = false
        resetInputText()
    }
    func resetInputText() {
        inputSign = 1
        inputText = ["+", "0"]
        hasDecimal = false
        hasInput = false
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
        if currentOperator == "=" || currentOperator == "%"{
            resetCalculatorValues()
        }
        if !(hasInput) {
            resetInputText()
        }
        if (inputText.count == 2 && inputText[1] == "0" && !(hasDecimal) && content != ".") {
            inputText[1] = content
        } else if (content != "." && ((inputText.count < 7) || ((inputSign == 1) && (inputText.count < 8)))) {
            inputText.append(content)
        } else if (content == "." && !(hasDecimal)) {
            inputText.append(content)
            hasDecimal = true
        }
        hasInput = true
        alreadyCalculated = false
    }
    
    func updateSign() {
        if hasInput || isFirstInput || isArithmeticOperator || errorOccured { // negate input
            if !hasInput {
                resetInputText()
            }
            inputSign *= -1
            if inputSign == 1 {
                inputText[0] = "+"
            } else {
                inputText[0] = "-"
            }
            hasInput = true
            alreadyCalculated = false
            updateResultLabel(inputText.joined())
        } else { // negate result
            resultSign *= -1
            if resultSign == 1 {
                resultString = "+\(resultString.substring(from: 1))"
            } else {
                resultString = "-\(resultString.substring(from: 1))"
            }
            updateResultLabel(resultString)
        }
    }
    
    // Done: Ensure that resultLabel gets updated.
    //       Modify this one or create your own.
    func updateResultLabel(_ content: String) {
        let contentArray = Array(content.characters)
        if (errorOccured && content == "Error") {
            resultLabel.text = "Error"
        } else if (isFirstInput || hasInput) {
            // allow negating 0 or keeping integeral decimal as decimal instead of showing as integer at start
            if (Double(content) != nil && String(contentArray[0]) == "+") {
                resultLabel.text = String(content.characters.dropFirst())
            } else {
                resultLabel.text = content
            }
        } else { // !(hasInput)
            // display result and convert integer decimals to display as integers without the decimal
            // let intResult = Int(Double(content)!) // cast to Double?, unwrap, then to Int
            // let doubleResult = Double(content)!
            let intResult = (content as NSString).integerValue // better way of casting than comments above
            let doubleResult = (content as NSString).doubleValue
            if doubleResult == Double(intResult) {
                resultLabel.text = String(intResult)
            } else if (String(contentArray[0]) == "+") {
                resultLabel.text = String(content.characters.dropFirst())
            } else {
                resultLabel.text = content
            }
        }
    }
    
    
    // Done: A calculate method with no parameters, scary!
    //       Modify this one or create your own.
    func calculate() -> String {
        if isFirstInput && currentOperator != "%" {
            if hasInput {
                return inputText.joined()
            }
            return resultString
        }
        resultSign = 1

        let inputString = inputText.joined()
        var result = calcIntOrDouble(resultString: resultString, inputString: inputString)
        if (resultSign == -1 && result.characters.count > 7) {
            result = truncateCharArray(charArray: Array(result.characters), sizeLimit: 7).joined()
        } else if (resultSign == 1 && result.characters.count > 8) {
            result = truncateCharArray(charArray: Array(result.characters), sizeLimit: 8).joined()
        }
        return result
    }
    
    func calcIntOrDouble(resultString: String, inputString: String) -> String {
        if ((Double(inputString) == 0.0 && previousOperator == "/") || errorOccured) {
            errorOccured = true // signal error if division by 0 or if there's already an error
            return "Error"
        }
        
        let intInputString = Int(inputString) // wrapped Int
        let intResultString = Int(resultString) // wrapped Int
        // Don't perform int division when operator is "/", instead perform double division.
        if previousOperator != "/" && currentOperator != "%" && intInputString != nil && intResultString != nil {
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
            errorOccured = true
            return "Error"
        }
        
        var doubleResult = calculate(firstOperand: resultString, secondOperand: inputString, operation: previousOperator)
        if (currentOperator == "%" && hasInput) {
            doubleResult = calculate(firstOperand: inputString, secondOperand: "100.0", operation: "/")
        } else if (currentOperator == "%") {
            doubleResult = calculate(firstOperand: resultString, secondOperand: "100.0", operation: "/")
        }
        let stringDoubleResult = String(doubleResult)
        if doubleResult < 0.0 {
            resultSign = -1
            return stringDoubleResult // negative sign already there
        }
        return "+\(stringDoubleResult)" // add positive sign
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
            break
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
                break
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
            updateSign() // also updates the displayed resultLabel
        case "%":
            isArithmeticOperator = false
            if hasInput {
                inputText = charArrayToStringArray(charArray: Array(calculate().characters))
                updateResultLabel(inputText.joined())
            } else {
                resultString = charArrayToStringArray(charArray: Array(calculate().characters)).joined()
                updateResultLabel(resultString)
            }
        case "/", "*", "-", "+":
            if !(alreadyCalculated) {
                resultString = calculate()
                alreadyCalculated = true
                resetInputText()
                hasInput = false
                updateResultLabel(resultString)
            }
            isFirstInput = false
            isArithmeticOperator = true
            inputText = charArrayToStringArray(charArray: Array(resultString.characters))
            previousOperator = currentOperator
        case "=":
            resultString = calculate()
            alreadyCalculated = true
            hasInput = false
            isArithmeticOperator = false
            updateResultLabel(resultString)
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
