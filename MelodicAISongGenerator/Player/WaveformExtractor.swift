//
//  WaveformExtractor.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 15.08.2026.
//


import Foundation
import AVFoundation

enum WaveformExtractor {
    static func amplitudes(for url: URL, sampleCount: Int) async -> [Float] {
        await Task.detached(priority: .userInitiated) {
            extractAmplitudes(url: url, sampleCount: sampleCount)
        }.value
    }

    private static func extractAmplitudes(url: URL, sampleCount: Int) -> [Float] {
        let fallback = [Float](repeating: 0.16, count: sampleCount)

        guard let file = try? AVAudioFile(forReading: url) else { return fallback }

        let frameCount = AVAudioFrameCount(file.length)
        guard frameCount > 0 else { return fallback }

        guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: frameCount) else {
            return fallback
        }

        do {
            try file.read(into: buffer)
        } catch {
            return fallback
        }

        guard let channelData = buffer.floatChannelData else { return fallback }

        let totalSamples = Int(buffer.frameLength)
        let channelCount = Int(buffer.format.channelCount)
        guard totalSamples > 0, channelCount > 0 else { return fallback }

        let samplesPerBucket = max(1, totalSamples / sampleCount)
        var result: [Float] = []
        result.reserveCapacity(sampleCount)

        for bucket in 0..<sampleCount {
            let start = bucket * samplesPerBucket
            let end = min(start + samplesPerBucket, totalSamples)
            guard start < end else {
                result.append(0)
                continue
            }

            var sumOfSquares: Float = 0
            for channel in 0..<channelCount {
                let data = channelData[channel]
                var index = start
                while index < end {
                    let sample = data[index]
                    sumOfSquares += sample * sample
                    index += 1
                }
            }

            let sampleTotal = Float((end - start) * channelCount)
            let rms = sampleTotal > 0 ? sqrt(sumOfSquares / sampleTotal) : 0
            result.append(rms)
        }


        let peak = result.max() ?? 1
        guard peak > 0 else { return fallback }

        return result.map { min(1, max(0.08, $0 / peak)) }
    }
}
