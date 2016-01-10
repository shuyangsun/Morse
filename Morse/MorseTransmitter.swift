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
	case Always = 0
	case OnlyWhenSingulated = 1
	case None = 2
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
private let encodeQueue = dispatch_queue_create("Encode Queue", nil)
private let decodeQueue = dispatch_queue_create("Decode Queue", nil)

private let numberOfNewLineForNewPageProsign = 5
private var newPageProsignText:String {
	return String(count: numberOfNewLineForNewPageProsign, repeatedValue: Character("\n"))
}

class MorseTransmitter {
	var prosignTranslationType = ProsignTranslationType(rawValue: appDelegate.prosignTranslationTypeRaw)!
	private var _text:String?
	private var _morse:String?

	static let standardWordLength:Int = 50

	private let _getTimeStampQueue = dispatch_queue_create("Get Time Stamp Queue", nil)

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
			return res?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		}
	}

	var morse:String? {
		set {
			self._morse = newValue
			self._text = nil
		}
		get {
			let res = self._morse == nil ? self.encodeTextToMorse(self._text) : self._morse
			return res?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		}
	}

	init(prosignTranslationType:ProsignTranslationType = ProsignTranslationType(rawValue: appDelegate.prosignTranslationTypeRaw)!) {
		self.prosignTranslationType = prosignTranslationType
	}

	// TODO: Not used, because it doesn't work
	func morseRangeFromTextRange(range:NSRange) -> NSRange {
		if self.text != nil && self.morse != nil &&
			range.location > 0 && range.location + range.length <= self.text!.lengthOfBytesUsingEncoding(NSISOLatin1StringEncoding) {
			let textStr = self.text!
			let preText = textStr.substringWithRange(textStr.startIndex..<textStr.startIndex.advancedBy(range.location)) // ******TextSelected****** // This is the first "******" part.
			let postText = textStr.substringWithRange(textStr.startIndex..<textStr.startIndex.advancedBy(range.location + range.length)) // ******TextSelected****** // This is the "******TextSelected" part.
			let preMorse = self.encodeTextToMorse(preText)
			let endMorse = self.encodeTextToMorse(postText)
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
	private var _currentWordMorse = ""
	private var _inputWPM:Int {
		return appDelegate.userDefaults.integerForKey(userDefaultsKeyInputWPM)
	}
	private var _sampleRate:Double = -1
	private let _spellChecker = UITextChecker()
	// This variable means how many callbacks should one unit be with the given WPM and the default sample rate (44100).
	private var _unitLength:Float {
		let unitsPerSecond = Double(self._inputWPM) * 50.0 / 60.0
		return Float(self._sampleRate/1000.0/unitsPerSecond)
	}

	private var _lengthRanges:(oneUnit:Range<Int>, threeUnit:Range<Int>, sevenUnit:Range<Int>) {
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

	private var _isDuringSignal = false
	private var _singalStarted = false
	private var _wordGapAppended = true
	private var _newLineAppended = true
	private var _counter = 1

	// The following variables are to help calculating input WPM
	private var _ditSignalLengthRecordRecent:[Int] = []
	private var _dahSignalLengthRecordRecent:[Int] = []
	private let _unitLengthRecordLength = 3

	// The following variables are to help calculating the threshold of signal rise/fall
	private var _maxLevelsHistoryRecent:[Float] = []
	private var _levelsHistoryRecent:[Float] = []

	private var _minLvl = Int.max

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

	// This method is called when an audio sample has been recieved in the microphone.
	func microphone(microphone: EZMicrophone!, maxFrequencyMagnitude: Float) {
		dispatch_sync(self._audioAnalysisQueue) {
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
			let recordLengthAll = (self._lengthRanges.oneUnit.startIndex + self._lengthRanges.oneUnit.endIndex - 1)/2
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
					self._counter++
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
						appDelegate.userDefaults.setInteger(wpm, forKey: userDefaultsKeyInputWPM)
						appDelegate.userDefaults.synchronize()
						NSNotificationCenter.defaultCenter().postNotificationName(inputWPMDidChangeNotificationName, object: nil)
					}
				} else {
					// Singal already fell, not during signal
					self._counter++

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
	private func appendUnit(unit:MorseUnit) {
		self._newLineAppended = false
		if unit == .LetterGap || unit == .WordGap {
			// If we're appending a gap, reset currentLetterMorse
			self._currentLetterMorse = ""
			if unit == .LetterGap {
				self._morse?.appendContentsOf(unit.rawValue)
				if self.prosignTranslationType == .Always {
					self._currentWordMorse.appendContentsOf(unit.rawValue)
				}
			}
			if unit == .WordGap {
				if self.prosignTranslationType == .Always {
					// If we translate prosign, decode the whole sentence again.
					if let prosignText = MorseTransmitter.prosignMorseToTextStringDictionary[self._currentWordMorse] {
						if prosignText.characters.last! == "\n" { // Cannot use hasSuffix method, does not work on newline characters.
							self._newLineAppended = true
						}
						// Remove the wrong character appended last time.
						self._text?.removeAtIndex(self._text!.endIndex.advancedBy(-1))
						// If a newline was appended, removed the redundant space appended to text last time.
						if self._newLineAppended {
							self._text?.removeAtIndex(self._text!.endIndex.advancedBy(-1))
						}
						self._text?.appendContentsOf(prosignText)
					}
					self._currentWordMorse = ""
				}
				self._morse?.appendContentsOf(unit.rawValue)
				// Append a space on the text if there's a word gap, don't append if there is a newline before
				if !self._newLineAppended {
					self._text?.appendContentsOf(" ")
				}

				// If the user wants to auto correct mis-spelled words when using audio input to translate morse, this chunk of code does it.
				// This is only done after appending a white space
				var correctedText = self._text!
				if appDelegate.autoCorrectMissSpelledWordsForAudioInput {
					// Check if the current language code can be spell-checked and romanized, this language list is done manually.
					var checkedLanguage = appDelegate.currentLocaleLanguageCode
					var canBeChecked = false
					for lan in canBeSpellCheckedLanguageCodes {
						if checkedLanguage.hasPrefix(lan) {
							canBeChecked = true
							break
						}
					}
					// If the language cannot be spell-checked, use English by default.
					if !canBeChecked {
						checkedLanguage = defaultSpellCheckLanguageCode
					}
					// Find the first mis-spelled range.
					var misSpelledRange = self._spellChecker.rangeOfMisspelledWordInString(correctedText, range: NSMakeRange(0, correctedText.lengthOfBytesUsingEncoding(NSASCIIStringEncoding)), startingAt: 0, wrap: false, language: checkedLanguage)
					var misSpelledWord = ""
					// Keep fixing mis-spelled words while there is one.
					while misSpelledRange.location != NSNotFound {
						let misSpelledIndexRange = correctedText.startIndex.advancedBy(misSpelledRange.location)..<correctedText.startIndex.advancedBy(misSpelledRange.location + misSpelledRange.length)
						misSpelledWord = correctedText.substringWithRange(misSpelledIndexRange)
						// See if there is any guess for the word.
						if let guessedWords = self._spellChecker.guessesForWordRange(misSpelledRange, inString: correctedText, language: checkedLanguage) as? [String] {
							if !guessedWords.isEmpty {
								// Convert the word to upper case to avoid case sensitivity
								let guessedWordsUpperCase = guessedWords.map { $0.uppercaseString }
								// Check if guessed words already contains the mis-spelled word without case sensitive, sometime spell checker is case sensitive.
								if !guessedWordsUpperCase.contains(misSpelledWord.uppercaseString) {
									// If there is at least one guessed word, replace the mis-spelled word with the first guessed word.
									let firstGuessedWord = guessedWords[0]
									correctedText.replaceRange(misSpelledIndexRange, with: firstGuessedWord)
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
						misSpelledRange = self._spellChecker.rangeOfMisspelledWordInString(correctedText, range: NSMakeRange(0, correctedText.lengthOfBytesUsingEncoding(NSASCIIStringEncoding)), startingAt: misSpelledRange.location + misSpelledRange.length - 1, wrap: false, language: checkedLanguage)
					}
					self._text = correctedText
				}
			}
		} else {
			let startOfALetter = self._currentLetterMorse.isEmpty
			// We're sure unit is either DIT or DAH at this point
			// If morse for current character is not empty (means there is a DIT or DAH at the end), append a one unit gap for morse.
			if !self._currentLetterMorse.isEmpty && !self._currentLetterMorse.hasPrefix(" ") {
				self._currentLetterMorse.appendContentsOf(" ")
				self._morse?.appendContentsOf(" ")
				if self.prosignTranslationType == .Always {
					self._currentWordMorse.appendContentsOf(" ")
				}
			}
			// Append this new unit (DIT or DAH) to morse for current character
			self._currentLetterMorse.appendContentsOf(unit.rawValue)
			self._morse?.appendContentsOf(unit.rawValue)
			if self.prosignTranslationType == .Always {
				self._currentWordMorse.appendContentsOf(unit.rawValue)
			}

			// After appending this new unit, change the text.
			var letter = MorseTransmitter.decodeMorseStringToTextDictionary[self._currentLetterMorse]
			// If this Morse code cannot be found in the dictionary, change letter to the error character.
			if letter == nil {
				letter = notRecognizedLetterStr
			}
			// If in the middle of decoding a letter, remove the last appended letter and append the new one.
			if !startOfALetter {
				self._text?.removeAtIndex(self._text!.endIndex.advancedBy(-1))
			}
			// If not in the middle of decoding a letter, simply append the new letter.
			self._text?.appendContentsOf(letter!)
		}

		// Call the delegate method notifying at least one of text and Morse content is changed.
		self.delegate?.transmitterContentDidChange?(self._text!, morse: self._morse!)
	}

	// *****************************
	// MARK: Private Helper Methods
	// *****************************

	// Ignores invalid character
	private func encodeTextToMorse(text:String!) -> String? {
		// If there's no text, return nil.
		if text == nil || text.isEmpty { return nil }

		// Create an empty string as result to append content later.
		var res = ""
		// Encode on another queue.
		dispatch_sync(encodeQueue) {
			// Decide if we need to keep portaintial prosign characters.
			var seperatorCharacters = " \t"
			if self.prosignTranslationType != .Always {
				seperatorCharacters += "\n\r"
			}
			// Seperate the text into words.
			// WARNING: If translating prosign, this word may contain newline character if translating prosign
			var words = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: seperatorCharacters))
			// Do some additional processing if translating prosign
			if self.prosignTranslationType == .Always {
				for var i in 0..<words.count {
					if i + 1 < words.count {
						// Find adjacent words can connect with newline characters, combine them into one word.
						if (words[i].hasSuffix("\n") || words[i].hasSuffix("\r")) &&
							(words[i + 1].hasPrefix("\n") || words[i + 1].hasPrefix("\r")) {
							words[i] += words[i + 1]
							words.removeAtIndex(i + 1)
							i--
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
						if self.prosignTranslationType == .Always && newLineChCounter > 0 {
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
						if self.prosignTranslationType == .Always {
							if ch == "\n" || ch == "\r" {
								newLineChCounter++
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
	private func decodeMorseToText(morse:String!) -> String? {
		// If the morse code is nil or empty, return nil
		if morse == nil || morse.isEmpty { return nil }
		// If the morse code only contains code prosign, translate it to prosign and done.
		if self.prosignTranslationType == .OnlyWhenSingulated {
			// If there exists a prosign for it, return it.
			if let translatedProsign = MorseTransmitter.prosignMorseToTextStringDictionary[morse!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())] {
				return translatedProsign
			}
		}

		// Create an empty string as result to append content later.
		var res = ""
		// Decode on another queue.
		dispatch_sync(decodeQueue) {
			// Seperate Morse code into words.
			let words = morse.componentsSeparatedByString(WORD_GAP_STRING)
			for word in words {
				// Get an array of characters in this word.
				let chArr = word.componentsSeparatedByString(LETTER_GAP_STRING)
				// Initliaze an empty string for later word construction.
				var wordStr:String = ""
				// Seperate this word into characters
				for ch in chArr {
					// If the user always want to translate prosign and this maybe one prosign (only one character in this word), do it.
					if self.prosignTranslationType == .Always && chArr.count == 1 {
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
				res.removeAtIndex(res.endIndex.advancedBy(-1))
			}
		}
		return res.isEmpty ? nil : res
	}
}

