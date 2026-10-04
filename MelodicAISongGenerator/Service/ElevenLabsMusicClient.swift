

import Foundation


public struct ElevenLabsConfiguration: Sendable {
    public let apiKey: String
    public let baseURL: URL
    public let session: URLSession
    
    public init(
        apiKey: String,
        baseURL: URL = URL(string: "https://api.elevenlabs.io")!,
        session: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.session = session
    }
}


public enum ElevenLabsMusicError: LocalizedError, Sendable {
    case invalidURL
    case invalidRequest(String)
    case encodingFailed(String)
    case network(String)
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case decodingFailed(String)
    case emptyAudioData
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Не вдалося сформувати URL запиту."
        case .invalidRequest(let reason):
            return "Некоректний запит: \(reason)"
        case .encodingFailed(let reason):
            return "Не вдалося закодувати тіло запиту: \(reason)"
        case .network(let reason):
            return "Мережева помилка: \(reason)"
        case .invalidResponse:
            return "Сервер повернув відповідь у неочікуваному форматі."
        case .apiError(let statusCode, let message):
            return "ElevenLabs API повернув помилку (\(statusCode)): \(message)"
        case .decodingFailed(let reason):
            return "Не вдалося розпарсити відповідь сервера: \(reason)"
        case .emptyAudioData:
            return "Сервер не повернув аудіодані."
        }
    }
}

private struct ElevenLabsAPIErrorEnvelope: Decodable {
    struct Detail: Decodable {
        let status: String?
        let message: String?
    }
    let detail: Detail?
}


public enum ElevenLabsMusicModel: String, Codable, Sendable {
    case v1 = "music_v1"
    case v2 = "music_v2"
}


public enum MusicOutputFormat {
    public static let auto = "auto"
    public static let mp3_44100_128 = "mp3_44100_128"
    public static let mp3_44100_192 = "mp3_44100_192"
    public static let mp3_48000_192 = "mp3_48000_192"
    public static let pcm_44100 = "pcm_44100"
}


public struct CompositionSection: Codable, Sendable, Equatable {
    public var sectionName: String
    public var positiveLocalStyles: [String]
    public var negativeLocalStyles: [String]
    public var durationMs: Int
    public var lines: [String]
    
    enum CodingKeys: String, CodingKey {
        case sectionName = "section_name"
        case positiveLocalStyles = "positive_local_styles"
        case negativeLocalStyles = "negative_local_styles"
        case durationMs = "duration_ms"
        case lines
    }
    
    public init(
        sectionName: String,
        positiveLocalStyles: [String] = [],
        negativeLocalStyles: [String] = [],
        durationMs: Int,
        lines: [String] = []
    ) {
        self.sectionName = sectionName
        self.positiveLocalStyles = positiveLocalStyles
        self.negativeLocalStyles = negativeLocalStyles
        self.durationMs = durationMs
        self.lines = lines
    }
}

public struct CompositionPlan: Codable, Sendable, Equatable {
    public var positiveGlobalStyles: [String]
    public var negativeGlobalStyles: [String]
    public var sections: [CompositionSection]
    
    enum CodingKeys: String, CodingKey {
        case positiveGlobalStyles = "positive_global_styles"
        case negativeGlobalStyles = "negative_global_styles"
        case sections
    }
    
    public init(
        positiveGlobalStyles: [String] = [],
        negativeGlobalStyles: [String] = [],
        sections: [CompositionSection] = []
    ) {
        self.positiveGlobalStyles = positiveGlobalStyles
        self.negativeGlobalStyles = negativeGlobalStyles
        self.sections = sections
    }
}

public struct SongMetadata: Decodable, Sendable, Equatable {
    public var title: String?
    public let description: String?
    public let genres: [String]?
    public let languages: [String]?
    public let isExplicit: Bool?
    
    enum CodingKeys: String, CodingKey {
        case title, description, genres, languages
        case isExplicit = "is_explicit"
    }
}


public struct MusicComposeRequest: Sendable {
    public var prompt: String?
    public var compositionPlan: CompositionPlan?
    public var musicLengthMs: Int?
    public var model: ElevenLabsMusicModel
    public var seed: Int?
    public var forceInstrumental: Bool
    public var respectSectionsDurations: Bool
    public var storeForInpainting: Bool
    public var signWithC2PA: Bool
    public var withTimestamps: Bool
    public var outputFormat: String?
    
    
    public init(
        prompt: String,
        musicLengthMs: Int? = nil,
        model: ElevenLabsMusicModel = .v2,
        seed: Int? = nil,
        forceInstrumental: Bool = false,
        outputFormat: String? = nil
    ) {
        self.prompt = prompt
        self.compositionPlan = nil
        self.musicLengthMs = musicLengthMs
        self.model = model
        self.seed = seed
        self.forceInstrumental = forceInstrumental
        self.respectSectionsDurations = true
        self.storeForInpainting = false
        self.signWithC2PA = false
        self.withTimestamps = false
        self.outputFormat = outputFormat
    }
    
    
    public init(
        compositionPlan: CompositionPlan,
        model: ElevenLabsMusicModel = .v2,
        respectSectionsDurations: Bool = true,
        outputFormat: String? = nil
    ) {
        self.prompt = nil
        self.compositionPlan = compositionPlan
        self.musicLengthMs = nil
        self.model = model
        self.seed = nil
        self.forceInstrumental = false
        self.respectSectionsDurations = respectSectionsDurations
        self.storeForInpainting = false
        self.signWithC2PA = false
        self.withTimestamps = false
        self.outputFormat = outputFormat
    }
    
    
    func validate() throws {
        if prompt == nil && compositionPlan == nil {
            throw ElevenLabsMusicError.invalidRequest("потрібно вказати prompt або compositionPlan")
        }
        if prompt != nil && compositionPlan != nil {
            throw ElevenLabsMusicError.invalidRequest("prompt і compositionPlan не можна використовувати одночасно")
        }
        if let prompt, prompt.count > 4100 {
            throw ElevenLabsMusicError.invalidRequest("prompt не може перевищувати 4100 символів (зараз \(prompt.count))")
        }
        if let musicLengthMs, !(3000...600_000).contains(musicLengthMs) {
            throw ElevenLabsMusicError.invalidRequest("musicLengthMs має бути в межах 3000–600000 мс")
        }
        if seed != nil && prompt == nil {
            throw ElevenLabsMusicError.invalidRequest("seed можна використовувати лише разом із prompt")
        }
    }
}

extension MusicComposeRequest: Encodable {
    private enum CodingKeys: String, CodingKey {
        case prompt
        case compositionPlan = "composition_plan"
        case musicLengthMs = "music_length_ms"
        case model = "model_id"
        case seed
        case forceInstrumental = "force_instrumental"
        case respectSectionsDurations = "respect_sections_durations"
        case storeForInpainting = "store_for_inpainting"
        case signWithC2PA = "sign_with_c2pa"
        case withTimestamps = "with_timestamps"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(prompt, forKey: .prompt)
        try container.encodeIfPresent(compositionPlan, forKey: .compositionPlan)
        try container.encodeIfPresent(musicLengthMs, forKey: .musicLengthMs)
        try container.encode(model, forKey: .model)
        try container.encodeIfPresent(seed, forKey: .seed)
        try container.encode(forceInstrumental, forKey: .forceInstrumental)
        try container.encode(respectSectionsDurations, forKey: .respectSectionsDurations)
        try container.encode(storeForInpainting, forKey: .storeForInpainting)
        try container.encode(signWithC2PA, forKey: .signWithC2PA)
        try container.encode(withTimestamps, forKey: .withTimestamps)
    }
}


public struct MusicGenerationOptions: Sendable {
    public enum VocalOption: Sendable {
        case none
        case anyVoice
        case withLyrics(String)
    }
    
    public var genre: String?
    public var mood: String?
    public var tempoBPM: Int?
    public var styleTags: [String]
    public var vocals: VocalOption
    public var durationMs: Int?
    public var model: ElevenLabsMusicModel
    
    public init(
        genre: String? = nil,
        mood: String? = nil,
        tempoBPM: Int? = nil,
        styleTags: [String] = [],
        vocals: VocalOption = .anyVoice,
        durationMs: Int? = nil,
        model: ElevenLabsMusicModel = .v2
    ) {
        self.genre = genre
        self.mood = mood
        self.tempoBPM = tempoBPM
        self.styleTags = styleTags
        self.vocals = vocals
        self.durationMs = durationMs
        self.model = model
    }
    
    
    var forceInstrumental: Bool {
        if case .none = vocals { return true }
        return false
    }
    
    
    func buildPrompt() -> String {
        var parts: [String] = []
        if let genre { parts.append(genre) }
        if let mood { parts.append(mood) }
        if !styleTags.isEmpty { parts.append(styleTags.joined(separator: ", ")) }
        if let tempoBPM { parts.append("tempo around \(tempoBPM) bpm") }
        
        switch vocals {
        case .none:
            parts.append("fully instrumental track, no vocals")
        case .anyVoice:
            parts.append("with expressive vocals")
        case .withLyrics(let lyrics):
            parts.append("with vocals singing the following lyrics: \(lyrics)")
        }
        
        return parts.joined(separator: ", ")
    }
}


public struct MusicTrack: Sendable {
    public let audioData: Data
    public let songID: String?
    
    @discardableResult
    public func save(to url: URL) throws -> URL {
        try audioData.write(to: url, options: .atomic)
        return url
    }
}

public struct DetailedComposeResult: Sendable {
    public let audioData: Data
    public let songID: String?
    public let compositionPlan: CompositionPlan?
    public var songMetadata: SongMetadata?
    
    @discardableResult
    public func save(to url: URL) throws -> URL {
        guard !audioData.isEmpty else { throw ElevenLabsMusicError.emptyAudioData }
        try audioData.write(to: url, options: .atomic)
        return url
    }
}


enum MultipartParser {
    struct Part {
        let headers: [String: String]
        let body: Data
    }
    
    static func boundary(fromContentType contentType: String) -> String? {
        for component in contentType.components(separatedBy: ";") {
            let trimmed = component.trimmingCharacters(in: .whitespaces)
            if trimmed.lowercased().hasPrefix("boundary=") {
                var value = String(trimmed.dropFirst("boundary=".count))
                value = value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                return value
            }
        }
        return nil
    }
    
    static func parse(data: Data, boundary: String) -> [Part] {
        guard let boundaryData = "--\(boundary)".data(using: .utf8) else { return [] }
        
        var ranges: [Range<Data.Index>] = []
        var searchStart = data.startIndex
        while let range = data.range(of: boundaryData, in: searchStart..<data.endIndex) {
            ranges.append(range)
            searchStart = range.upperBound
        }
        guard ranges.count >= 2 else { return [] }
        
        var parts: [Part] = []
        let crlf = Data([0x0D, 0x0A])
        let doubleCRLF = Data([0x0D, 0x0A, 0x0D, 0x0A])
        
        for i in 0..<(ranges.count - 1) {
            var partStart = ranges[i].upperBound
            let partEnd = ranges[i + 1].lowerBound
            guard partStart < partEnd else { continue }
            
            var partData = data.subdata(in: partStart..<partEnd)
            if partData.starts(with: crlf) {
                partData.removeFirst(2)
            }
            if partData.count >= 2, partData.suffix(2) == crlf {
                partData.removeLast(2)
            }
            
            guard let headerSeparator = partData.range(of: doubleCRLF) else { continue }
            let headerData = partData.subdata(in: partData.startIndex..<headerSeparator.lowerBound)
            let bodyData = partData.subdata(in: headerSeparator.upperBound..<partData.endIndex)
            
            var headers: [String: String] = [:]
            if let headerString = String(data: headerData, encoding: .utf8) {
                for line in headerString.components(separatedBy: "\r\n") {
                    let pair = line.split(separator: ":", maxSplits: 1).map {
                        $0.trimmingCharacters(in: .whitespaces)
                    }
                    if pair.count == 2 {
                        headers[pair[0].lowercased()] = pair[1]
                    }
                }
            }
            
            parts.append(Part(headers: headers, body: bodyData))
            partStart = partEnd
        }
        return parts
    }
}

private struct DetailedJSONPayload: Decodable {
    let compositionPlan: CompositionPlan?
    let songMetadata: SongMetadata?
    
    enum CodingKeys: String, CodingKey {
        case compositionPlan = "composition_plan"
        case songMetadata = "song_metadata"
    }
}


public actor ElevenLabsMusicClient {
    
    private let configuration: ElevenLabsConfiguration
    private let decoder: JSONDecoder = JSONDecoder()
    private let encoder: JSONEncoder = JSONEncoder()
    
    public init(configuration: ElevenLabsConfiguration) {
        self.configuration = configuration
    }
    
    public convenience init(apiKey: String) {
        self.init(configuration: ElevenLabsConfiguration(apiKey: apiKey))
    }
    
    
    @discardableResult
    public func composeMusic(_ request: MusicComposeRequest) async throws -> MusicTrack {
        try request.validate()
        
        let url = try buildURL(path: "v1/music", outputFormat: request.outputFormat)
        let urlRequest = try buildRequest(url: url, body: request)
        
        let (data, response) = try await perform(urlRequest)
        let httpResponse = try httpResponse(from: response)
        try validate(httpResponse, data: data)
        
        guard !data.isEmpty else { throw ElevenLabsMusicError.emptyAudioData }
        let songID = httpResponse.value(forHTTPHeaderField: "song-id")
        return MusicTrack(audioData: data, songID: songID)
    }
    
    
    @discardableResult
    public func generateTrack(options: MusicGenerationOptions) async throws -> MusicTrack {
        let request = MusicComposeRequest(
            prompt: options.buildPrompt(),
            musicLengthMs: options.durationMs,
            model: options.model,
            forceInstrumental: options.forceInstrumental
        )
        return try await composeMusic(request)
    }
    
    
    @discardableResult
    public func generateTrackDetailed(options: MusicGenerationOptions) async throws -> DetailedComposeResult {
        let request = MusicComposeRequest(
            prompt: options.buildPrompt(),
            musicLengthMs: options.durationMs,
            model: options.model,
            forceInstrumental: options.forceInstrumental
        )
        return try await composeMusicDetailed(request)
    }
    
    
    public func composeMusicDetailed(_ request: MusicComposeRequest) async throws -> DetailedComposeResult {
        try request.validate()
        
        let url = try buildURL(path: "v1/music/detailed", outputFormat: request.outputFormat)
        let urlRequest = try buildRequest(url: url, body: request)
        
        let (data, response) = try await perform(urlRequest)
        let httpResponse = try httpResponse(from: response)
        try validate(httpResponse, data: data)
        
        let songID = httpResponse.value(forHTTPHeaderField: "song-id")
        
        guard
            let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type"),
            let boundary = MultipartParser.boundary(fromContentType: contentType)
        else {
            return DetailedComposeResult(audioData: data, songID: songID, compositionPlan: nil, songMetadata: nil)
        }
        
        let parts = MultipartParser.parse(data: data, boundary: boundary)
        var compositionPlan: CompositionPlan?
        var songMetadata: SongMetadata?
        var audioData = Data()
        
        for part in parts {
            let partContentType = part.headers["content-type"] ?? ""
            if partContentType.contains("application/json") {
                if let payload = try? decoder.decode(DetailedJSONPayload.self, from: part.body) {
                    compositionPlan = payload.compositionPlan
                    songMetadata = payload.songMetadata
                }
            } else if !part.body.isEmpty {
                audioData = part.body
            }
        }
        
        return DetailedComposeResult(
            audioData: audioData,
            songID: songID,
            compositionPlan: compositionPlan,
            songMetadata: songMetadata
        )
    }
    
    
    public func createCompositionPlan(
        prompt: String,
        musicLengthMs: Int? = nil,
        model: ElevenLabsMusicModel = .v2,
        sourceCompositionPlan: CompositionPlan? = nil
    ) async throws -> CompositionPlan {
        guard prompt.count <= 4100 else {
            throw ElevenLabsMusicError.invalidRequest("prompt не може перевищувати 4100 символів")
        }
        if let musicLengthMs, !(3000...600_000).contains(musicLengthMs) {
            throw ElevenLabsMusicError.invalidRequest("musicLengthMs має бути в межах 3000–600000 мс")
        }
        
        let url = configuration.baseURL.appendingPathComponent("v1/music/plan")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(configuration.apiKey, forHTTPHeaderField: "xi-api-key")
        
        struct PlanRequestBody: Encodable {
            let prompt: String
            let musicLengthMs: Int?
            let modelId: String
            let sourceCompositionPlan: CompositionPlan?
            
            enum CodingKeys: String, CodingKey {
                case prompt
                case musicLengthMs = "music_length_ms"
                case modelId = "model_id"
                case sourceCompositionPlan = "source_composition_plan"
            }
        }
        
        let body = PlanRequestBody(
            prompt: prompt,
            musicLengthMs: musicLengthMs,
            modelId: model.rawValue,
            sourceCompositionPlan: sourceCompositionPlan
        )
        
        do {
            urlRequest.httpBody = try encoder.encode(body)
        } catch {
            throw ElevenLabsMusicError.encodingFailed(error.localizedDescription)
        }
        
        let (data, response) = try await perform(urlRequest)
        let httpResponse = try httpResponse(from: response)
        try validate(httpResponse, data: data)
        
        do {
            return try decoder.decode(CompositionPlan.self, from: data)
        } catch {
            throw ElevenLabsMusicError.decodingFailed(error.localizedDescription)
        }
    }
    
    
    public func streamMusic(_ request: MusicComposeRequest) -> AsyncThrowingStream<Data, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try request.validate()
                    let url = try buildURL(path: "v1/music/stream", outputFormat: request.outputFormat)
                    let urlRequest = try buildRequest(url: url, body: request)
                    
                    let (byteStream, response) = try await configuration.session.bytes(for: urlRequest)
                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.finish(throwing: ElevenLabsMusicError.invalidResponse)
                        return
                    }
                    guard (200...299).contains(httpResponse.statusCode) else {
                        var collected = Data()
                        for try await byte in byteStream { collected.append(byte) }
                        let message = String(data: collected, encoding: .utf8) ?? "Unknown error"
                        continuation.finish(throwing: ElevenLabsMusicError.apiError(statusCode: httpResponse.statusCode, message: message))
                        return
                    }
                    
                    var buffer = Data()
                    let chunkSize = 32 * 1024
                    for try await byte in byteStream {
                        buffer.append(byte)
                        if buffer.count >= chunkSize {
                            continuation.yield(buffer)
                            buffer.removeAll(keepingCapacity: true)
                        }
                    }
                    if !buffer.isEmpty {
                        continuation.yield(buffer)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
    
    
    private func buildURL(path: String, outputFormat: String?) throws -> URL {
        var components = URLComponents(
            url: configuration.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )
        if let outputFormat {
            components?.queryItems = [URLQueryItem(name: "output_format", value: outputFormat)]
        }
        guard let url = components?.url else { throw ElevenLabsMusicError.invalidURL }
        return url
    }
    
    private func buildRequest(url: URL, body: MusicComposeRequest) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(configuration.apiKey, forHTTPHeaderField: "xi-api-key")
        do {
            urlRequest.httpBody = try encoder.encode(body)
        } catch {
            throw ElevenLabsMusicError.encodingFailed(error.localizedDescription)
        }
        return urlRequest
    }
    
    private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await configuration.session.data(for: request)
        } catch {
            throw ElevenLabsMusicError.network(error.localizedDescription)
        }
    }
    
    private func httpResponse(from response: URLResponse) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ElevenLabsMusicError.invalidResponse
        }
        return httpResponse
    }
    
    private func validate(_ response: HTTPURLResponse, data: Data) throws {
        guard (200...299).contains(response.statusCode) else {
            let envelope = try? decoder.decode(ElevenLabsAPIErrorEnvelope.self, from: data)
            let message = envelope?.detail?.message
            ?? String(data: data, encoding: .utf8)
            ?? "Unknown error"
            throw ElevenLabsMusicError.apiError(statusCode: response.statusCode, message: message)
        }
    }
}




// MARK: - Usage example (для довідки, не виконується автоматично)
//
// let client = ElevenLabsMusicClient(apiKey: "YOUR_XI_API_KEY")
//
// // 1) Проста генерація за жанром/темпом/вокалом:
// let track = try await client.generateTrack(
//     options: MusicGenerationOptions(
//         genre: "lo-fi hip-hop",
//         mood: "relaxed, nostalgic",
//         tempoBPM: 85,
//         styleTags: ["vinyl crackle", "warm piano"],
//         vocals: .none,
//         durationMs: 60_000
//     )
// )
// let savedURL = try track.save(to: destinationURL)
//
// // 2) Генерація з власним текстом пісні:
// let sungTrack = try await client.composeMusic(
//     MusicComposeRequest(
//         prompt: "upbeat pop anthem with vocals singing: 'we rise together, higher than before'",
//         musicLengthMs: 30_000
//     )
// )
//
// // 3) Детальна генерація з метаданими (жанри, мова, чи є explicit):
// let detailed = try await client.composeMusicDetailed(
//     MusicComposeRequest(prompt: "cinematic orchestral trailer, epic and dark", musicLengthMs: 20_000)
// )
// print(detailed.songMetadata?.genres ?? [])
//
// // 4) Composition plan для точного контролю секцій:
// let plan = try await client.createCompositionPlan(prompt: "energetic EDM festival anthem")
// let planTrack = try await client.composeMusic(MusicComposeRequest(compositionPlan: plan))
//
// // 5) Стрімінг для програвання ще під час генерації:
// for try await chunk in client.streamMusic(MusicComposeRequest(prompt: "ambient space drone")) {
//     // передати chunk у аудіоплеєр / буфер
// }
