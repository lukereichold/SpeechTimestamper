# Speech Timestamper

Generate an accurate, timestamped transcript given an audio file and its text.

Demo iOS application leveraging Google Cloud Speech-to-Text via streaming gRPC. This project can also be used as a general template for iOS applications to communicate with GCP services via gRPC.

## Big idea
1. Record some speech
1. Provide manual transcript of what was said
1. Generate timestamped transcription of audio from [GCP's Speech-to-Text API](https://cloud.google.com/speech-to-text/)
1. Square up the provided transcription and the API's transcript using a sequence alignment algorithm, keeping the underlying actual word-timestamp pairs.
1. Voilà!

## Requirements
- Provide your Google Cloud Platform API key `GOOGLE_API_KEY` in `AppDelegate.swift`
- If you'd like to run a fresh `pod update` to generate the most up-to-date protobuf definitions, you'll need [protobuf](https://github.com/apple/swift-protobuf) installed.
