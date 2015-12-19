//
//  MorseTransmitter.swift
//  Morse
//
//  Created by Shuyang Sun on 11/30/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import Foundation

class MorseTransmitter {
	private var _text:String?
	private var _morse:String?

	static let keys:[String] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "à", "å", "ä", "ą", "æ", "ć", "ĉ", "ç", "đ", "ð", "é", "ę", "è", "ĝ", "ĥ", "ĵ", "ł", "ń", "ñ", "ó", "ö", "ø", "ś", "ŝ", "š", "þ", "ü", "ŭ", "ź", "ż", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ".", ",", "'", "\"", "_", ":", ";", "?", "!", "-", "+", "/", "(", ")", "&", "=", "@", "$"]

	static let encodeTextToMorseStringDictionary:Dictionary<String, String> = [
		// English Alphabets
		"a": "• —",
		"b": "— • • •",
		"c": "— • — •",
		"d": "— • •",
		"e": "•",
		"f": "• • — •",
		"g": "— — •",
		"h": "• • • •",
		"i": "• •",
		"j": "• — — —",
		"k": "— • —",
		"l": "• — • •",
		"m": "— —",
		"n": "— •",
		"o": "— — —",
		"p": "• — — •",
		"q": "— — • —",
		"r": "• — •",
		"s": "• • •",
		"t": "—",
		"u": "• • —",
		"v": "• • • —",
		"w": "• — —",
		"x": "— • • —",
		"y": "— • — —",
		"z": "— — • •",
		// Other Latin Alphabets (there are characters sharing one morese code here)
		"à": "• — — • —",
		"å": "• — — • —",
		"ä": "• — • —",
		"ą": "• — • —",
		"æ": "• — • —",
		"ć": "— • — • •",
		"ĉ": "— • — • •",
		"ç": "— • — • •",
		"đ": "• • — • •",
		"ð": "• • — — •",
		"é": "• • — • •",
		"ę": "• • — • •",
		"è": "• — • • —",
		"ĝ": "— — • — •",
		"ĥ": "— — — —",
		"ĵ": "• — — — •",
		"ł": "• — • • —",
		"ń": "— — • — —",
		"ñ": "— — • — —",
		"ó": "— — — •",
		"ö": "— — — •",
		"ø": "— — — •",
		"ś": "• • • — • • •",
		"ŝ": "• • • — •",
		"š": "— — — —",
		"þ": "• — — • •",
		"ü": "• • — —",
		"ŭ": "• • — —",
		"ź": "— — • • — •",
		"ż": "— — • • —",
		// Numbers
		"1": "• — — — —",
		"2": "• • — — —",
		"3": "• • • — —",
		"4": "• • • • —",
		"5": "• • • • •",
		"6": "— • • • •",
		"7": "— — • • •",
		"8": "— — — • •",
		"9": "— — — — •",
		"0": "— — — — —",
		// Special Characters
		".": "• — • — • —",
		",": "— — • • — —",
		"'": "• — — — — •",
		"\"": "• — • • — •",
		"_": "• • — — • —",
		":": "— — — • • •",
		";": "— • — • — •",
		"?": "• • — — • •",
		"!": "— • — • — —",
		"-": "— • • • • —",
		"+": "• — • — •",
		"/": "— • • — •",
		"(": "— • — — •",
		")": "— • — — • —",
		"&": "• — • • •",
		"=": "— • • • —",
		"@": "• — — • — •",
		"$": "• • • — • • —"
	]

	static let decodeMorseStringToTextDictionary:Dictionary<String, String> = [
		// English Alphabets
		"• —": "a",
		"— • • •": "b",
		"— • — •": "c",
		"— • •": "d",
		"•": "e",
		"• • — •": "f",
		"— — •": "g",
		"• • • •": "h",
		"• •": "i",
		"• — — —": "j",
		"— • —": "k",
		"• — • •": "l",
		"— —": "m",
		"— •": "n",
		"— — —": "o",
		"• — — •": "p",
		"— — • —": "q",
		"• — •": "r",
		"• • •": "s",
		"—": "t",
		"• • —": "u",
		"• • • —": "v",
		"• — —": "w",
		"— • • —": "x",
		"— • — —": "y",
		"— — • •": "z",
		// Other Latin Alphabets (there are characters sharing one morese code here)
		"• — — • —": "à",
		"• — • —": "æ",
		"— • — • •": "ć",
		"• • — — •": "ð",
		"• • — • •": "é",
		"• — • • —": "è",
		"— — • — •": "ĝ",
		"— — — —": "ĥ",
		"• — — — •": "ĵ",
		"— — • — —": "ń",
		"— — — •": "ø",
		"• • • — • • •": "ś",
		"• • • — •": "ŝ",
		"• — — • •": "þ",
		"• • — —": "ü",
		"— — • • — •": "ź",
		"— — • • —": "ż",
		// Numbers
		"• — — — —": "1",
		"• • — — —": "2",
		"• • • — —": "3",
		"• • • • —": "4",
		"• • • • •": "5",
		"— • • • •": "6",
		"— — • • •": "7",
		"— — — • •": "8",
		"— — — — •": "9",
		"— — — — —": "0",
		// Special Characters
		"• — • — • —": ".",
		"— — • • — —": ",",
		"• — — — — •": "'",
		 "• — • • — •": "\"",
		"• • — — • —": "_",
		"— — — • • •": ":",
		"— • — • — •": ";",
		"• • — — • •": "?",
		"— • — • — —": "!",
		"— • • • • —": "-",
		"• — • — •": "+",
		"— • • — •": "/",
		"— • — — •": "(",
		"— • — — • —": ")",
		"• — • • •": "&",
		"— • • • —": "=",
		"• — — • — •": "@",
		"• • • — • • —": "$"
	]

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

	func morseRangeFromTextRange(range:NSRange) -> NSRange {
		if self.text != nil && self.morse != nil &&
			range.location > 0 && range.location + range.length <= self.text!.lengthOfBytesUsingEncoding(NSISOLatin1StringEncoding) {
			let textStr = self.text!

			let preText = textStr.substringWithRange(textStr.startIndex..<textStr.startIndex.advancedBy(range.location)) // ******TextSelected****** // This is the first "******" part.
			let postText = textStr.substringWithRange(textStr.startIndex..<textStr.startIndex.advancedBy(range.location + range.length)) // ******TextSelected****** // This is the "******TextSelected" part.
			let preMorse = encodeTextToMorse(preText)
			let endMorse = encodeTextToMorse(postText)
			let location = preMorse?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
			let end = endMorse?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
			if location != nil && end != nil {
				return NSRange(location: location!, length: end! - location!)
			}
		}

		let morseLen = self.morse?.lengthOfBytesUsingEncoding(NSISOLatin1StringEncoding)
		let defaultLocation = morseLen == nil ? 0 : morseLen!
		let defaultRange = NSRange(location: defaultLocation, length: 0)
		return defaultRange
	}

	// Assume morse is valid
	func getTimeStamp(withScalar scalar:Float = 1.0) -> [NSTimeInterval]? {
		if self.morse == nil || self.morse!.isEmpty { return nil }
		if scalar <= 0 { return nil }
		if scalar <= 1.0/60 {
			NSLog("Input/output scalar(\(scalar)) is less than 1/60, may cause serious encoding or decoding problem.")
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
						if unit == UNIT_DIT_STRING  {
							res.append(res.last! + NSTimeInterval(DIT_LENGTH * scalar))
							res.append(res.last! + NSTimeInterval(UNIT_GAP_LENGTH * scalar))
							appendedUnit = true
						} else if unit == UNIT_DAH_STRING {
							res.append(res.last! + NSTimeInterval(DAH_LENGTH * scalar))
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
				if let chMorseString = MorseTransmitter.encodeTextToMorseStringDictionary[String(ch)] {
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
				if let chText = MorseTransmitter.decodeMorseStringToTextDictionary[String(ch)] {
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
private let UNIT_DIT_STRING = "•"
private let UNIT_DAH_STRING = "—"
private let DIT_LENGTH:Float = 1.0
private let UNIT_GAP_LENGTH:Float = 1.0
private let DAH_LENGTH:Float = 3.0
private let LETTER_GAP_LENGTH:Float = 3.0
private let WORD_GAP_LENGTH:Float = 7.0

