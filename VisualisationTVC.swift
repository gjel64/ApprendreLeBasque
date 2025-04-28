//
//  VisualisationTVC.swift
//  EuskApp
//
//  Created by etudiant on 08/04/2025.
//

import UIKit

class VisualisationTVC: UITableViewController, UITextFieldDelegate {

    // Champ de texte pour la recherche
    @IBOutlet weak var searchTextField: UITextField!

    // "Glisser pour rafraîchir"
    private var unRefreshControl : UIRefreshControl!

    // Toutes les traductions
    private var listTranslations: [[String]] = []

    // Liste filtrée en fonction de la recherche
    private var filteredTranslations: [[String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialise le "Glisser pour rafraîchir"
        unRefreshControl = UIRefreshControl()

        // Définit le texte affiché pendant le rafraîchissement
        unRefreshControl.attributedTitle =
        NSAttributedString(string: "Glisser pour rafraîchir")

        // Quand on tire pour rafraîchir, appelle rechargerTableView()
        unRefreshControl.addTarget(self, action:
                        #selector(VisualisationTVC.loadTableView), for: UIControl.Event.valueChanged)

        // Ajoute ce contrôle à la tableView
        self.tableView.addSubview(self.unRefreshControl)

        // Charge la tableView une première fois au chargement
        loadTableView()

        // Définit ce contrôleur comme délégué pour le champ de recherche
        searchTextField.delegate = self

        // Au départ affiche tout
        filteredTranslations = listTranslations

        // Ajoute un bouton clear sur le textField pour effacer la recherche
        // Croix visible lorsque l'utilisateur édite (aussi définie sur le storyboard)
        searchTextField.clearButtonMode = .whileEditing
    }

    // Charge les données dans la tableView
    @objc func loadTableView() {
        // Charge les traductions triées depuis AppDelegate
        listTranslations = AppDelegate.asSortedArr()

        // Réinitialise la liste filtrée
        filteredTranslations = listTranslations

        // Recharge l'affichage'
        self.tableView.reloadData()

        // Arrête l'animation de "Glisser pour rafraîchir"
        self.unRefreshControl.endRefreshing()
    }


    // MARK: Recherche (filtrage dynamique)

    // Filtrage dynamique des traductions selon la recherche
    func searching() {
        guard let textSearch = searchTextField.text?.lowercased(), !textSearch.isEmpty else {
            // Si aucun texte ou champ vide, on affiche tout
            filteredTranslations = listTranslations
            tableView.reloadData()
            return
        }

        filteredTranslations = []
        for translation in listTranslations {
            for field in translation { // [français, basque]
                if field.lowercased().contains(textSearch) {
                    filteredTranslations.append(translation)
                    // Dès qu'un champ correspond, pas besoin de continuer
                    break
                }
            }
        }
        tableView.reloadData()
    }

    // Déclenche la recherche quand on appuie sur Entrée du clavier
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Cache le clavier
        searching() // Lance la recherche
        return true
    }

    // Ne réinitialise pas la recherche, méthode appelée lorsqu'on appuie sur "Entrée"
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Ne rien faire ici concernant la recherche, sinon ça efface la recherche trop tôt
    }

    // Bouton de réinitialisation
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // Efface le texte de recherche
        searchTextField.text = ""

        // Réinitialise les traductions pour afficher toutes les cellules
        filteredTranslations = listTranslations

        // Recharge la table
        tableView.reloadData()
        return true
    }


    // MARK: Gestion de la TableView

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTranslations.count // Nombre de lignes = nombre de traductions
    }

    // Remplit chaque cellule avec un mot français + sa traduction basque
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transCell", for: indexPath)

        // Récupère les mots français et basques
        let frWord = filteredTranslations[indexPath.row][0] // Mot en français
        let euWord = filteredTranslations[indexPath.row][1] // Mot en basque
        
        // Si un texte de recherche est saisi
        if let searchTerm = searchTextField.text, !searchTerm.isEmpty {
            // Crée un NSMutableAttributedString pour appliquer le style
            let attributedFrWord = NSMutableAttributedString(string: frWord)
            let attributedEuWord = NSMutableAttributedString(string: euWord)
            
            // Recherche et applique le style sur le mot français si trouvé
            if let frRange = frWord.range(of: searchTerm, options: .caseInsensitive) {
                let nsRange = NSRange(frRange, in: frWord)
                // Gras
                attributedFrWord.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 12), range: nsRange)
                // Surligne en gris clair
                attributedFrWord.addAttribute(.backgroundColor, value: UIColor.lightGray.withAlphaComponent(0.2), range: nsRange)
            }
            
            // Recherche et applique un style sur le mot basque si trouvé
            if let euRange = euWord.range(of: searchTerm, options: .caseInsensitive) {
                let nsRange = NSRange(euRange, in: euWord)
                // Gras
                attributedEuWord.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 12), range: nsRange)
                // Surligne en gris clair
                attributedEuWord.addAttribute(.backgroundColor, value: UIColor.lightGray.withAlphaComponent(0.2), range: nsRange)
            }
            
            // Assigne les textes formatés à la cellule
            cell.textLabel?.attributedText = attributedFrWord
            cell.detailTextLabel?.attributedText = attributedEuWord
        } else {
            // Pas de recherche -> affiche les mots normalement
            cell.textLabel?.text = frWord
            cell.detailTextLabel?.text = euWord
        }
        return cell
    }


    // MARK: Navigation

    // Prépare l'envoi de données vers le détail
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewDetail" {
            if let indexPath = tableView.indexPathForSelectedRow,
               let destinationVC = segue.destination as? DetailVC {
                // Envoie les mots
                let wordFr = listTranslations[indexPath.row][0]
                let wordEu = listTranslations[indexPath.row][1]

                destinationVC.original = wordFr
                destinationVC.translation = wordEu

                // Transmet l'index de la ligne à supprimer
                destinationVC.indexDeleteTrans = indexPath.row

                // Transmet une référence vers DetailVC pour pouvoir recharger la table après suppression
                destinationVC.visualisationVC = self
            }
        }
    }
}
