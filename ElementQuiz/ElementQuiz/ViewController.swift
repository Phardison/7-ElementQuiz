//
//  ViewController.swift
//  ElementQuiz
//
//  Created by Patrick Hardison on 12/1/20.
//

import UIKit

enum Mode {
    case flashCard
    case quiz
}

enum State{
    case question
    case answer
    case score
}

class ViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        mode = .flashCard
        updateUI()
        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var showAnswerButton: UIButton!
    
    @IBOutlet weak var modeSelector: UISegmentedControl!
    
    @IBOutlet weak var textField: UITextField!
    
    let fixedElementList = ["Carbon", "Gold",
       "Chlorine", "Sodium"]
    var elementList: [String] = []
    
    var currentElementIndex = 0
    var mode: Mode = .flashCard {
        didSet{
            switch mode{
            case .flashCard:
                setupFlashCards()
            case .quiz:
                setupQuiz()
            }
            
            updateUI()
        }
    }
    var state: State = .question
    var answerIsCorrect = false
    var correctAnswerCount = 0

    
    func updateUI() {
        let elementName =
           elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image

        switch mode {
        case .flashCard:
            updateFlashCardUI(elementName: elementName)
        case .quiz:
            updateQuizUI(elementName: elementName)
        }
    }
    
    func updateFlashCardUI(elementName: String) {
        textField.isHidden = true
        textField.resignFirstResponder()
        // Segmented control
        modeSelector.selectedSegmentIndex = 0
        
        //Buttons
        showAnswerButton.isHidden = false
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
        if state == .answer {
                answerLabel.text = elementName
            } else {
                answerLabel.text = "?"
            }
    }
    
    func updateQuizUI(elementName: String) {
        textField.isHidden = false
        // Segmented control
        modeSelector.selectedSegmentIndex = 1
        
        //Buttons
        showAnswerButton.isHidden = true
        if currentElementIndex == elementList.count - 1 {
            nextButton.setTitle("Show Score", for: .normal)
        } else {
            nextButton.setTitle("Next Question", for: .normal)
        }
        switch state {
        case .question:
            nextButton.isEnabled = false
        case .answer:
            nextButton.isEnabled = true
        case .score:
            nextButton.isEnabled = false
        }
        
        // Text field and keyboard
        textField.isHidden = false
        switch state {
        case .question:
            textField.isEnabled = true
            textField.text = ""
            textField.becomeFirstResponder()
        case .answer:
            textField.isEnabled = false
            textField.resignFirstResponder()
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }

        switch state {
            case .question:
                answerLabel.text = " "
            case .answer:
                if answerIsCorrect {
                    answerLabel.text = "Correct!"
                } else {
                    answerLabel.text = "❌\nCorrect answer: " + elementName
                }
            case .score:
                answerLabel.text = ""
                print("Your score is \(correctAnswerCount) out of \(elementList.count).")
            }
        // Score display
        if state == .score {
            displayScoreAlert()
        }
    }

    // Sets up a new flash card session.
    func setupFlashCards() {
        state = .question
        currentElementIndex = 0
        elementList = fixedElementList
    }
    
    // Sets up a new quiz.
    func setupQuiz() {
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
        elementList = fixedElementList.shuffled()
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        state = .answer
        updateUI()
    }
    
    
    @IBAction func next(_ sender: Any) {
        currentElementIndex += 1
        if currentElementIndex >= elementList.count {
            currentElementIndex = 0
            if mode == .quiz {
                state = .score
                updateUI()
                return
            }
        } else {
            state = .question
        }
        updateUI()
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        
        let textFieldContents = textField.text!
        
        if textFieldContents.lowercased() == elementList[currentElementIndex].lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }
        state = .answer
        updateUI()
        
    
        return true
    }
    
    @IBAction func switchMode(_ sender: Any) {
        if modeSelector.selectedSegmentIndex == 0 {
                mode = .flashCard
            } else {
                mode = .quiz
            }
    }
    
    
    // Shows an iOS alert with the user's quiz score.
    func displayScoreAlert() {
        let alert = UIAlertController(title: "Quiz Score", message: "Your score is \(correctAnswerCount) out of \(elementList.count)", preferredStyle: .alert)

        let dismissAction =
           UIAlertAction(title: "OK",
           style: .default, handler:
           scoreAlertDismissed(_:))
        alert.addAction(dismissAction)
        present(alert, animated: true,
           completion: nil)
    }
    
    func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashCard
    }
    

}

