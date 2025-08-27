//Audify audio : https://almoghamdani.github.io/audify/index.html
const WebSocket = require('ws')

// Get audio port from environment variable or use default
const audioPort = process.env.AUDIO_PORT || 50160;

var wss = new WebSocket.Server({
    port: audioPort
});

console.log('Server ready...')
wss.on('connection', function connection(ws) {
    console.log('Socket connected. sending data...')
})

const {
    RtAudio,
    RtAudioFormat,
} = require("audify")

// Init RtAudio instance using default sound API
const rtAudio = new RtAudio()
rtAudio.outputVolume = 0

// Open the input/output stream
rtAudio.openStream({
        deviceId: rtAudio.getDefaultOutputDevice(), // Output device id (Get all devices using `getDevices`)
        nChannels: 2, // Number of channels
        firstChannel: 0 // First channel index on device (default = 0).
    }, {
        deviceId: rtAudio.getDefaultInputDevice(), // Input device id (Get all devices using `getDevices`)
        nChannels: 2, // Number of channels
        firstChannel: 0 // First channel index on device (default = 0).
    },
    RtAudioFormat.RTAUDIO_SINT16, // PCM Format - Signed 16-bit integer
    48000, // Sampling rate is 44.1kHz
    480, // Frame size is 1920 (40ms)
    "MyStream", // The name of the stream (used for JACK Api)
    pcm => {
        wss.clients.forEach(function each(client) {
            if (client.readyState === WebSocket.OPEN) {
                client.send(pcm)
            }
        })
        rtAudio.write(pcm)
    } // Input callback function, write every input pcm data to the output buffer
)

// Start the stream
rtAudio.start()
