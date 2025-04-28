//
//  CloudAPI.swift
//  EuskApp
//
//  Created by etudiant on 22/04/2025.
//

import Foundation
import AVFoundation

class CloudAPI {
    static let apiKey = "AIzaSyCkCLyb9OGA07Nlq1lGbVCKvJ1-qQzzwLU"


    // MARK: Cloud Translation API - Traduction automatique basque-français

    // Traduit un texte vers la langue cible
    static func translate(text: String, targetLang: String, completion: @escaping (String?) -> Void) {
        // Construit l'URL de la requête
        let urlString = "https://translation.googleapis.com/language/translate/v2?key=\(apiKey)"

        // Vérifie la validité de l'URL
        guard let url = URL(string: urlString) else {
            print("URL invalide")
            completion(nil)
            return
        }

        // Prépare les paramètres pour la requête
        let parameters: [String: Any] = ["q": text, "target": targetLang, "format": "text"]

        // Prépare la requête POST
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        // Lance la requête
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur réseau : \(error.localizedDescription)")
                completion(nil)
                return
            }

            // Affiche le code HTTP pour debug
            if let httpResponse = response as? HTTPURLResponse {
                print("Code HTTP : \(httpResponse.statusCode)")
            }

            // Vérifie la présence de données
            guard let data = data else {
                print("Données vides")
                completion(nil)
                return
            }

            // Affiche la réponse brute JSON pour debug
            if let jsonStr = String(data: data, encoding: .utf8) {
                print("Réponse JSON brute : \(jsonStr)")
            }

            // Tente d'extraire la traduction du JSON
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataObject = json["data"] as? [String: Any],
               let translations = dataObject["translations"] as? [[String: Any]],
               let translatedText = translations.first?["translatedText"] as? String {

                // Retourne la traduction sur le thread principal
                DispatchQueue.main.async {
                    completion(translatedText)
                }
            } else {
                print("Erreur de parsing JSON")
                completion(nil)
            }
        }
        task.resume()
    }


    // MARK: Cloud Text-to-Speech API - Conversion du texte en audio

    static var audioPlayer: AVAudioPlayer?

    // Synthétise un texte en fichier audio
    static func audio(text: String, targetLang: String) {
        // Construit l'URL de la requête
        let urlString = "https://texttospeech.googleapis.com/v1/text:synthesize?key=\(apiKey)"

        // Vérifie l'URL
        guard let url = URL(string: urlString) else {
            print("URL invalide")
            return
        }

        // Prépare les paramètres pour la requête
        let parameters: [String: Any] = [
            "input": ["text": text],
            "voice": ["languageCode": targetLang, "ssmlGender": "NEUTRAL"],
            "audioConfig": ["audioEncoding": "MP3"]
        ]

        // Configure la requête POST
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        // Lance la requête
        URLSession.shared.dataTask(with: request) { data, _, error in
            // Vérifie les erreurs
            guard error == nil, let data = data else {
                print("Erreur TTS : \(error?.localizedDescription ?? "inconnue")")
                return
            }

            // Tente d'extraire l'audio depuis la réponse
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let audioContent = result["audioContent"] as? String,
               let audioData = Data(base64Encoded: audioContent) {

                DispatchQueue.main.async {
                    do {
                        // Joue l'audio
                        audioPlayer = try AVAudioPlayer(data: audioData)
                        audioPlayer?.prepareToPlay()
                        audioPlayer?.play()
                    } catch {
                        print("Erreur de lecture audio : \(error)")
                    }
                }
            } else {
                print("Erreur parsing réponse TTS")
            }
        }
        .resume()
    }
}
