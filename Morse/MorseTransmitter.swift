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

	static let standardWordLength:Int = 50

	private let _getTimeStampQueue = dispatch_queue_create("Get Time Stamp Queue", nil)

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

	// TODO: Not used, because it doesn't work
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

	// Assumes morse is valid
	func getTimeStamp(withScalar scalar:Float = 1.0, delay:NSTimeInterval = 0.0) -> [NSTimeInterval]? {
		if self.morse == nil || self.morse!.isEmpty { return nil }
		if scalar <= 0 { return nil }
		if scalar <= 1.0/60 {
			NSLog("Input/output scalar(\(scalar)) is less than 1/60, may cause serious encoding or decoding problem.")
		}
		var res:[NSTimeInterval] = [delay]
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

	// *****************************
	// MARK: Audio Input Processing
	// *****************************
	var delegate:MorseTransmitterDelegate?

	private let _audioAnalysisQueue = dispatch_queue_create("Audio Analysis Queue", nil)
	private var _currentLetterMorse = ""
	private var _inputWPM = 15
	private var _sampleRate:Double = -1
	private var _singalStarted = false
	private var _counter = 0
	private let _spellChecker = UITextChecker()
	// This variable means how many callbacks should one unit be with the given WPM and the default sample rate (44100).
	private var _unitLength:Float {
		let unitsPerSecond = Double(self._inputWPM) * 50.0 / 60.0
		return Float(self._sampleRate/1000.0/unitsPerSecond)
	}

	private var _oneUnitLengthRange:Range<Int> {
//		return	Int(floor(self._unitLength))...Int(floor(self._unitLength * 2))
		return 2...5
	}

	private var _threeUnitLengthRange:Range<Int> {
//		return	self._oneUnitLengthRange.endIndex...self._oneUnitLengthRange.startIndex * 3
		return 7...14
	}

	private var _sevenUnitLengthRange:Range<Int> {
//		return	self._threeUnitLengthRange.endIndex...self._oneUnitLengthRange.startIndex * 99
		return 15...999
	}

	private var _isDuringSignal = false
	private var _levelsRecord:[Float] = []
	private var _minLvl = Int.max

	// ******************************************************************************
	// WARNNING: MUST call this before using this tramsmitter to process input audio.
	// ******************************************************************************
	func resetForAudioInput() {
		self._morse = ""
		self._text = ""
		self._currentLetterMorse = ""
		self._inputWPM = 15
		self._sampleRate = -1
	}

	// This method is called when an audio sample has been recieved in the microphone.
	func microphone(microphone: EZMicrophone!, maxFrequencyMagnitude: Float) {
		dispatch_sync(self._audioAnalysisQueue) {
			// Setup sample rate
			if self._sampleRate < 0 {
				self._sampleRate = microphone.audioStreamBasicDescription().mSampleRate
				#if DEBUG
				print(self._unitLength)
				print(self._oneUnitLengthRange)
				print(self._threeUnitLengthRange)
				print(self._sevenUnitLengthRange)
				#endif
			}
			// Setup WPM
			self._inputWPM = 15 // TODO: Better algorithm for this

			let level = pow(maxFrequencyMagnitude * 100, 1.5)

			// Calculate when should the isDuringSignal bar be set.
			self._levelsRecord.append(level)
			let recordLength = (self._oneUnitLengthRange.startIndex + self._oneUnitLengthRange.endIndex - 1)/2
			while self._levelsRecord.count > recordLength {
				self._levelsRecord.removeFirst()
			}
			let avgLvl = (self._levelsRecord.reduce(0) { return $0 + $1 }) / Float(recordLength)
			self._isDuringSignal = level >= max(avgLvl/3.0, 1) // FIXME: better algorithm. This one does not work properly on high or low input volumes.
			#if DEBUG
				// If debugging, print the wave form in the console.
				if printAudiWaveFormWhenDebug {
					for _ in 0...Int(level) {
						print(self._isDuringSignal ? "*" : "=", separator: "", terminator: "")
					}
					print("\(Int(level))", separator: "", terminator: "")
					print(" \(Int(avgLvl/3.0))")
				}
			#endif

			if self._isDuringSignal {
				if self._singalStarted {
					self._counter++
				} else {
					// If this is where the singal rises
					if !self._text!.isEmpty {
						if self._threeUnitLengthRange.contains(self._counter) {
							self.appendUnit(.LetterGap)
						} else if self._sevenUnitLengthRange.contains(self._counter) {
							self.appendUnit(.WordGap)
						}
					}
					self._counter = 1
					self._singalStarted = true
				}
			} else {
				if self._singalStarted {
					// If this is where the singal falls
					if self._oneUnitLengthRange.contains(self._counter) {
						self.appendUnit(.Dit)
					} else if self._threeUnitLengthRange.contains(self._counter) || self._sevenUnitLengthRange.contains(self._counter) {
						self.appendUnit(.Dah)
					}
					self._counter = 1
					self._singalStarted = false
				} else {
					self._counter++
				}
			}
		}
	}

	// ********************************************************************************************************************
	// This method is called when a piece of audio is processed and a unit is sure will be appended to the Morse code.
	// Only 4 type of units can be appended: DIT, DAH, LETTERGAP, WORDGAP. UNITGAP will be appended automatically.
	// ********************************************************************************************************************
	private func appendUnit(unit:MorseUnit) {
		if unit == .LetterGap || unit == .WordGap {
			// If we're appending a gap, reset currentLetterMorse
			self._currentLetterMorse = ""
			self._morse?.appendContentsOf(unit.rawValue)
			if unit == .WordGap {
				self._text?.appendContentsOf(" ")

				var correctedText = self._text!
				// If the user wants to auto correct mis-spelled words when using audio input to translate morse, this chunk of code does it.
				// This is only done after appending a white space
				if appDelegate.autoCorrectMissSpelledWordsForAudioInput {
					// Check if the current language code can be spell-checked and romanized, this language list is done manually.
					// If it cannot be spell-checked, use English by default.
					var checkedLanguage = appDelegate.currentLocaleLanguageCode
					var canBeChecked = false
					for lan in canBeSpellCheckedLanguageCodes {
						if checkedLanguage.hasPrefix(lan) {
							canBeChecked = true
							break
						}
					}
					if !canBeChecked {
						checkedLanguage = "en"
					}
					// Find the first mis-spelled range.
					var misSpelledRange = self._spellChecker.rangeOfMisspelledWordInString(correctedText, range: NSMakeRange(0, correctedText.lengthOfBytesUsingEncoding(NSASCIIStringEncoding)), startingAt: 0, wrap: false, language: checkedLanguage)
					// Keep fixing mis-spelled words while there is one.
					while misSpelledRange.location != NSNotFound {
						// See if there is any guess for the word.
						if let guessedWords = self._spellChecker.guessesForWordRange(misSpelledRange, inString: correctedText, language: checkedLanguage) as? [String] {
							if !guessedWords.isEmpty {
								let guessedWordsUpperCase = guessedWords.map { $0.uppercaseString }
								let misSpelledIndexRange = correctedText.startIndex.advancedBy(misSpelledRange.location)..<correctedText.startIndex.advancedBy(misSpelledRange.location + misSpelledRange.length)
								let misSpelledWord = correctedText.substringWithRange(misSpelledIndexRange)
								// Check if guessed words already contains the mis-spelled word without case sensitive, sometime spell checker is case sensitive.
								if !guessedWordsUpperCase.contains(misSpelledWord.uppercaseString) {
									// If there is at least one guessed word, replace the mis-spelled word with the first guessed word.
									let firstGuessedWord = guessedWords[0]
									#if DEBUG
										print("Mis-Spelled Word: \(misSpelledWord) | Guessed Words: \(guessedWords)")
									#endif
									correctedText.replaceRange(misSpelledIndexRange, with: firstGuessedWord)
								}
								// Keep looking for mis-spelled words
								misSpelledRange = self._spellChecker.rangeOfMisspelledWordInString(correctedText, range: NSMakeRange(0, correctedText.lengthOfBytesUsingEncoding(NSASCIIStringEncoding)), startingAt: misSpelledRange.location + misSpelledRange.length - 1, wrap: false, language: checkedLanguage)
							}
						}
					}
					self._text = correctedText
				}
			}
		} else {
			let startOfALetter = self._currentLetterMorse.isEmpty
			// We're sure unit is either DIT or DAH at this point
			if !self._currentLetterMorse.isEmpty && !self._currentLetterMorse.hasPrefix(" ") {
				self._currentLetterMorse.appendContentsOf(" ")
				self._morse?.appendContentsOf(" ")
			}
			self._currentLetterMorse.appendContentsOf(unit.rawValue)
			self._morse?.appendContentsOf(unit.rawValue)

			// Change text
			var letter = MorseTransmitter.decodeMorseStringToTextDictionary[self._currentLetterMorse]
			if letter == nil {
				letter = notRecognizedLetterStr
			}
			if !startOfALetter {
				self._text?.removeAtIndex(self._text!.endIndex.advancedBy(-1))
			}
			self._text?.appendContentsOf(letter!)
		}
		self.delegate?.transmitterContentDidChange?(self._text!, morse: self._morse!)
	}
}

// *****************************
// MARK: Types and Constants
// *****************************

enum MorseUnit:String {
	case Dit = "•"
	case Dah = "—"
	case LetterGap = "   "
	case WordGap = "       "
}

// Strings
private let UNIT_DIT_STRING = MorseUnit.Dit.rawValue
private let UNIT_DAH_STRING = MorseUnit.Dah.rawValue
private let UNIT_GAP_STRING = " "
private let WORD_GAP_STRING = MorseUnit.WordGap.rawValue
private let LETTER_GAP_STRING = MorseUnit.LetterGap.rawValue

// Lengths
private let DIT_LENGTH:Float = 1.0
private let UNIT_GAP_LENGTH:Float = 1.0
private let DAH_LENGTH:Float = 3.0
private let LETTER_GAP_LENGTH:Float = 3.0
private let WORD_GAP_LENGTH:Float = 7.0

// Dispatch Queues
private let _encodeQueue = dispatch_queue_create("Encode Queue", nil)
private let _decodeQueue = dispatch_queue_create("Decode Queue", nil)

// *****************************
// MARK: Private Helper Methods
// *****************************

// Ignores invalid character
private func encodeTextToMorse(text:String!) -> String? {
	if text == nil || text.isEmpty { return nil }
	var res = ""
	dispatch_sync(_encodeQueue) {
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
	dispatch_sync(_decodeQueue) {
		let words = morse.componentsSeparatedByString(WORD_GAP_STRING)
		for word in words {
			let chArr = word.componentsSeparatedByString(LETTER_GAP_STRING)
			var wordStr:String = ""
			for ch in chArr {
				if let chText = MorseTransmitter.decodeMorseStringToTextDictionary[String(ch)] {
					wordStr += chText
				} else {
					wordStr += notRecognizedLetterStr
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

