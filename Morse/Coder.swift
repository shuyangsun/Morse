//
//  Coder.swift
//  Morse
//
//  Created by Shuyang Sun on 11/30/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import Foundation

class MorseCoder {
	private var _text:String?
	private var _morse:String?

	var text:String? {
		set {
			self._text = newValue
			self._morse = nil
		}
		get {
			return self._text == nil ? decodeMorseToText(self._morse) : self._text
		}
	}

	var morse:String? {
		set {
			self._morse = newValue
			self._text = nil
		}
		get {
			return self._morse == nil ? encodeTextToMorse(self._text) : self._morse
		}
	}

	init() {

	}

	// Assume morse is valid
	func getTimeStamp(withScalar scalar:Float = 1.0) -> [NSTimeInterval]? {
		if self.morse == nil || self.morse!.isEmpty { return nil }
		if scalar <= 0 { return nil }
		if scalar <= 1.0/60 {
			NSLog("Scalar(\(scalar)) is less than 1/60, may cause serious encoding or decoding problem.")
		}
		var res:[NSTimeInterval] = [0.0]
		dispatch_sync(dispatch_queue_create("Get Time Stamp Queue", nil)) {
			// Seperate words
			let words = self.morse!.componentsSeparatedByString(WORD_GAP_STRING)
			var appendedWord = false
			for word in words {
				// Seperate letters
				let letters = word.componentsSeparatedByString(LETTER_GAP_STRING)
				var appendedLetter = false
				for letter in letters {
					// Seperate units
					let units = letter.componentsSeparatedByString(UNIT_GAP_STRING)
					var appendedUnit = false
					for unit in units {
						if unit == UNIT_DOT_STRING  {
							res.append(res.last! + NSTimeInterval(DOT_LENGTH * scalar))
							res.append(res.last! + NSTimeInterval(UNIT_GAP_LENGTH * scalar))
							appendedUnit = true
						} else if unit == UNIT_DASH_STRING {
							res.append(res.last! + NSTimeInterval(DASH_LENGTH * scalar))
							res.append(res.last! + NSTimeInterval(UNIT_GAP_LENGTH * scalar))
							appendedUnit = true
						}
					}
					if appendedUnit {
						res.removeLast()
						res.append(res.last! + NSTimeInterval(LETTER_GAP_LENGTH * scalar))
						appendedLetter = true
					}
				}
				if appendedLetter {
					res.removeLast()
					res.append(res.last! + NSTimeInterval(WORD_GAP_LENGTH * scalar))
					appendedWord = true
				}
			}
			if appendedWord {
				res.removeLast()
			}
		}
		return res.count == 1 ? nil : res
	}
}

// Ignores invalid character
private func encodeTextToMorse(text:String!) -> String? {
	if text == nil || text.isEmpty { return nil }
	var res = ""
	dispatch_sync(dispatch_queue_create("Encode Queue", nil)) {
		let words = text.lowercaseString.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: " \t\n\r"))
		for word in words {
			let chArr = word.characters
			var wordStr:String = ""
			for ch in chArr {
				if let chMorseString = encoderTextToMorseStringDictionary[String(ch)] {
					wordStr += chMorseString
					wordStr += LETTER_GAP_STRING
				}
			}

			if !wordStr.isEmpty {
				res += wordStr
				// 4 spaces, on top of the last 3, make it 7
				res += "    "
			}
		}
		if !res.isEmpty {
			res.removeRange(res.endIndex.advancedBy(-7)..<res.endIndex)
		}
	}
	return res.isEmpty ? nil : res
}

// Assume morse is valid
private func decodeMorseToText(morse:String!) -> String? {
	if morse == nil || morse.isEmpty { return nil }
	var res = ""
	dispatch_sync(dispatch_queue_create("Decode Queue", nil)) {
		let words = morse.componentsSeparatedByString(WORD_GAP_STRING)
		for word in words {
			let chArr = word.componentsSeparatedByString(LETTER_GAP_STRING)
			var wordStr:String = ""
			for ch in chArr {
				if let chText = decoderMorseStringToTextDictionary[String(ch)] {
					wordStr += chText
				}
			}

			if !wordStr.isEmpty {
				res += wordStr
				res += " "
			}
		}
		if !res.isEmpty {
			res.removeAtIndex(res.endIndex.advancedBy(-1))
		}
	}
	return res.isEmpty ? nil : res
}

private let WORD_GAP_STRING = "       "
private let LETTER_GAP_STRING = "   "
private let UNIT_GAP_STRING = " "
private let UNIT_DOT_STRING = "."
private let UNIT_DASH_STRING = "___"
private let DOT_LENGTH:Float = 1.0
private let UNIT_GAP_LENGTH:Float = 1.0
private let DASH_LENGTH:Float = 3.0
private let LETTER_GAP_LENGTH:Float = 3.0
private let WORD_GAP_LENGTH:Float = 7.0

private let encoderTextToMorseStringDictionary:Dictionary<String, String> = [
	"a": ". ___",
	"b": "___ . . .",
	"c": "___ . ___ .",
	"d": "___ . .",
	"e": ".",
	"f": ". . ___ .",
	"g": "___ ___ .",
	"h": ". . . .",
	"i": ". .",
	"j": ". ___ ___ ___",
	"k": "___ . ___",
	"l": ". ___ . .",
	"m": "___ ___",
	"n": "___ .",
	"o": "___ ___ ___",
	"p": ". ___ ___ .",
	"q": "___ ___ . ___",
	"r": ". ___ .",
	"s": ". . .",
	"t": "___",
	"u": ". . ___",
	"v": ". . . ___",
	"w": ". ___ ___",
	"x": "___ . . ___",
	"y": "___ . ___ ___",
	"z": "___ ___ . .",
	"1": ". ___ ___ ___ ___",
	"2": ". . ___ ___ ___",
	"3": ". . . ___ ___",
	"4": ". . . . ___",
	"5": ". . . . .",
	"6": "___ . . . .",
	"7": "___ ___ . . .",
	"8": "___ ___ ___ . .",
	"9": "___ ___ ___ ___ .",
	"0": "___ ___ ___ ___ ___",
	".": ". ___ . ___ . ___",
	",": "___ ___ . . ___ ___",
	"'": ". ___ ___ ___ ___ .",
	"\"": ". ___ . . ___ .",
	"_": ". . ___ ___ . ___",
	":": "___ ___ ___ . . .",
	";": "___ . ___ . ___ .",
	"?": ". . ___ ___ . .",
	"!": "___ . ___ . ___ ___",
	"-": "___ . . . . ___",
	"+": ". ___ . ___ .",
	"/": "___ . . ___ .",
	"(": "___ . ___ ___ .",
	")": "___ . ___ ___ . ___",
	"&": ". ___ . . .",
	"=": "___ . . . ___",
	"@": ". ___ ___ . ___ .",
	"$": ". . . ___ . . ___"
]

private let decoderMorseStringToTextDictionary:Dictionary<String, String> = [
	". ___": "a",
	"___ . . .": "b",
	"___ . ___ .": "c",
	"___ . .": "d",
	".": "e",
	". . ___ .": "f",
	"___ ___ .": "g",
	". . . .": "h",
	". .": "i",
	". ___ ___ ___": "j",
	"___ . ___": "k",
	". ___ . .": "l",
	"___ ___": "m",
	"___ .": "n",
	"___ ___ ___": "o",
	". ___ ___ .": "p",
	"___ ___ . ___": "q",
	". ___ .": "r",
	". . .": "s",
	"___": "t",
	". . ___": "u",
	". . . ___": "v",
	". ___ ___": "w",
	"___ . . ___": "x",
	"___ . ___ ___": "y",
	"___ ___ . .": "z",
	". ___ ___ ___ ___": "1",
	". . ___ ___ ___": "2",
	". . . ___ ___": "3",
	". . . . ___": "4",
	". . . . .": "5",
	"___ . . . .": "6",
	"___ ___ . . .": "7",
	"___ ___ ___ . .": "8",
	"___ ___ ___ ___ .": "9",
	"___ ___ ___ ___ ___": "0",
	". ___ . ___ . ___": ".",
	"___ ___ . . ___ ___": ",",
	". ___ ___ ___ ___ .": "'",
	". ___ . . ___ .": "\"",
	". . ___ ___ . ___": "_",
	"___ ___ ___ . . .": ":",
	"___ . ___ . ___ .": ";",
	". . ___ ___ . .": "?",
	"___ . ___ . ___ ___": "!",
	"___ . . . . ___": "-",
	". ___ . ___ .": "+",
	"___ . . ___ .": "/",
	"___ . ___ ___ .": "(",
	"___ . ___ ___ . ___": ")",
	". ___ . . .": "&",
	"___ . . . ___": "=",
	". ___ ___ . ___ .": "@",
	". . . ___ . . ___": "$"
]



