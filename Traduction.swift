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
    
    let apiKey = "AIzaSyCkCLyb9OGA07Nlq1lGbVCKvJ1-qQzzwLU"
    
    func translate(text: String, targetLang: String, completion: @escaping (String?) -> Void) {
        let urlString = "https://translation.googleapis.com/language/translate/v2?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            print("❌ URL invalide")
            completion(nil)
            return
        }
        
        let parameters: [String: Any] = ["q": text, "target": targetLang, "format": "text"]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Erreur réseau : \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Code HTTP : \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌ Données vides")
                completion(nil)
                return
            }
            
            // Afficher la réponse brute pour débogage
            if let jsonStr = String(data: data, encoding: .utf8) {
                print("📦 Réponse JSON brute : \(jsonStr)")
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataObject = json["data"] as? [String: Any],
               let translations = dataObject["translations"] as? [[String: Any]],
               let translatedText = translations.first?["translatedText"] as? String {
                
                DispatchQueue.main.async {
                    AppDelegate.addTrans(original: text, translation: translatedText)
                    completion(translatedText)
                }
            } else {
                print("❌ Erreur de parsing JSON")
                completion(nil)
            }
        }
        task.resume()
    }

    // Français vers basque
    @IBAction func translateFrIntoEu(_ sender: Any) {
        guard let text = tfFr.text, !text.isEmpty else {
            return
        }
        translate(text: text, targetLang: "eu") { translation in
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

    // Basque vers français
    @IBAction func transEuIntoFr(_ sender: Any) {
        guard let text = tfEu.text, !text.isEmpty else {
            return
        }
        translate(text: text, targetLang: "eu") { translation in
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
    
}

