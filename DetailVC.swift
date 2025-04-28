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
    var original: String = "" // Texte français
    var translation: String = "" // Traduction basque

    // Index de la traduction à supprimer, on met "?" car l'index peut être absent
    var indexDeleteTrans: Int?
    // Référence vers la TableView pour recharger les données après suppression
    var visualisationVC: VisualisationTVC?

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Affichage des textes français et basque

        lblFr.text = original
        lblEu.text = translation
    }


    // MARK: Audio

    // Lecture audio du mot en français
    @IBAction func playFrAudio(_ sender: Any) {
        guard let text = lblFr.text, !text.isEmpty else {
            return
        }
        // Appelle l'API pour jouer l'audio du français
        CloudAPI.audio(text: text, targetLang: "fr-FR")
    }

    // Lecture audio du mot en basque
    @IBAction func playEuAudio(_ sender: Any) {
        guard let text = lblEu.text, !text.isEmpty else {
            return
        }
        // Appelle l'API pour jouer l'audio du basque
        // N.B. : la voix esp. est meilleure que la fr. de mon pdv pour prononcer le basque
        CloudAPI.audio(text: text, targetLang: "eu-ES")
    }


    // MARK: Suppression du mot - Action Sheet

    @IBAction func deleteTrans(_ sender: Any) {
        let alert = UIAlertController(title: "Souhaitez-vous supprimer cette traduction ?",
                                      message: "Cette action est irréversible.",
                                      preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Supprimer", style: .destructive) { _ in
            guard let index = self.indexDeleteTrans else {
                return
            }
            
            // Supprime la bonne paire dans le dictionnaire
            let sorted = AppDelegate.asSortedArr() // Trie les traductions
            let pair = sorted[index] // Récupère la paire (français, basque)
            let fr = pair[0] // Texte français
            
            // Supprime la traduction du dictionnaire
            AppDelegate.translations.removeValue(forKey: fr)
            
            // Enregistre les modifications dans le fichier
            AppDelegate.writeTrans()
            
            // Recharge l'affichage dans la TableView
            self.visualisationVC?.loadTableView()
            
            // Retour à la page précédente
            self.navigationController?.popViewController(animated: true)
        }

        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)

        // Ajoute les actions à l'alerte
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        // Affiche l'alerte
        present(alert, animated: true, completion: nil)
    }
}
