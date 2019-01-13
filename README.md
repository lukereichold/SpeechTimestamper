# Speech Timestamper

**Demo iOS application to generate an accurately timestamped transcript given an audio file and its pre-supplied text.**

It leverages Google Cloud Platform's Speech-to-Text API for its _[time offsets](https://cloud.google.com/speech-to-text/docs/async-time-offsets)_ feature (that is, returning the absolute timestamp of each word relative to the beginning of the audio). Any mistranscriptions from the service can then be corrected using the pre-supplied text and a sequence alignment algorithm.

_Why is this useful?_

In cases where the raw text transcription of a piece of audio is known upfront, we can use this to obtain the correct word-level timestamps. This resulting information is useful for contexts relating to interactive language education and music lyrics.

## Big idea

1. Record some speech
1. Provide manual transcript of what was said (a `String`)
1. Generate timestamped transcription of audio from [GCP's Speech-to-Text API](https://cloud.google.com/speech-to-text/)
1. Square up the provided transcription and the API's transcript using a sequence alignment algorithm, keeping the underlying actual word-timestamp pairs.
1. Voilà!

## Getting Started

- Rename `Secrets.template.plist` to `Secrets.plist` and provide your Google Cloud Platform API key for the field `GOOGLE_API_KEY`.
- Build and run the `SpeechTimestamper` target in Xcode.

## gRPC

This project uses gRPC instead of REST to communicate with GCP services. While there is not yet [an official Google Cloud Client Library](https://cloud.google.com/apis/docs/cloud-client-libraries) for Swift), this project can be used as an example of how to interact with Google Cloud services (polling long-running operations, etc) using Swift with gRPC. For basic functionality of the gRPC API for Swift, see [the Swift gRPC Overview](https://github.com/grpc/grpc-swift/blob/master/OVERVIEW.md). 

If you'd like to generate the most up-to-date protobuf definitions, you'll need [protobuf](https://github.com/apple/swift-protobuf) installed and then run a fresh `pod update`.
