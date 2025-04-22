//
//  DetailVC.swift
//  EuskApp
//
//  Created by etudiant on 20/04/2025.
//

import UIKit

class DetailVC: UIViewController {

    @IBOutlet weak var lblFr: UILabel!
    @IBOutlet weak var lblEu: UILabel!

    // Données envoyées depuis la TableView : permet d’afficher le mot sélectionné dans la table
    var original: String = ""
    // Permet d’afficher la traduction basque correspondante
    var translation: String = ""
    // Supprime à la bonne position, on met "?" car l'index peut être absent
    var indexDeleteTrans: Int?
    // Référence vers VisualtionTVC pour stocker
    var visualisationVC: VisualisationTVC?

    override func viewDidLoad() {
        super.viewDidLoad()

        lblFr.text = original
        lblEu.text = translation
    }

    @IBAction func playFrAudio(_ sender: Any) {
        guard let text = lblFr.text, !text.isEmpty else {
            return
        }
        CloudAPI.audio(text: text, targetLang: "fr-FR")
    }

    @IBAction func playEuAudio(_ sender: Any) {
        guard let text = lblEu.text, !text.isEmpty else {
            return
        }
        CloudAPI.audio(text: text, targetLang: "eu-ES")
    }

    @IBAction func deleteTrans(_ sender: Any) {
        guard let index = indexDeleteTrans else {
            return
        }

        // Supprime la bonne paire dans le dictionnaire
        let sorted = AppDelegate.asSortedArr()
        let pair = sorted[index]
        let fr = pair[0]

        // Supprime du dictionnaire
        AppDelegate.translations.removeValue(forKey: fr)

        // Enregistre dans le fichier
        AppDelegate.writeTrans()

        // Recharge l'affichage'
        visualisationVC?.loadTableView()

        // Retour à la page précédente
        navigationController?.popViewController(animated: true)
    }

}
