//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let sentimentClassifier = TweetSentimentClassifier()
    let swifter = Swifter(consumerKey: "03wPGccPY0qFmEygl55Ce4IJK", consumerSecret: "dozRI93e1IRIlJVfsUso08Fbg9ChYQbgxG2yMzhNTFdANRndkQ")
    let tweetCount = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        fetchTweet()
    }
    
    func fetchTweet() {
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText,lang: "en",count: tweetCount,tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                self.calculateScore(with:tweets)
                
            }) { (error) in
                print("There was an error with the Twitter API Request, \(error)")
            }
        }
    }
    
    func calculateScore(with tweets: [TweetSentimentClassifierInput]) {
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            var score = 0
            for pred in predictions {
                if pred.label == "Pos" {
                    score += 1
                } else if(pred.label == "Neg") {
                    score -= 1
                }
            }
            updateEmoji(score)
        } catch {
            print("Error in making predictions. \(error)")
        }
    }
    
    func updateEmoji(_ score: Int) {
        if score > 20 {
            sentimentLabel.text = "😍"
        } else if score > 10 {
            sentimentLabel.text = "😀"
        } else if score > 0 {
            sentimentLabel.text = "🙂"
        } else if score == 0 {
            sentimentLabel.text = "😐"
        } else if score > -10 {
            sentimentLabel.text = "😕"
        } else if score > -20 {
            sentimentLabel.text = "😡"
        } else {
            sentimentLabel.text = "🤮"
        }
    }
}
