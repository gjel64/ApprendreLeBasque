//
//  Traduction.swift
//  EuskApp
//
//  Created by etudiant on 24/03/2025.
//

import UIKit

class Traduction: UIViewController {
    
    // Français vers basque
    @IBOutlet weak var tfFr: UITextField!
    @IBOutlet weak var lblTransEu: UILabel!
    
    // Basque vers français
    @IBOutlet weak var tfEu: UITextField!
    @IBOutlet weak var lblTransFr: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: Français vers basque
    @IBAction func translateFrIntoEu(_ sender: Any) {
        guard let text = tfFr.text, !text.isEmpty else {
            return
        }
        CloudAPI.translate(text: text, targetLang: "eu") { translation in
            if let translated = translation {
                self.lblTransEu.text = translated
            } else {
                self.lblTransEu.text = "Erreur de traduction"
            }
        }
    }

    @IBAction func addFrIntoEu(_ sender: Any) {
        guard let fr = tfFr.text, let eu = lblTransEu.text, !fr.isEmpty, !eu.isEmpty else {
            return
        }
        AppDelegate.addTrans(original: fr, translation: eu)
        AppDelegate.writeTrans()
    }

    @IBAction func playEuAudio(_ sender: Any) {
        guard let text = lblTransEu.text, !text.isEmpty else {
            return
        }
        CloudAPI.audio(text: text, targetLang: "eu-ES")
    }


    // MARK: Basque vers français
    @IBAction func transEuIntoFr(_ sender: Any) {
        guard let text = tfEu.text, !text.isEmpty else {
            return
        }
        CloudAPI.translate(text: text, targetLang: "fr") { translation in
            if let translated = translation {
                self.lblTransFr.text = translated
            } else {
                self.lblTransFr.text = "Erreur de traduction"
            }
        }
    }

    @IBAction func addEuIntoFr(_ sender: Any) {
        guard let eu = tfEu.text, let fr = lblTransFr.text, !eu.isEmpty, !fr.isEmpty else { return }
        AppDelegate.addTrans(original: fr, translation: eu)
        AppDelegate.writeTrans()
    }
    
    @IBAction func playFrAudio(_ sender: Any) {
        guard let text = lblTransFr.text, !text.isEmpty else {
            return
        }
        CloudAPI.audio(text: text, targetLang: "fr-FR")
    }
}
