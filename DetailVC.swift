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
    var original: String = "" // Valeur non-optionnelle
    // Permet d’afficher la traduction basque correspondante
    var translation: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        lblFr.text = original
        lblEu.text = translation
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
