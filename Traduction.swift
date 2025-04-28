//
//  Traduction.swift
//  EuskApp
//
//  Created by etudiant on 24/03/2025.
//

import UIKit

class Traduction: UIViewController, UITextFieldDelegate {

    // Français vers basque
    @IBOutlet weak var tfFr: UITextField!
    @IBOutlet weak var lblTransEu: UILabel!

    // Basque vers français
    @IBOutlet weak var tfEu: UITextField!
    @IBOutlet weak var lblTransFr: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Ajoute un bouton clear sur le textField pour effacer la recherche
        // Croix visible lorsque l'utilisateur édite
        tfFr.clearButtonMode = .whileEditing
        tfEu.clearButtonMode = .whileEditing

        // Détecte quand l'utilisateur clique sur la croix / clavier
        tfFr.delegate = self
        tfEu.delegate = self
    }


    // MARK: Français vers basque

    @IBAction func translateFrIntoEu(_ sender: Any) {
        // Vérifie que le texte français n'est pas vide
        guard let text = tfFr.text, !text.isEmpty else {
            return
        }

        // Appelle l'API pour traduire en basque
        CloudAPI.translate(text: text, targetLang: "eu") { translation in
            // Met à jour le label avec la traduction reçue
            if let translated = translation {
                self.lblTransEu.text = translated
            } else {
                self.lblTransEu.text = "Erreur de traduction"
            }
        }
    }

    @IBAction func addFrIntoEu(_ sender: Any) {
        // Vérifie que les champs français et basque ne sont pas vides
        guard let fr = tfFr.text, let eu = lblTransEu.text, !fr.isEmpty, !eu.isEmpty else {
            return
        }

        // Ajoute la paire (français-basque) aux traductions
        AppDelegate.addTrans(original: fr, translation: eu)

        // Sauvegarde immédiatement la mise à jour dans le fichier JSON
        AppDelegate.writeTrans()

        // Affiche une alerte pour confirmer que la traduction a été ajoutée
        confirmation(message: "La traduction a été ajoutée à votre liste de vocabulaire.")
    }

    @IBAction func playEuAudio(_ sender: Any) {
        // Vérifie que le label basque n'est pas vide
        guard let text = lblTransEu.text, !text.isEmpty else {
            return
        }

        // Joue l'audio en basque (basque d'Espagne)
        CloudAPI.audio(text: text, targetLang: "eu-ES")
    }


    // MARK: Basque vers français

    @IBAction func transEuIntoFr(_ sender: Any) {
        // Vérifie que le texte basque n'est pas vide
        guard let text = tfEu.text, !text.isEmpty else {
            return
        }

        // Appelle l'API pour traduire en français
        CloudAPI.translate(text: text, targetLang: "fr") { translation in
            // Met à jour le label avec la traduction reçue
            if let translated = translation {
                self.lblTransFr.text = translated
            } else {
                self.lblTransFr.text = "Erreur de traduction"
            }
        }
    }

    @IBAction func addEuIntoFr(_ sender: Any) {
        // Vérifie que les champs basque et français ne sont pas vides
        guard let eu = tfEu.text, let fr = lblTransFr.text, !eu.isEmpty, !fr.isEmpty else {
            return
        }

        // Ajoute la paire (français-basque) aux traductions
        AppDelegate.addTrans(original: fr, translation: eu)

        // Sauvegarde immédiatement la mise à jour dans le fichier JSON
        AppDelegate.writeTrans()

        // Affiche une alerte pour confirmer que la traduction a été ajoutée
        confirmation(message: "La traduction a été ajoutée à votre liste de vocabulaire.")
    }
    
    @IBAction func playFrAudio(_ sender: Any) {
        // Vérifie que le label français n'est pas vide
        guard let text = lblTransFr.text, !text.isEmpty else {
            return
        }

        // Joue l'audio en français
        CloudAPI.audio(text: text, targetLang: "fr-FR")
    }


    // MARK: Croix pour effacer un TextField

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // Si on efface tfFr, alors vide aussi lblTransEu
        if textField == tfFr {
            lblTransEu.text = ""
        }

        // Si on efface tfEu, alors vide aussi lblTransFr
        else if textField == tfEu {
            lblTransFr.text = ""
        }

        // Autorise la suppression du texte
        return true
    }


    // MARK: Afficher une pop-up de confirmation

    func confirmation(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        // Ajoute un bouton OK
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        // Affiche l'alerte
        present(alert, animated: true, completion: nil)
    }
}
