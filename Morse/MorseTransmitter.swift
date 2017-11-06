//
//  MorseTransmitter.swift
//  Morse
//
//  Created by Shuyang Sun on 11/30/15.
//  Copyright © 2015 Shuyang Sun. All rights reserved.
//

import Foundation

// *****************************
// MARK: Types and Constants
// *****************************

enum MorseUnit:String {
	case Dit = "•"
	case Dah = "—"
	case LetterGap = "   "
	case WordGap = "       "
}

// This enum means how the prosigns are translated. Value 0 is the default translation type.
enum ProsignTranslationType:Int {
	case always = 0
	case onlyWhenSingulated = 1
	case none = 2
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
private let _encodeQueue = DispatchQueue(label: "Encode Queue", attributes: [])
private let _decodeQueue = DispatchQueue(label: "Decode Queue", attributes: [])
private let _futureQueue = DispatchQueue(label: "Transmitter Future Serial Queue", attributes: [])
private let _globalQueueDefault = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)

private let numberOfNewLineForNewPageProsign = 5
private var newPageProsignText:String {
	return String(repeating: "\n", count: numberOfNewLineForNewPageProsign)
}

class MorseTransmitter {
	fileprivate var _text:String?
	fileprivate var _morse:String?

	static let standardWordLength:Int = 50

	fileprivate let _getTimeStampQueue = DispatchQueue(label: "Get Time Stamp Queue", attributes: [])

	static let keys:[String] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "à", "å", "ä", "ą", "æ", "ć", "ĉ", "ç", "đ", "ð", "é", "ę", "è", "ĝ", "ĥ", "ĵ", "ł", "ń", "ñ", "ó", "ö", "ø", "ś", "ŝ", "š", "þ", "ü", "ŭ", "ź", "ż", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ".", ",", "'", "\"", "_", ":", ";", "?", "!", "-", "+", "/", "(", ")", "&", "=", "@", "$"]

	static let prosignMorseToTextStringDictionary:Dictionary<String, String> = [
		"• — • —": "\n",
		"• — • — •": newPageProsignText,
		"• — • • •": prosignContainerLeft + LocalizedStrings.Prosign.wait + prosignContainerRight,
		"— • • • — • —": prosignContainerLeft + LocalizedStrings.Prosign.backToYou + prosignContainerRight,
		"— • • • —": "\n\n",
		"— • — • • — • •": prosignContainerLeft + LocalizedStrings.Prosign.closing + prosignContainerRight,
		"— • — • —": prosignContainerLeft + LocalizedStrings.Prosign.attention + prosignContainerRight,
		"• • • • • • •": prosignContainerLeft + LocalizedStrings.Prosign.error + prosignContainerRight,
		"— • —": prosignContainerLeft + LocalizedStrings.Prosign.inviteToTransmitAnyStation + prosignContainerRight,
		"— • — — •": prosignContainerLeft + LocalizedStrings.Prosign.inviteToTransmitNamedStation + prosignContainerRight,
		"— • • — — —": prosignContainerLeft + LocalizedStrings.Prosign.shiftToWabunCode + prosignContainerRight,
		"• • • — • —": prosignContainerLeft + LocalizedStrings.Prosign.endOfContact + prosignContainerRight,
		"• • • — •": prosignContainerLeft + LocalizedStrings.Prosign.understood + prosignContainerRight,
		"• • • — — — • • •": prosignContainerLeft + LocalizedStrings.Prosign.emergency + prosignContainerRight
	]

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
			let res = self._text == nil ? self.decodeMorseToText(self._morse) : self._text
			return res?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		}
	}

	var morse:String? {
		set {
			self._morse = newValue
			self._text = nil
		}
		get {
			let res = self._morse == nil ? self.encodeTextToMorse(self._text) : self._morse
			return res?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		}
	}

	init(prosignTranslationType:ProsignTranslationType = appDelegate.prosignTranslationType) {
		appDelegate.prosignTranslationType = prosignTranslationType
	}

	// TODO: Not used, because it doesn't work
	func morseRangeFromTextRange(_ range:NSRange) -> NSRange {
		if self.text != nil && self.morse != nil &&
			range.location > 0 && range.location + range.length <= self.text!.lengthOfBytes(using: String.Encoding.isoLatin1) {
			let textStr = self.text!
			let preText = textStr.substring(with: textStr.startIndex..<textStr.characters.index(textStr.startIndex, offsetBy: range.location)) // ******TextSelected****** // This is the first "******" part.
			let postText = textStr.substring(with: textStr.startIndex..<textStr.characters.index(textStr.startIndex, offsetBy: range.location + range.length)) // ******TextSelected****** // This is the "******TextSelected" part.
			let preMorse = self.encodeTextToMorse(preText)
			let endMorse = self.encodeTextToMorse(postText)
			let location = preMorse?.lengthOfBytes(using: String.Encoding.utf8)
			let end = endMorse?.lengthOfBytes(using: String.Encoding.utf8)
			if location != nil && end != nil {
				return NSRange(location: location!, length: end! - location!)
			}
		}

		let morseLen = self.morse?.lengthOfBytes(using: String.Encoding.isoLatin1)
		let defaultLocation = morseLen == nil ? 0 : morseLen!
		let defaultRange = NSRange(location: defaultLocation, length: 0)
		return defaultRange
	}

	// Assumes morse is valid
	func getTimeStamp(withScalar scalar:Float = 1.0, delay:TimeInterval = 0.0) -> [TimeInterval]? {
		if self.morse == nil || self.morse!.isEmpty { return nil }
		if scalar <= 0 { return nil }
		if scalar <= 1.0/60 {
			NSLog("Input/output scalar(\(scalar)) is less than 1/60, may cause serious encoding or decoding problem.")
		}
		var res:[TimeInterval] = [delay]
		DispatchQueue(label: "Get Time Stamp Queue", attributes: []).sync {
			// Seperate words
			let words = self.morse!.components(separatedBy: WORD_GAP_STRING)
			var appendedWord = false
			for word in words {
				// Seperate letters
				let letters = word.components(separatedBy: LETTER_GAP_STRING)
				var appendedLetter = false
				for letter in letters {
					// Seperate units
					let units = letter.components(separatedBy: UNIT_GAP_STRING)
					var appendedUnit = false
					for unit in units {
						if unit == UNIT_DIT_STRING  {
							res.append(res.last! + TimeInterval(DIT_LENGTH * scalar))
							res.append(res.last! + TimeInterval(UNIT_GAP_LENGTH * scalar))
							appendedUnit = true
						} else if unit == UNIT_DAH_STRING {
							res.append(res.last! + TimeInterval(DAH_LENGTH * scalar))
							res.append(res.last! + TimeInterval(UNIT_GAP_LENGTH * scalar))
							appendedUnit = true
						}
					}
					if appendedUnit {
						res.removeLast()
						res.append(res.last! + TimeInterval(LETTER_GAP_LENGTH * scalar))
						appendedLetter = true
					}
				}
				if appendedLetter {
					res.removeLast()
					res.append(res.last! + TimeInterval(WORD_GAP_LENGTH * scalar))
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

	fileprivate let _audioAnalysisQueue = DispatchQueue(label: "Audio Analysis Queue", attributes: [])
	fileprivate var _currentLetterMorse = ""
	fileprivate var _currentWordMorse = ""
	fileprivate var _inputWPM:Int {
		return appDelegate.userDefaults.integer(forKey: userDefaultsKeyInputWPM)
	}
	fileprivate var _sampleRate:Double = -1
	fileprivate let _spellChecker = UITextChecker()
	// This variable means how many callbacks should one unit be with the given WPM and the default sample rate (44100).
	fileprivate var _unitLength:Float {
		let unitsPerSecond = Double(self._inputWPM) * 50.0 / 60.0
		return Float(self._sampleRate/1000.0/unitsPerSecond)
	}

	fileprivate var _lengthRanges:(oneUnit:CountableClosedRange<Int>, threeUnit:CountableClosedRange<Int>, sevenUnit:CountableClosedRange<Int>) {
		if (14...18).contains(self._inputWPM) {
			return (2...5, 6...14, 15...999)
		} else if (19...23).contains(self._inputWPM) {
			return (2...4, 5...11, 12...999)
		} else if self._inputWPM == 24 {
			return (2...4, 5...7, 8...999)
		} else if self._inputWPM == 25 {
			return (2...3, 4...6, 7...999)
		}
		return (2...5, 7...14, 15...999)
	}

	fileprivate var _isDuringSignal = false
	fileprivate var _singalStarted = false
	fileprivate var _wordGapAppended = true
	fileprivate var _newLineAppended = true
	fileprivate var _counter = 1

	// The following variables are to help calculating input WPM
	fileprivate var _ditSignalLengthRecordRecent:[Int] = []
	fileprivate var _dahSignalLengthRecordRecent:[Int] = []
	fileprivate let _unitLengthRecordLength = 3

	// The following variables are to help calculating the threshold of signal rise/fall
	fileprivate var _maxLevelsHistoryRecent:[Float] = []
	fileprivate var _levelsHistoryRecent:[Float] = []

	fileprivate var _minLvl = Int.max

	// ******************************************************************************
	// WARNNING: MUST call this before using this tramsmitter to process input audio.
	// ******************************************************************************
	func resetForAudioInput() {
		self._morse = ""
		self._text = ""
		self._currentLetterMorse = ""
		self._sampleRate = -1
		self._counter = 1
		self._ditSignalLengthRecordRecent = []
		self._dahSignalLengthRecordRecent = []
		self._levelsHistoryRecent = []
		self._maxLevelsHistoryRecent = []
	}

	// ******************************************************************************
	// This method is called when an audio sample has been recieved in the microphone.
	// At sample rate 44.1k, this method is called about 44 times per second. Normally
	// it won't cause a performance issue, but for safety we dispatch it
	// ******************************************************************************

	func microphone(_ microphone: EZMicrophone!, maxFrequencyMagnitude: Float) {
		self._audioAnalysisQueue.async {
			// Setup sample rate
			if self._sampleRate < 0 {
				self._sampleRate = microphone.audioStreamBasicDescription().mSampleRate
				#if DEBUG
				print(self._unitLength)
				print(self._lengthRanges.oneUnit)
				print(self._lengthRanges.threeUnit)
				print(self._lengthRanges.sevenUnit)
				#endif
			}

			// TODO Auto WPM
			let level = pow(maxFrequencyMagnitude * 100, 1.5)

			// Calculate when should the isDuringSignal bar be set.
			self._levelsHistoryRecent.append(level)
			let recordLengthAll = (self._lengthRanges.oneUnit.lowerBound + self._lengthRanges.oneUnit.upperBound - 1)/2
			let recordLengthMax = recordLengthAll * 2
			while self._levelsHistoryRecent.count > recordLengthAll {
				self._levelsHistoryRecent.removeFirst()
			}
			while self._maxLevelsHistoryRecent.count > recordLengthMax {
				self._maxLevelsHistoryRecent.removeFirst()
			}
			var thresholdLvl:Float = 0
			if self._maxLevelsHistoryRecent.count >= recordLengthMax {
				thresholdLvl = ((self._maxLevelsHistoryRecent.reduce(0) { return $0 + $1 }) / Float(self._maxLevelsHistoryRecent.count))/5.0
			} else {
				thresholdLvl = ((self._levelsHistoryRecent.reduce(0) { return $0 + $1 }) / Float(self._levelsHistoryRecent.count))/5.0
			}
			self._isDuringSignal = level >= max(thresholdLvl, 1)
			if self._isDuringSignal {
				self._maxLevelsHistoryRecent.append(level)
			}
			#if DEBUG
				// If debugging, print the wave form in the console.
				if printAudiWaveFormWhenDebug {
					for _ in 0...Int(level) {
						print(self._isDuringSignal ? "*" : "=", separator: "", terminator: "")
					}
					print("\(Int(level))", separator: "", terminator: "")
					print(" \(Int(thresholdLvl))")
				}
			#endif

			if self._isDuringSignal {
				if self._singalStarted {
					// Signal already rose, during signal
					self._counter += 1
				} else {
					// Signal rises
					if !self._text!.isEmpty {
						if self._lengthRanges.threeUnit.contains(self._counter) {
							if !self._wordGapAppended && !self._newLineAppended {
								self.appendUnit(.LetterGap)
							}
						}
					}
					self._counter = 1
					self._singalStarted = true
				}
				self._wordGapAppended = false
			} else {
				if self._singalStarted {
					// Singal falls
					if self._lengthRanges.oneUnit.contains(self._counter) {
						self.appendUnit(.Dit)
						self._ditSignalLengthRecordRecent.append(self._counter)
					} else if self._lengthRanges.threeUnit.contains(self._counter) || self._lengthRanges.sevenUnit.contains(self._counter) {
						self.appendUnit(.Dah)
						self._dahSignalLengthRecordRecent.append(self._counter)
					}
					self._counter = 1
					self._singalStarted = false
					// Calculate input WPM
					if appDelegate.inputWPMAutomatic {
						while self._ditSignalLengthRecordRecent.count > self._unitLengthRecordLength {
							self._ditSignalLengthRecordRecent.removeFirst()
						}
						while self._dahSignalLengthRecordRecent.count > self._unitLengthRecordLength {
							self._dahSignalLengthRecordRecent.removeFirst()
						}
						// If we have enough history record for calculating input WPM, do it like a boss.
						if !self._ditSignalLengthRecordRecent.isEmpty || !self._dahSignalLengthRecordRecent.isEmpty {
							var ditLenAvg:Float = 0
							var dahLenAvg:Float = 0
							if self._ditSignalLengthRecordRecent.count > 0 {
								ditLenAvg = Float(self._ditSignalLengthRecordRecent.reduce(0) { $0 + $1 }) / Float(self._ditSignalLengthRecordRecent.count)
							}
							if self._dahSignalLengthRecordRecent.count > 0 {
								dahLenAvg = Float(self._dahSignalLengthRecordRecent.reduce(0) { $0 + $1 }) / Float(self._dahSignalLengthRecordRecent.count)
							}
							#if DEBUG
								print("DIT: \(ditLenAvg) DAH: \(dahLenAvg)")
							#endif
							var wpm = 20
							if (3...5).contains(ditLenAvg) && (10...13).contains(dahLenAvg) {
								wpm = 15
							} else if (2...4).contains(ditLenAvg) && (7...10).contains(dahLenAvg) {
								wpm = 20
							}
							appDelegate.inputWPM = wpm
						}
					}
				} else {
					// Singal already fell, not during signal
					self._counter += 1

					if self._lengthRanges.sevenUnit.contains(self._counter) {
						if !self._wordGapAppended && !self._newLineAppended {
							self.appendUnit(.WordGap)
						}
						self._wordGapAppended = true
					}
				}
			}
		}
	}

	// ********************************************************************************************************************
	// This method is called when a piece of audio is processed and a unit is sure will be appended to the Morse code.
	// Only 4 type of units can be appended: DIT, DAH, LETTERGAP, WORDGAP. UNITGAP will be appended automatically.
	// ********************************************************************************************************************
	fileprivate func appendUnit(_ unit:MorseUnit) { 
		self._newLineAppended = false
		if unit == .LetterGap || unit == .WordGap {
			// If we're appending a gap, reset currentLetterMorse
			self._currentLetterMorse = ""
			if unit == .LetterGap {
				self._morse?.append(unit.rawValue)
				if appDelegate.prosignTranslationType == .always {
					self._currentWordMorse.append(unit.rawValue)
				}
			}
			if unit == .WordGap {
				if appDelegate.prosignTranslationType == .always {
					// If we translate prosign, decode the whole sentence again.
					if let prosignText = MorseTransmitter.prosignMorseToTextStringDictionary[self._currentWordMorse] {
						if prosignText.characters.last! == "\n" { // Cannot use hasSuffix method, does not work on newline characters.
							self._newLineAppended = true
						}
						// Remove the wrong character appended last time.
						self._text?.remove(at: self._text!.characters.index(self._text!.endIndex, offsetBy: -1))
						// If a newline was appended, removed the redundant space appended to text last time.
						if self._newLineAppended {
							self._text?.remove(at: self._text!.characters.index(self._text!.endIndex, offsetBy: -1))
						}
						self._text?.append(prosignText)
					}
					self._currentWordMorse = ""
				}
				self._morse?.append(unit.rawValue)
				// Append a space on the text if there's a word gap, don't append if there is a newline before
				if !self._newLineAppended {
					self._text?.append(" ")
				}

				// If the user wants to auto correct mis-spelled words when using audio input to translate morse, this chunk of code does it.
				// This is only done after appending a white space
				var correctedText = self._text!
				if appDelegate.autoCorrectMissSpelledWordsForAudioInput {
					// Check if the current language code can be spell-checked and romanized, this language list is done manually.
					var checkedLanguage = appDelegate.currentLocaleLanguageCode
					var canBeChecked = false
					for lan in canBeSpellCheckedLanguageCodes {
						if checkedLanguage.hasPrefix(lan) || lan.hasPrefix(checkedLanguage) {
							canBeChecked = true
							break
						}
					}
					// If the language cannot be spell-checked, use English by default.
					if !canBeChecked {
						checkedLanguage = defaultSpellCheckLanguageCode
					}
					// Find the first mis-spelled range.
					var misSpelledRange = self._spellChecker.rangeOfMisspelledWord(in: correctedText, range: NSMakeRange(0, correctedText.lengthOfBytes(using: String.Encoding.ascii)), startingAt: 0, wrap: false, language: checkedLanguage)
					var misSpelledWord = ""
					// Keep fixing mis-spelled words while there is one.
					while misSpelledRange.location != NSNotFound {
						let misSpelledIndexRange = correctedText.characters.index(correctedText.startIndex, offsetBy: misSpelledRange.location)..<correctedText.characters.index(correctedText.startIndex, offsetBy: misSpelledRange.location + misSpelledRange.length)
						misSpelledWord = correctedText.substring(with: misSpelledIndexRange)
						// See if there is any guess for the word.
						if let guessedWords = self._spellChecker.guesses(forWordRange: misSpelledRange, in: correctedText, language: checkedLanguage) as? [String] {
							if !guessedWords.isEmpty {
								// Convert the word to upper case to avoid case sensitivity
								let guessedWordsUpperCase = guessedWords.map { $0.uppercased() }
								// Check if guessed words already contains the mis-spelled word without case sensitive, sometime spell checker is case sensitive.
								if !guessedWordsUpperCase.contains(misSpelledWord.uppercased()) {
									// If there is at least one guessed word, replace the mis-spelled word with the first guessed word.
									let firstGuessedWord = guessedWords[0]
									correctedText.replaceSubrange(misSpelledIndexRange, with: firstGuessedWord)
								}
							} else if guessedWords.isEmpty {
								self._spellChecker.ignoreWord(misSpelledWord)
							}
							#if DEBUG
								print("Mis-spelled Word: \(misSpelledWord) | Guessed Words: \(guessedWords)")
							#endif
						} else {
							self._spellChecker.ignoreWord(misSpelledWord)
							#if DEBUG
								print("Mis-spelled Word: \(misSpelledWord) | Guessed Words: NONE")
							#endif
						}
						// Keep looking for mis-spelled words
						misSpelledRange = self._spellChecker.rangeOfMisspelledWord(in: correctedText, range: NSMakeRange(0, correctedText.lengthOfBytes(using: String.Encoding.ascii)), startingAt: misSpelledRange.location + misSpelledRange.length - 1, wrap: false, language: checkedLanguage)
					}
					self._text = correctedText
				}
			}
		} else {
			let startOfALetter = self._currentLetterMorse.isEmpty
			// We're sure unit is either DIT or DAH at this point
			// If morse for current character is not empty (means there is a DIT or DAH at the end), append a one unit gap for morse.
			if !self._currentLetterMorse.isEmpty && !self._currentLetterMorse.hasPrefix(" ") {
				self._currentLetterMorse.append(" ")
				self._morse?.append(" ")
				if appDelegate.prosignTranslationType == .always {
					self._currentWordMorse.append(" ")
				}
			}
			// Append this new unit (DIT or DAH) to morse for current character
			self._currentLetterMorse.append(unit.rawValue)
			self._morse?.append(unit.rawValue)
			if appDelegate.prosignTranslationType == .always {
				self._currentWordMorse.append(unit.rawValue)
			}

			// After appending this new unit, change the text.
			var letter = MorseTransmitter.decodeMorseStringToTextDictionary[self._currentLetterMorse]
			// If this Morse code cannot be found in the dictionary, change letter to the error character.
			if letter == nil {
				letter = notRecognizedLetterStr
			}
			// If in the middle of decoding a letter, remove the last appended letter and append the new one.
			if !startOfALetter {
				self._text?.remove(at: self._text!.characters.index(self._text!.endIndex, offsetBy: -1))
			}
			// If not in the middle of decoding a letter, simply append the new letter.
			self._text?.append(letter!)
		}

		// Call the delegate method notifying at least one of text and Morse content is changed.
		self.delegate?.transmitterContentDidChange?(self._text!, morse: self._morse!)
	}

	// *****************************
	// MARK: Private Helper Methods
	// *****************************

	// Ignores invalid character
	fileprivate func encodeTextToMorse(_ text:String!) -> String? {
		// If there's no text, return nil.
		if text == nil || text.isEmpty { return nil }

		// Create an empty string as result to append content later.
		var res = ""
		// Encode on another queue.
		_encodeQueue.sync {
			// Decide if we need to keep portaintial prosign characters.
			var seperatorCharacters = " \t"
			if appDelegate.prosignTranslationType != .always {
				seperatorCharacters += "\n\r"
			}
			// Seperate the text into words.
			// WARNING: If translating prosign, this word may contain newline character if translating prosign
			var words = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercased().components(separatedBy: CharacterSet(charactersIn: seperatorCharacters))
			// Do some additional processing if translating prosign
			if appDelegate.prosignTranslationType == .always {
				for var i in 0..<words.count {
					if i + 1 < words.count {
						// Find adjacent words can connect with newline characters, combine them into one word.
						if (words[i].hasSuffix("\n") || words[i].hasSuffix("\r")) &&
							(words[i + 1].hasPrefix("\n") || words[i + 1].hasPrefix("\r")) {
							words[i] += words[i + 1]
							words.remove(at: i + 1)
							i -= 1
						}
					}
				}
			}
			for wordInd in 0..<words.count {
				let word = words[wordInd]
				// Get all the characters in the word.
				let chArr = word.characters.map { String($0) }
				// Create an empty string to append content later.
				var wordStr:String = ""
				var newLineChCounter = 0
				// Get all the characters in this word.
				for chInd in 0..<chArr.count {
					let ch = chArr[chInd]
					// If this charater is found in the dictionary, append it with a letter gap.
					if let chMorseString = MorseTransmitter.encodeTextToMorseStringDictionary[ch] {
						var prefixSpaceForLetter = MorseUnit.LetterGap.rawValue
						// If there was a series of newline characters
						if appDelegate.prosignTranslationType == .always && newLineChCounter > 0 {
							// Decide the prefix-space based on the position of this newline character
							// NOTE: this part only considers two situations: the beginning and the middle of word. The third situation (the end of the word) is handdled later.
							var prefixSpace = MorseUnit.WordGap.rawValue
							if chInd - 1 == 0 {
								// At the beginning of the word
								prefixSpace = ""
							}
							// Count number of newline characters to determin which prosign to append.
							if newLineChCounter == 1 {
								wordStr += prefixSpace + "• — • —" // New line prosign
							} else if newLineChCounter == 2 {
								wordStr += prefixSpace + "— • • • —" // New paragraph prosign
							} else {
								wordStr += prefixSpace + "• — • — •" // New page prosign
							}
							wordStr += MorseUnit.WordGap.rawValue
							prefixSpaceForLetter = ""
							newLineChCounter = 0
						}
						// After appending portaintial prosign for newline characers, append the current word.
						if chInd != 0 {
							wordStr += prefixSpaceForLetter
						}
						wordStr += chMorseString
					} else { // If the character cannot be found, it's possible it a new line character
						// If this character is a newline character, do something
						if appDelegate.prosignTranslationType == .always {
							if ch == "\n" || ch == "\r" {
								newLineChCounter += 1
							}
							// If this is the end of word and there are still pending newline characters, deal with them.
							if newLineChCounter > 0 && chInd == chArr.count - 1 {
								wordStr += MorseUnit.WordGap.rawValue
								if newLineChCounter == 1 {
									wordStr += "• — • —" // New line prosign
								} else if newLineChCounter == 2 {
									wordStr += "— • • • —" // New paragraph prosign
								} else {
									wordStr += "• — • — •" // New page prosign
								}
							}
						}
					}
				}

				// If this word can be translated, append a word gap and the word.
				if !wordStr.isEmpty {
					// If this is not the first word in the text, append a wordGap
					if wordInd > 0 {
						res += MorseUnit.WordGap.rawValue
					}
					// Append the new word
					res += wordStr
				}
			}
		}
		return res.isEmpty ? nil : res
	}

	// Assume morse is valid
	fileprivate func decodeMorseToText(_ morse:String!) -> String? {
		// If the morse code is nil or empty, return nil
		if morse == nil || morse.isEmpty { return nil }
		// If the morse code only contains code prosign, translate it to prosign and done.
		if appDelegate.prosignTranslationType == .onlyWhenSingulated {
			// If there exists a prosign for it, return it.
			if let translatedProsign = MorseTransmitter.prosignMorseToTextStringDictionary[morse!.trimmingCharacters(in: CharacterSet.whitespaces)] {
				return translatedProsign
			}
		}

		// Create an empty string as result to append content later.
		var res = ""
		// Decode on another queue.
		_decodeQueue.sync {
			// Seperate Morse code into words.
			let words = morse.components(separatedBy: WORD_GAP_STRING)
			for word in words {
				// Get an array of characters in this word.
				let chArr = word.components(separatedBy: LETTER_GAP_STRING)
				// Initliaze an empty string for later word construction.
				var wordStr:String = ""
				// Seperate this word into characters
				for ch in chArr {
					if !ch.isEmpty { // This line is here to fix a bug where in some cases empty string will be found in chArr
						// If the user always want to translate prosign and this maybe one prosign (only one character in this word), do it.
						if appDelegate.prosignTranslationType == .always && chArr.count == 1 {
							// Check if this is a prosign
							if let prosignText = MorseTransmitter.prosignMorseToTextStringDictionary[String(ch)] {
								wordStr = prosignText
								// Break out of the loop so if the letter is "&" or "k" which overlaps with prosign, it does not keep decoding this message.
								continue
							}
						}
						// If this is not a prosign, use normal dictionary to translate it.
						if let chText = MorseTransmitter.decodeMorseStringToTextDictionary[String(ch)] {
							wordStr += chText
						} else {
							// If the dictionary does not recognize this letter, append the error character.
							wordStr += notRecognizedLetterStr
						}
					}
				}

				// If a word is found, append it to the final result.
				if !wordStr.isEmpty {
					res += wordStr
					if !wordStr.hasSuffix("\n") && !wordStr.hasSuffix("\r") {
						res += " "
					}
				}
			}

			// Remove the trailing white space.
			if !res.isEmpty {
				res.remove(at: res.characters.index(res.endIndex, offsetBy: -1))
			}
		}
		return res.isEmpty ? nil : res
	}

	//----------------------- Future Design for Concurrency -----------------------

	/** Get the text from transmitter. Instead of returning the value on the calling thread,
		this function tranlsates text on another thread, and execute the completion block
		when it's done.
		- parameters:
			- concurrent: Whether the code of getting this text should be ran concurrently or serially. False by default.
			- completionDispatchQueue: The queue to execute completion block. By default this is set to main queue.
			- completion: The completion block to run after text is translated. */
	func getFutureText(_ concurrent:Bool = false,
	                   completionDispatchQueue:DispatchQueue? = nil,
	                   completion:((_ futureText:String?)->Void)) {
		// Call helper method:
		_getFuture(.text,
		           completionDispatchQueue: completionDispatchQueue,
		           concurrent: concurrent,
		           completion: completion)
	}

	/** Get the Morse code from transmitter. Instead of returning the value on the calling
		thread, this function tranlsates Morse code on another thread, and execute the completion
		block when it's done.
		- parameters:
			- concurrent: Whether the code of getting Morse code should be ran concurrently or serially. False by default.
			- completionDispatchQueue: The queue to execute completion block. By default this is set to main queue.
			- completion: The completion block to run after Morse code is translated. */
	func getFutureMorse(_ concurrent:Bool = false,
	                    completionDispatchQueue:DispatchQueue? = nil,
	                    completion:@escaping ((_ futureText:String?)->Void)) {
		// Call helper method:
		_getFuture(.morse,
		           concurrent: concurrent,
		           completionDispatchQueue: completionDispatchQueue,
		           completion: completion)
	}

	// A helper method for the 'Future' design of text and Morse code translation.
	fileprivate func _getFuture(_ type:FutureObjectType,
	                        concurrent:Bool = false,
	                        completionDispatchQueue:DispatchQueue? = nil,
	                        completion:@escaping ((_ futureText:String?)->Void)) {
		// Create a completion queue for the completion block to run on. Use main queue if not specified.
		let completionQueue = (completionDispatchQueue == nil ? DispatchQueue.main:completionDispatchQueue)
		// Create a queue and group to translate text/Morse code.
		let group = DispatchGroup()
		let getTextQueue = concurrent ? _globalQueueDefault:_futureQueue
		// Get the future place holder.
		var future:String? = nil
		getTextQueue.async(group: group) {
			switch type {
			case .text: future = self.text
			case .morse: future = self.morse
			}
		}
		// When the process is done, call the completion block with 'future', which has the result now.
		group.notify(queue: completionQueue!) {
			completion(future)
		}
	}

	// Type of content user wants to get out of 'Future' functions.
	fileprivate enum FutureObjectType {
		case text, morse
	}
}

