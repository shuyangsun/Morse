var frequency = 800.0;
var volume = 0.1;
var stopped = false;
var audioCtx = new (window.AudioContext || window.webkitAudioContext)();
var gainNode = audioCtx.createGain();

frequency = (frequency - 0.3756)/1.0594; // Doing this because of a bug.
var currentOscillator;

function startSignalFor(seconds, delay) {
	if (!stopped) {

		// create Oscillator node
		var oscillator = audioCtx.createOscillator();
		currentOscillator = oscillator;

		// connect oscillator to gain node to speakers

		oscillator.connect(gainNode);
		gainNode.connect(audioCtx.destination);

		oscillator.type = 'square';
		oscillator.frequency.value = frequency; // value in hertz
		oscillator.detune.value = 100;

		gainNode.gain.value = volume;
		oscillator.start(delay);
		oscillator.stop(delay + seconds);
	}
}

function start() {
	stopped = false;
}

function stop() {
	stopped = true;
	currentOscillator.stop();
}

function myFunc() {
	//	startSignalFor(1, 0);
	startSignalFor(0.18, 0.5);
	startSignalFor(0.06, 1.1);
	startSignalFor(0.18, 1.22);
	startSignalFor(0.18, 1.46);
}