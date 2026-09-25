# Análise de Upgrade de Target iOS — RainStorm

> **Data:** 24/09/2026 · **Escopo:** definir o deployment target mínimo que alcance o maior número de iPhones no Brasil, mapear as melhorias do Swift moderno aplicáveis ao código atual, planejar a migração para SwiftUI (iOS 16 · Xcode 26) e o plano de testes da migração.

---

## 1. Resumo Executivo

| Item | Hoje | Recomendado |
|------|------|-------------|
| Deployment target | iOS 13.0 / 13.2 (inconsistente) | **iOS 16.0** (todos os targets) |
| Linguagem | Swift 5.0 | **Swift 6** language mode |
| Xcode | Formato Xcode 11.2 | **Xcode 26** (exigido pela App Store) |
| Interface | UIKit + Storyboards | **SwiftUI** (ciclo de vida `App`, iOS 16) — seção 6 |
| Testes | XCTest vazio (template) | **Swift Testing** + XCUITest + snapshot + Test Plans — seção 7 |

**Por que iOS 16:** é o menor target que ainda roda no **iPhone 8, 8 Plus e X**. Esses modelos continuam comuns no Brasil por causa do mercado de usados e recondicionados. Com iOS 16 o app já tem acesso a todo o Swift moderno de que precisa (async/await, Swift 6, `FormatStyle`, `Measurement`, Swift Testing) e a um **SwiftUI maduro**: `NavigationStack`, `.task`, `.refreshable`, Swift Charts e `Layout`. O que fica de fora do iOS 17 (`@Observable`, SwiftData, `ContentUnavailableView`) tem substituto direto no iOS 16 (seção 6). Por isso não compensa perder o iPhone 8/X da base.

### 1.1 Status da implementação (24/09/2026)

As fases 1 a 8 do roteiro (seção 8) foram implementadas: iOS 16.0, Swift 6 (strict concurrency `complete`, isolamento padrão `MainActor`), app 100% SwiftUI, projeto gerado por **XcodeGen** (`project.yml`) e a suíte de testes da seção 7. O build do app sai sem warnings.

**Resultado dos testes**

| Execução | Destino | Resultado |
|----------|---------|-----------|
| Test Plan `RainStorm` (pt-BR + en-US): unit, snapshot, UI, acessibilidade | iPhone 17 / iOS 26.5 | ✅ 54 testes (144 casos com parametrizados) × 2 idiomas, 0 falhas |
| Test Plan `Nightly` (Thread Sanitizer + performance + retry) | iPhone 17 / iOS 26.5 | ✅ pt-BR: 145/145. TSan: 144/144 **sem nenhum data race**. Performance pulada sob sanitizer (medida só no build normal) |
| Test Plan `RainStorm` sem snapshots (compatibilidade) | iPhone SE 3 / iOS 18.2 | ✅ 48/48 |
| Cobertura de código (target `RainStorm`) | — | 96,09% (884/920 linhas) |

**Desvios em relação ao plano**

| Plano | Implementado | Motivo |
|-------|-------------|--------|
| Etapa B (SwiftUI dentro de `UIHostingController`) | Migração direta para o ciclo de vida SwiftUI | Implementação feita de uma vez, sem publicação intermediária; a etapa só faria sentido com releases entre as fases |
| Mocks em `RainStormTests/Support` | Mocks e fixture em `RainStorm/App/Debug` (`#if DEBUG`) | Os UI tests e os `#Preview` precisam deles dentro do app; os testes unitários os reutilizam via `@testable import` |
| GPX de São Paulo no Test Plan | `XCUIDevice.shared.location` (iOS 16.4+) no próprio teste | Sem arquivo extra; o teste pula com `XCTSkip` em runtimes mais antigos |
| Simulador iPhone 8 / iOS 16 | iPhone SE 3 / iOS 18.2 e iPhone 17 / iOS 26.5 | Esta instalação do Xcode 26.5 não oferece runtime iOS 16. **A regressão em iOS 16 precisa de um iPhone 8/X físico** |
| Cor da marca `#4FB8D4` | Adaptativa: `#367D90` no modo claro, original no escuro | Contraste de 2,30:1 sobre branco (mínimo WCAG AA: 4,5:1), reprovado no `performAccessibilityAudit`. **Decisão de design a validar** |
| `.secondary` do sistema | `Color.secondaryText` (6,4:1 claro / 7,7:1 escuro) | O `.secondary` fica em ~3,4:1 e reprovou no audit |
| Localização padrão Cupertino | São Paulo, com banner "Mostrando a previsão para São Paulo" | App voltado ao Brasil; o usuário sabe por que não vê a própria cidade |

**Bugs encontrados pelos testes durante a migração**

1. `Date.ParseStrategy` é leniente por padrão: `"2026-13-45"` virava uma data válida. Corrigido com `isLenient: false`.
2. `capitalized(with:)` gerava "Quinta-Feira". Corrigido com `capitalizationContext(.beginningOfSentence)` ("Quinta-feira").
3. `String(localized:locale:)` não troca o idioma, só a formatação. Corrigido com `LocalizedStringResource.locale`.
4. `.accessibilityIdentifier` num container sobrescreve o dos filhos (o botão de retry sumia para o XCUITest). Corrigido com `.accessibilityElement(children: .contain)`.
5. `Task.sleep(nanoseconds: .max)` retorna imediatamente no iOS 18: o cenário de loading virava erro (pego só pelo destino iOS 18.2). Corrigido com esperas curtas em laço.
6. Em XXXL o gráfico ficava ilegível. Limitado a `.xxLarge`, já que a lista "Próximos dias" traz os mesmos valores em texto grande.
7. Os 14 rótulos desenhados no gráfico não existiam na árvore de acessibilidade. O gráfico virou um elemento com resumo + `AXChartDescriptor` (Audio Graph).
8. Os já conhecidos da seção 2 (`Conversions` com `Int` e `"YYYY"`) foram eliminados: `Conversions.swift` saiu e as datas usam `FormatStyle`.

**Exceção documentada na auditoria:** issues de Dynamic Type nos cabeçalhos de seção da `List` (identificador `weather.sectionHeader`) são ignoradas no `testAccessibilityAudit`. Trata-se de falso positivo: o snapshot `loadedWithLargestAccessibilityTextSize` prova que eles escalam.

**Widget (24/09/2026, seção 11):** extensão `RainStormWidget` com o card "Clima atual". Test Plan `RainStorm` completo (unit + snapshot + UI, pt-BR e en-US): ✅ 453 casos. `Nightly` (TSan): ✅ sem data race. iPhone SE 3 / iOS 18.2 sem snapshots: ✅, incluindo os 21 testes do widget e o deep link.

**Pendente:** mensagens de erro por caso em `WeatherDataError+Presentation.swift` (hoje, texto genérico) e regressão manual em iPhone 8/X com iOS 16.

---

## 2. Estado Atual do Projeto

| Aspecto | Situação | Problema |
|---------|----------|----------|
| `IPHONEOS_DEPLOYMENT_TARGET` | 13.0 no projeto, 13.2 nos targets | Abaixo do mínimo do Xcode 26 (iOS 15); inconsistente |
| `SWIFT_VERSION` | 5.0 | Sem checagem de concorrência |
| `LastUpgradeCheck` | 1120 (Xcode 11.2) | Build settings desatualizados |
| Entry point | `@UIApplicationMain` | Deprecado; usar `@main` |
| Rede | `URLSession.dataTask` + callback + `DispatchQueue.main.async` | Aninhamento, sem `MainActor` |
| Localização | `locationManager(_:didChangeAuthorization:)` | Assinatura deprecada desde iOS 14 |
| Formatação | `DateFormatter()` criado a cada ViewModel + `String(format:)` | Custo de performance, sem localização automática |
| Cores | `.black` / `.white` fixos | Sem Dark Mode |
| Testes | XCTest vazio (template) | Sem cobertura |
| Privacidade | Sem `PrivacyInfo.xcprivacy` | Exigido pela App Store |

### Bugs encontrados durante a análise

1. **`Conversions.fahrenheitToCelsius(tempInF: Int)` sempre retorna 0.** `(5/9)` é divisão inteira e dá `0`. O mesmo acontece em `celsiusToFahrenheit(tempInC: Int)`, onde `9/5` dá `1`.
   Arquivo: [Conversions.swift](../RainStorm/Utils/Conversions.swift)
2. **`DayViewModel.date` usa `"YYYY"`**, que é o ano da semana ISO (*week-year*). Nos últimos dias de dezembro isso mostra o ano seguinte. O correto é `"yyyy"`, ou melhor ainda, `FormatStyle` (seção 5.4).
   Arquivo: [DayViewModel.swift](../RainStorm/View%20Controllers/Weather%20View%20Controller/Day%20View%20Controller/View%20Models/DayViewModel.swift)

---

## 3. Análise de Mercado — Brasil

### Aparelhos por versão mínima

| Target mínimo | iPhones mais antigos suportados | Situação da versão | Avaliação |
|---------------|--------------------------------|--------------------|-----------|
| iOS 15 | 6s, 7, SE (1ª geração) | Último update em 2023 | Fatia desprezível; aparelhos sem suporte há anos |
| **iOS 16** | **8, 8 Plus, X** | Congelado em 16.7.x | **Melhor alcance real no Brasil** |
| iOS 17 | XS, XR | Substituída pelo 18 | Perde 8/X; ganha `@Observable`, `CLLocationUpdate` |
| iOS 18 | XS, XR (mesma lista do 17) | Ainda com base relevante | Não traz aparelhos novos em relação ao 17 |
| iOS 26 | 11 em diante | Versão atual | Corta XS/XR, muito usados no Brasil |

### Dados disponíveis

- **Apple (mundial, jun/2026):** 79% de todos os iPhones no iOS 26, 14% no iOS 18 e **7% em versões mais antigas**.
- **Brasil:** a adoção é mais lenta que a média mundial. A base de aparelhos é mais antiga e o preço dos modelos novos pesa muito. A fatia "mais antigos que o iOS 18", que cai no iOS 16/17, tende a ser **maior que os 7% mundiais**.
- **Cuidado com o StatCounter:** até jan/2026 o Safari reportava o iOS 26.x como 18.x por causa das proteções anti-fingerprinting. Dados anteriores a essa correção inflam o iOS 18.

> **Ação recomendada:** depois de publicar, acompanhar a distribuição real em *App Store Connect → Analytics → Métricas → Versão do SO* e rever o target a cada WWDC. Quando o iOS 16 ficar abaixo de ~2% da base do app, subir para o iOS 17.

### E a migração para SwiftUI? Continua iOS 16

O SwiftUI no iOS 16 atende bem um app de clima com duas telas. O que só existe no iOS 17+ tem substituto no 16:

| API iOS 17+ | Substituto no iOS 16 |
|-------------|----------------------|
| `@Observable` / `@Bindable` | `ObservableObject` + `@Published` + `@StateObject` / `@ObservedObject` |
| `ContentUnavailableView` | View própria `EmptyStateView` (ícone + texto + botão) |
| `CLLocationUpdate.liveUpdates()` | `LocationProvider` com `CheckedContinuation` (seção 5.2) |
| SwiftData | Não é necessário (o app não persiste dados); se precisar de cache, `Codable` + arquivo em `Caches/` |
| `.onChange(of:initial:_:)` (2 parâmetros) | `.onChange(of:perform:)` |
| `scrollTargetBehavior`, `.symbolEffect` | Opcionais, via `if #available(iOS 17, *)` |

> Quando o iOS 16 ficar abaixo de ~2% da base do app, subir para o iOS 17 e trocar `ObservableObject` por `@Observable`. É uma mudança mecânica se a arquitetura da seção 6 for seguida.

---

## 4. Configurações do Projeto

Aplicar em **todos os targets** (RainStorm, RainStormTests, RainStormUITests):

| Build Setting | Valor |
|---------------|-------|
| `IPHONEOS_DEPLOYMENT_TARGET` | `16.0` |
| `SWIFT_VERSION` | `6.0` |
| `SWIFT_STRICT_CONCURRENCY` | `complete` (começar com `targeted` para migrar aos poucos) |
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` (opcional, Swift 6.2 "Approachable Concurrency") |
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` (opcional) |

Passos:
1. Abrir no Xcode 26 → **Editor ▸ Validate Settings… / Update to recommended settings**.
2. Alterar os valores acima em *Build Settings* (nível projeto e targets).
3. Build verde **antes** de qualquer refatoração.

> `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` combina bem com um app UIKit pequeno: tudo passa a rodar na main thread por padrão, e só o que for marcado como `nonisolated` (parse de JSON, por exemplo) sai dela. Isso reduz bastante o ruído de erros ao ativar o Swift 6.

---

## 5. Melhorias do Swift Aplicáveis ao Código

### 5.1 `async/await` na camada de rede

**Arquivo:** [RootViewModel.swift](../RainStorm/View%20Controllers/Root%20View%20Controller/View%20Models/RootViewModel.swift)

**Antes:**
```swift
URLSession.shared.dataTask(with: weatherRequest.url) { [weak self] (data, response, error) in
    DispatchQueue.main.async {
        if let error = error {
            self?.didFetchWeaterData?(nil, .noWeatherDataAvailable)
        } else if let data = data {
            do {
                let openMeteoResponse = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
                self?.didFetchWeaterData?(openMeteoResponse, nil)
            } catch { ... }
        }
    }
}.resume()
```

**Depois:**
```swift
@MainActor
final class RootViewModel: NSObject {

    var didFetchWeatherData: ((Result<WeatherData, WeatherDataError>) -> Void)?

    private func fetchWeatherData(for location: CLLocation) async {
        let request = WeatherRequest(baseUrl: WeatherService.baseUrl, location: location)
        do {
            let (data, response) = try await URLSession.shared.data(from: request.url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw WeatherDataError.noWeatherDataAvailable
            }
            let weather = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
            didFetchWeatherData?(.success(weather))
        } catch {
            didFetchWeatherData?(.failure(.noWeatherDataAvailable))
        }
    }
}
```

**Ganhos:** acabam o `DispatchQueue.main.async` e os `[weak self]`. O `@MainActor` garante que a UI seja atualizada na main thread em tempo de compilação. O `Result` substitui a tupla `(WeatherData?, WeatherDataError?)`, que permitia o estado inválido "ambos nil" (hoje tratado com o `else` de "sem dados"). De quebra, corrige o typo `didFetchWeaterData`.

### 5.2 Localização com `async` + API atual de autorização

**Hoje:** usa `locationManager(_:didChangeAuthorization:)`, deprecado desde o iOS 14.

**Depois:** usar `locationManagerDidChangeAuthorization(_:)` e expor a localização via `CheckedContinuation`. `CLLocationUpdate.liveUpdates()` só existe a partir do iOS 17.
```swift
@MainActor
final class LocationProvider: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
    }

    func currentLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            switch manager.authorizationStatus {
            case .notDetermined: manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways: manager.requestLocation()
            default: resume(with: .failure(LocationError.notAuthorized))
            }
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) { ... }
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { ... }
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { ... }
}
```
Com isso, o `RootViewModel` fica linear:
```swift
func load() async {
    await fetchWeatherData(for: Defaults.location)
    if let location = try? await locationProvider.currentLocation() {
        await fetchWeatherData(for: location)
    }
}
```
> Também vale tirar o trabalho do `init()` do `RootViewModel`. Hoje ele dispara rede e localização no construtor, o que dificulta os testes. Chamar `Task { await viewModel.load() }` no `viewDidLoad`.

### 5.3 `@main` no AppDelegate

**Arquivo:** [AppDelegate.swift](../RainStorm/Application%20Delegate/AppDelegate.swift)
```swift
// Antes
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate { ... }

// Depois
@main
final class AppDelegate: UIResponder, UIApplicationDelegate { ... }
```

### 5.4 `Date.FormatStyle` e `Measurement` no lugar de `DateFormatter` / `String(format:)`

**Arquivos:** `DayViewModel.swift`, `WeekDayViewModel.swift`

**Antes:**
```swift
private let dateFormatter = DateFormatter()   // criado a cada ViewModel

var date: String {
    dateFormatter.dateFormat = "EEE, MMMM d YYYY"   // bug do "YYYY"
    return dateFormatter.string(from: weatherData.time)
}

var temperature: String {
    String(format: "%.1f ºC", weatherData.temperature)
}
```

**Depois:**
```swift
var date: String {
    weatherData.time.formatted(.dateTime.weekday(.abbreviated).month(.wide).day().year())
    // pt-BR → "qua., 24 de setembro de 2026"
}

var time: String {
    weatherData.time.formatted(date: .omitted, time: .shortened)   // "14:30"
}

var temperature: String {
    Measurement(value: weatherData.temperature, unit: UnitTemperature.celsius)
        .formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(1))))
    // "24,5 °C" — vírgula decimal automática no Brasil
}

var windSpeed: String {
    Measurement(value: weatherData.windSpeed, unit: UnitSpeed.kilometersPerHour)
        .formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(0))))
}
```

**Ganhos:** usa o locale do aparelho (vírgula decimal, nomes de dias em português), elimina o custo de criar `DateFormatter` e deixa [Conversions.swift](../RainStorm/Utils/Conversions.swift) obsoleto, porque `Measurement.converted(to:)` faz °C↔°F e km/h↔mph sem bug de divisão inteira. Também corrige o uso de `ºC` (ordinal *º*) no lugar do símbolo de grau `°`.

### 5.5 Sintaxe moderna do Swift (5.7+)

| Recurso | Exemplo no projeto |
|---------|-------------------|
| `if let` / `guard let` abreviado | `guard let viewModel else { return }` em todos os `didSet` de `viewModel` |
| Typed throws (Swift 6) | `func fetch() async throws(WeatherDataError) -> WeatherData` |
| `Sendable` | `struct OpenMeteoResponse: Decodable, Sendable` (permite passar entre actors) |
| `some` / `any` explícitos | `let weatherData: any CurrentWeatherConditions` em `DayViewModel` |
| `if`/`switch` como expressão (Swift 5.9) | `let alertType: AlertType = switch error { case .notAuthorizedToRequestLocation: .notAuthorizedToRequestLocation ... }` em `RootViewController` |

### 5.6 UIKit moderno (iOS 16)

> **Com a migração para SwiftUI (seção 6), esta subseção vira opcional.** Só vale aplicar se o UIKit for continuar em produção por muito tempo durante a transição. As ideias de cores dinâmicas, Dynamic Type e SF Symbols passam direto para o SwiftUI, que já as trata por padrão.

| Recurso | Aplicação |
|---------|-----------|
| `UITableViewDiffableDataSource` | `WeekViewController`: substitui o `UITableViewDataSource` manual + `reloadData()` e anima as atualizações |
| `UIContentConfiguration` / `UIListContentConfiguration` | Alternativa ao `WeekDayTableViewCell` baseado em outlets; o protocolo `WeekDayRepresentable` (hoje comentado) volta a ser útil como input da configuração |
| Cores dinâmicas (`.label`, `.secondaryLabel`, `.systemBackground`) | [Styles.swift](../RainStorm/Configuration/Styles.swift): troca `.black`/`.white`/`lightBackgroundColor` fixos, com **Dark Mode** automático |
| Dynamic Type (`UIFont.preferredFont(forTextStyle:)` + `adjustsFontForContentSizeCategory`) | `UIFont.Rainstorm`: hoje os tamanhos são fixos (17/15/20 pt) |
| SF Symbols (`cloud.rain.fill`, `sun.max.fill`…) | Fallback ou substituto dos PNGs em `Weather Icons`, com suporte a multicolor |
| `UIAlertController` + `UIAction` | Mantém o padrão atual; só localizar as mensagens (hoje em inglês) |

### 5.7 Swift Testing

Substituir o template XCTest vazio em [RainStormTests.swift](../RainStormTests/RainStormTests.swift):
```swift
import Testing
@testable import RainStorm

struct WeatherCodeMapperTests {
    @Test(arguments: [(0, "clear-day"), (2, "cloudy"), (45, "fog"), (61, "rain"), (73, "snow")])
    func iconName(code: Int, expected: String) {
        #expect(WeatherCodeMapper.iconName(for: code) == expected)
    }
}

struct ConversionsTests {
    @Test func fahrenheitToCelsiusInt() {
        #expect(Conversions().fahrenheitToCelsius(tempInF: 212) == 100)   // falha hoje: retorna 0
    }
}
```
> Swift Testing funciona com qualquer deployment target suportado pelo Xcode 26. O teste de `Conversions` já **expõe o bug** descrito na seção 2.

### 5.8 Privacy Manifest

Adicionar `RainStorm/PrivacyInfo.xcprivacy` declarando:
- `NSPrivacyAccessedAPITypes`: `UserDefaults` e APIs de data/tempo de arquivo, se forem usadas.
- `NSPrivacyCollectedDataTypes`: **Precise Location** (uso: *App Functionality*, não vinculado à identidade, sem tracking).
- Revisar o texto de `NSLocationWhenInUseUsageDescription` no `Info.plist` (em pt-BR).

---

## 6. Migração para SwiftUI (iOS 16 · Xcode 26)

### 6.1 Estratégia: migração incremental em 3 etapas

Não é preciso reescrever tudo de uma vez. A migração segue o padrão *strangler*: a camada nova cresce em volta da antiga até a antiga poder ser removida.

| Etapa | O que muda | App continua publicável? |
|-------|-----------|--------------------------|
| **A. Domínio independente de UI** | Serviço de clima, provedor de localização e `WeatherViewModel` saem dos view controllers e passam a ser testáveis | Sim (UIKit consome o novo ViewModel) |
| **B. Telas SwiftUI dentro do UIKit** | `CurrentWeatherView` e `ForecastListView` hospedadas em `UIHostingController` no lugar de `DayViewController` / `WeekViewController` | Sim |
| **C. Ciclo de vida SwiftUI** | `@main struct RainStormApp: App`; remoção de `Main.storyboard`, `SceneDelegate`, `AppDelegate` e das entradas de cena do `Info.plist` | Sim |

### 6.2 Arquitetura alvo

```
RainStorm/
├── App/
│   ├── RainStormApp.swift          // @main, monta dependências
│   └── AppDependencies.swift       // real × mock (UI tests)
├── Domain/
│   ├── WeatherSnapshot.swift       // modelo de UI (Sendable)
│   └── WeatherDataError.swift
├── Services/
│   ├── WeatherServicing.swift      // protocolo + OpenMeteoWeatherService
│   ├── LocationProviding.swift     // protocolo + LocationProvider (CLLocationManager)
│   └── OpenMeteoResponse.swift     // DTO Decodable
├── Features/Weather/
│   ├── WeatherViewModel.swift      // ObservableObject @MainActor
│   ├── WeatherScreen.swift
│   ├── CurrentWeatherView.swift
│   ├── ForecastRow.swift
│   └── EmptyStateView.swift        // substitui ContentUnavailableView (iOS 17)
└── Resources/
    ├── Localizable.xcstrings       // String Catalog pt-BR / en
    └── PrivacyInfo.xcprivacy
```

**Contratos (pontos de injeção para testes):**
```swift
protocol WeatherServicing: Sendable {
    func forecast(for coordinate: CLLocationCoordinate2D) async throws(WeatherDataError) -> WeatherSnapshot
}

@MainActor
protocol LocationProviding {
    func currentLocation() async throws -> CLLocation
}
```

**ViewModel (iOS 16, sem `@Observable`):**
```swift
@MainActor
final class WeatherViewModel: ObservableObject {

    enum State: Equatable {
        case loading
        case loaded(WeatherSnapshot)
        case failed(WeatherDataError)
    }

    @Published private(set) var state: State = .loading

    private let service: any WeatherServicing
    private let location: any LocationProviding

    init(service: any WeatherServicing, location: any LocationProviding) {
        self.service = service
        self.location = location
    }

    func load() async {
        do {
            let coordinate = (try? await location.currentLocation())?.coordinate
                ?? Defaults.location.coordinate
            state = .loaded(try await service.forecast(for: coordinate))
        } catch {
            state = .failed(error)
        }
    }
}
```
> Se a permissão de localização for negada, o app cai na localização padrão em vez de travar. Hoje o `Defaults.location` aponta para Cupertino; vale trocar por uma cidade brasileira (São Paulo: `-23.5505, -46.6333`).

**Tela principal:**
```swift
struct WeatherScreen: View {
    @StateObject var viewModel: WeatherViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView().accessibilityIdentifier("weather.loading")
                case .loaded(let snapshot):
                    List {
                        CurrentWeatherView(current: snapshot.current)
                        Section("Próximos dias") {
                            ForEach(snapshot.forecast) { ForecastRow(day: $0) }
                        }
                    }
                    .refreshable { await viewModel.load() }
                case .failed(let error):
                    EmptyStateView(error: error) { Task { await viewModel.load() } }
                }
            }
            .navigationTitle("RainStorm")
        }
        .task { await viewModel.load() }
    }
}

#Preview("Carregado") {
    WeatherScreen(viewModel: .preview(.loaded(.fixture)))
}
```
> O `#Preview` funciona com target iOS 16 para views SwiftUI. Os `.preview(...)` / `.fixture` são os **mesmos dados** usados nos testes (seção 7.3), então o que aparece no preview é o que está sendo testado.

### 6.3 Mapeamento arquivo a arquivo

| Hoje (UIKit) | Depois (SwiftUI) |
|--------------|------------------|
| `AppDelegate.swift`, `SceneDelegate.swift` | `RainStormApp.swift` (removidos) |
| `Main.storyboard` | removido; `LaunchScreen.storyboard` → chave `UILaunchScreen` no `Info.plist` |
| `RootViewController` + `RootViewModel` | `WeatherScreen` + `WeatherViewModel` |
| `DayViewController` + `DayViewModel` | `CurrentWeatherView` (+ formatação no `WeatherSnapshot`) |
| `WeekViewController`, `WeekDayTableViewCell`, `WeekViewModel`, `WeekDayViewModel` | `ForecastRow` dentro de `List` |
| `WeekDayRepresentable` | removido (o `WeatherSnapshot.Day` cumpre o papel) |
| `Styles.swift` (`UIColor`/`UIFont`) | `Color`/`Font` + `ShapeStyle` (`.primary`, `.secondary`, `.tint`) |
| `UIStoryboard.swift`, `UIViewController.swift` | removidos |
| `UIImage.imageForIcon` | `Image(iconName)` ou SF Symbol com `.symbolRenderingMode(.multicolor)` |
| `Conversions.swift` | removido (`Measurement`, seção 5.4) |
| Alertas `UIAlertController` | `EmptyStateView` com botão "Tentar novamente" (ou `.alert(isPresented:)`) |

### 6.4 Recursos de SwiftUI disponíveis no iOS 16 que valem usar

| Recurso | Uso no RainStorm |
|---------|------------------|
| `NavigationStack` | Navegação para um futuro detalhe do dia |
| `.task { }` | Carregamento cancelado automaticamente quando a view sai da tela |
| `.refreshable { }` | Puxar para atualizar |
| **Swift Charts** | Gráfico de mínima/máxima da semana (`LineMark` / `AreaMark`) |
| `ViewThatFits`, `Grid` | Layout adaptável para iPhone SE/8 (4,7") até Pro Max |
| String Catalog (`.xcstrings`) | Textos em pt-BR/en, extraídos automaticamente pelo Xcode (funciona com target 16) |
| Dynamic Type / Dark Mode | Automático com `Font.body`, `.headline` e estilos semânticos |

### 6.5 Correções de dados a fazer junto com a migração

- `OpenMeteoResponse.dailyForecasts` acessa `daily.temperatureMin[index]` etc. com o índice de `daily.time`. **Se a API devolver arrays de tamanhos diferentes, o app trava.** Use `zip` ou valide os tamanhos no decode.
- O mesmo método usa `formatter.date(from:) ?? Date()`. Uma data inválida vira "hoje" em silêncio. Melhor lançar erro de decodificação.
- O `DateFormatter` de `dailyForecasts` não define `timeZone` nem `locale` (`en_US_POSIX`), então o resultado muda conforme o aparelho. Use `Date.ISO8601FormatStyle().year().month().day()` ou fixe os dois.

---

## 7. Plano de Testes

### 7.1 Estratégia (pirâmide)

| Camada | Framework | O que cobre | Quando roda |
|--------|-----------|-------------|-------------|
| **Unitário** | Swift Testing | Decode do `OpenMeteoResponse`, `WeatherCodeMapper`, formatação pt-BR, estados do `WeatherViewModel` | Todo build / PR |
| **Integração** | Swift Testing + `URLProtocol` stub | `OpenMeteoWeatherService`: URL montada, decode, HTTP ≠ 200, timeout | Todo PR |
| **Snapshot** | [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) (compatível com Swift Testing) | Views SwiftUI em cada estado × claro/escuro × Dynamic Type × tela 4,7"/6,1" | Todo PR |
| **UI / E2E** | XCUITest (XCTest) | Fluxo de abertura, permissão de localização, erro + "Tentar novamente", pull-to-refresh | PR para `master` / nightly |
| **Performance** | XCTest `measure` + `XCTApplicationLaunchMetric` | Tempo de abertura no simulador iOS 16 | Nightly |
| **Acessibilidade** | `XCUIApplication.performAccessibilityAudit()` | Contraste, rótulos, Dynamic Type | Nightly (só em runtime iOS 17+, ou seja, no destino iOS 26) |

> **Por que dois frameworks:** Swift Testing é o padrão atual para testes unitários e de integração (paralelo por padrão, parametrizado, `#expect`/`#require`, tags, traits). **UI tests e testes de performance ainda precisam de XCTest.** Os dois convivem no mesmo projeto e no mesmo Test Plan.

### 7.2 Estrutura dos targets de teste

```
RainStormTests/                      // Swift Testing (unit + integração + snapshot)
├── Fixtures/
│   ├── forecast_success.json        // resposta real da Open-Meteo gravada
│   ├── forecast_mismatched_arrays.json
│   └── forecast_invalid_date.json
├── Support/
│   ├── MockWeatherService.swift
│   ├── StubLocationProvider.swift
│   ├── URLProtocolStub.swift
│   ├── WeatherSnapshot+Fixture.swift  // compartilhado com os #Preview
│   └── Tags.swift
├── Domain/        WeatherCodeMapperTests, OpenMeteoResponseDecodingTests, FormattingTests
├── Services/      OpenMeteoWeatherServiceTests
├── Features/      WeatherViewModelTests
└── Snapshots/     WeatherScreenSnapshotTests (+ __Snapshots__/)

RainStormUITests/                    // XCTest (XCUITest)
├── Support/       LaunchArguments.swift, Screens (Page Objects)
├── WeatherFlowUITests.swift
├── LocationPermissionUITests.swift
└── LaunchPerformanceTests.swift

RainStorm.xctestplan                 // Test Plan com as configurações da seção 7.5
```

### 7.3 Pontos de injeção (o que torna o app testável)

| Dependência | Real | Teste unitário | UI test |
|-------------|------|----------------|---------|
| Clima | `OpenMeteoWeatherService(session:)` | `MockWeatherService` (retorna fixture ou erro) | Mock escolhido por launch argument |
| Rede | `URLSession.shared` | `URLSession` com `URLProtocolStub` | — |
| Localização | `LocationProvider` | `StubLocationProvider` | Mock ou GPX do Test Plan |
| Locale / fuso | `.current` | `Locale(identifier: "pt_BR")`, `TimeZone(identifier: "America/Sao_Paulo")` | Configuração do Test Plan |

**Seleção de dependências no app** (só para UI tests; nada de rede real em testes):
```swift
@main
struct RainStormApp: App {
    private let dependencies = AppDependencies.make(arguments: ProcessInfo.processInfo.arguments)

    var body: some Scene {
        WindowGroup {
            WeatherScreen(viewModel: WeatherViewModel(service: dependencies.weather,
                                                      location: dependencies.location))
        }
    }
}

enum AppDependencies {
    static func make(arguments: [String]) -> (weather: any WeatherServicing, location: any LocationProviding) {
        #if DEBUG
        if arguments.contains("-ui-testing") {
            let scenario = UITestScenario(arguments: arguments)   // .success, .networkError, .locationDenied
            return (MockWeatherService(scenario: scenario), StubLocationProvider(scenario: scenario))
        }
        #endif
        return (OpenMeteoWeatherService(), LocationProvider())
    }
}
```
> O `#if DEBUG` garante que os mocks nunca entrem no build de release. Para isso os mocks de UI ficam no target do app, dentro de `#if DEBUG`, e não no target de testes.

### 7.4 Exemplos de testes

**Tags compartilhadas:**
```swift
import Testing

extension Tag {
    @Tag static var decoding: Self
    @Tag static var networking: Self
    @Tag static var viewModel: Self
    @Tag static var formatting: Self
}
```

**Decode com fixture (`#require` para parar cedo):**
```swift
@Suite("OpenMeteoResponse", .tags(.decoding))
struct OpenMeteoResponseDecodingTests {

    @Test func decodesSevenDayForecast() throws {
        let data = try #require(Fixture.data("forecast_success"))
        let response = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)

        #expect(response.dailyForecasts.count == 7)
        #expect(response.currentWeather.weathercode == 3)
    }

    @Test func mismatchedDailyArraysThrowInsteadOfCrashing() throws {
        let data = try #require(Fixture.data("forecast_mismatched_arrays"))
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        }
    }
}
```

**Formatação determinística em pt-BR:**
```swift
@Suite(.tags(.formatting))
struct FormattingTests {
    let locale = Locale(identifier: "pt_BR")

    @Test(arguments: [(24.54, "24,5 °C"), (-3.0, "-3,0 °C"), (0.0, "0,0 °C")])
    func temperature(value: Double, expected: String) {
        #expect(WeatherFormatter.temperature(value, locale: locale) == expected)
    }

    @Test func yearUsesCalendarYearNotWeekYear() throws {
        // 29/12/2025 pertence à semana ISO 1 de 2026: com "YYYY" isso mostrava 2026.
        let date = try #require(DateComponents(calendar: .init(identifier: .gregorian),
                                                timeZone: .gmt, year: 2025, month: 12, day: 29).date)
        #expect(WeatherFormatter.fullDate(date, locale: locale).contains("2025"))
    }
}
```

**ViewModel (estados, `@MainActor`):**
```swift
@MainActor
@Suite(.tags(.viewModel))
struct WeatherViewModelTests {

    @Test func loadsForecastForUserLocation() async {
        let service = MockWeatherService(result: .success(.fixture))
        let sut = WeatherViewModel(service: service, location: StubLocationProvider(.saoPaulo))

        await sut.load()

        #expect(sut.state == .loaded(.fixture))
        #expect(await service.requestedCoordinates == [.saoPaulo])
    }

    @Test func fallsBackToDefaultLocationWhenPermissionDenied() async {
        let service = MockWeatherService(result: .success(.fixture))
        let sut = WeatherViewModel(service: service, location: StubLocationProvider(error: .notAuthorized))

        await sut.load()

        #expect(await service.requestedCoordinates == [Defaults.location.coordinate])
    }

    @Test func exposesErrorWhenServiceFails() async {
        let sut = WeatherViewModel(service: MockWeatherService(result: .failure(.noWeatherDataAvailable)),
                                   location: StubLocationProvider(.saoPaulo))
        await sut.load()
        #expect(sut.state == .failed(.noWeatherDataAvailable))
    }
}
```

**Serviço com `URLProtocolStub`** (`.serialized` porque o stub usa estado estático):
```swift
@Suite(.tags(.networking), .serialized)
struct OpenMeteoWeatherServiceTests {

    @Test func buildsRequestWithExpectedQuery() async throws {
        let session = URLProtocolStub.session(returning: Fixture.data("forecast_success"), status: 200)
        _ = try await OpenMeteoWeatherService(session: session).forecast(for: .saoPaulo)

        let url = try #require(URLProtocolStub.lastRequest?.url)
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        #expect(items.contains(URLQueryItem(name: "timezone", value: "auto")))
        #expect(items.contains(URLQueryItem(name: "current_weather", value: "true")))
    }

    @Test(arguments: [404, 500, 503])
    func nonSuccessStatusMapsToDomainError(status: Int) async {
        let session = URLProtocolStub.session(returning: Data(), status: status)
        await #expect(throws: WeatherDataError.noWeatherDataAvailable) {
            try await OpenMeteoWeatherService(session: session).forecast(for: .saoPaulo)
        }
    }
}
```

**Snapshot das views SwiftUI:**
```swift
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
@Suite(.snapshots(record: .missing))
struct WeatherScreenSnapshotTests {

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func loaded(style: UIUserInterfaceStyle) {
        let view = WeatherScreen(viewModel: .preview(.loaded(.fixture)))
        assertSnapshot(of: view,
                       as: .image(layout: .device(config: .iPhoneSe),
                                  traits: .init(userInterfaceStyle: style)))
    }

    @Test func errorStateWithLargestDynamicType() {
        let view = WeatherScreen(viewModel: .preview(.failed(.noWeatherDataAvailable)))
        assertSnapshot(of: view,
                       as: .image(layout: .device(config: .iPhoneSe),
                                  traits: .init(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)))
    }
}
```
> Snapshots mudam de acordo com a versão do iOS e do simulador. Grave e compare **sempre no mesmo destino** (ex.: iPhone 17 / iOS 26, definido no CI). O iOS 16 é validado pelos UI tests, não por snapshot.

**UI test (XCUITest) com Page Object:**
```swift
final class WeatherFlowUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testShowsForecastOnLaunch() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-scenario", "success"]
        app.launch()

        let screen = WeatherScreenPage(app: app)
        XCTAssertTrue(screen.currentTemperature.waitForExistence(timeout: 5))
        XCTAssertEqual(screen.forecastRows.count, 7)
    }

    @MainActor
    func testRetryAfterNetworkError() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-scenario", "networkError"]
        app.launch()

        let screen = WeatherScreenPage(app: app)
        XCTAssertTrue(screen.retryButton.waitForExistence(timeout: 5))
        screen.retryButton.tap()
        XCTAssertTrue(screen.retryButton.exists)   // cenário continua falhando
    }

    @MainActor
    func testAccessibilityAudit() throws {
        guard #available(iOS 17, *) else { throw XCTSkip("Audit exige runtime iOS 17+") }
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-scenario", "success"]
        app.launch()
        try app.performAccessibilityAudit()
    }
}
```
> **Permissão de localização real:** no `LocationPermissionUITests`, use `app.resetAuthorizationStatus(for: .location)` antes do `launch()` e toque no alerta do sistema pelo `XCUIApplication(bundleIdentifier: "com.apple.springboard")`. Esse é o único teste que passa pelo `LocationProvider` real, e mesmo nele o clima continua vindo do mock.

### 7.5 Test Plan (`RainStorm.xctestplan`)

| Configuração | Idioma / Região | Opções | Uso |
|--------------|-----------------|--------|-----|
| `pt-BR` (padrão) | Português / Brasil | Code coverage no target `RainStorm`, ordem aleatória | Todo PR |
| `en-US` | English / United States | — | Todo PR (garante o String Catalog) |
| `Sanitizers` | pt-BR | **Thread Sanitizer** + Main Thread Checker | Nightly (pega erros de concorrência que o Swift 6 não pega) |
| `Location-SP` | pt-BR | Location simulation: GPX de São Paulo | UI test de permissão |

Opções gerais: **Test Repetition Mode = Retry on Failure (até 3)** só no nightly, para identificar testes instáveis sem mascarar falhas nos PRs, e **Execution Order = Random**.

### 7.6 Destinos de execução

| Destino | Por quê |
|---------|---------|
| **iPhone 8 / iOS 16.x** (simulador) | Aparelho e sistema mínimos suportados. Baixar o runtime em *Xcode ▸ Settings ▸ Components*; se o Xcode 26 não oferecer o 16.x, usar um **iPhone 8 físico** para a regressão manual antes de cada release |
| **iPhone SE (3ª geração)** | Tela 4,7" com hardware mais recente |
| **iPhone 17 / iOS 26** | Sistema atual; destino dos snapshots e do audit de acessibilidade |

### 7.7 CI

```bash
xcodebuild test \
  -project RainStorm.xcodeproj \
  -scheme RainStorm \
  -testPlan RainStorm \
  -only-test-configuration pt-BR \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.0' \
  -destination 'platform=iOS Simulator,name=iPhone 8,OS=16.4' \
  -resultBundlePath build/TestResults.xcresult

xcrun xccov view --report --only-targets build/TestResults.xcresult
```
- **PR:** unitário + integração + snapshot (tags permitem filtrar: `-only-testing` por suíte).
- **Nightly:** tudo, incluindo UI, performance, acessibilidade e `Sanitizers`.
- Plataforma: **Xcode Cloud** (integrado ao App Store Connect) ou GitHub Actions com runner macOS + Xcode 26.
- Anexar o `.xcresult` como artefato para ver falhas de snapshot e UI com imagens.

### 7.8 Metas de cobertura

| Área | Meta |
|------|------|
| `Domain/` + `Services/` | ≥ 90% |
| `WeatherViewModel` | ≥ 90% (todos os estados) |
| Views SwiftUI | Cobertas por snapshot (todos os estados), sem meta de linha |
| App total | ≥ 70% |

### 7.9 Ordem de implementação dos testes (junto com a migração)

1. **Testes de caracterização primeiro.** Antes de mexer no código, escrever testes que fixam o comportamento atual de `WeatherCodeMapper`, decode do `OpenMeteoResponse`/`dailyForecasts` e `WeatherRequest.url`. Os testes que expõem bugs (`Conversions` Int, `YYYY`, arrays desalinhados) entram marcados com `.bug(...)` e `withKnownIssue { }`, para documentar o bug sem quebrar o build.
2. **TDD na camada de domínio.** `WeatherServicing`, `LocationProviding` e `WeatherViewModel` nascem com testes. Ao corrigir cada bug, trocar o `withKnownIssue` por um `#expect` normal.
3. **Snapshots ao criar cada view SwiftUI** (etapa B). A mesma fixture alimenta preview e snapshot.
4. **UI tests na troca do ciclo de vida** (etapa C). Os UI tests garantem que nada se perdeu ao remover storyboards e `SceneDelegate`.
5. **Nightly com sanitizers, performance e acessibilidade** por último, depois que o app estiver todo em SwiftUI.

---

## 8. Roteiro de Migração

Cada fase é um PR independente, termina com o build verde e com os testes da fase passando.

| Fase | Entrega | Testes da fase | Risco |
|------|---------|----------------|-------|
| 1 | Xcode 26 recommended settings + target **16.0** em todos os targets + `@main` + `RainStorm.xctestplan` | Infra de Swift Testing rodando (1 teste trivial) | Baixo |
| 2 | Remover código morto | **Caracterização** (seção 7.9, item 1) | Baixo |
| 3 | Swift 6: `SWIFT_STRICT_CONCURRENCY = targeted` → corrigir → `complete` | Suíte da fase 2 continua verde | Médio |
| 4 | Etapa A: `WeatherServicing`, `LocationProvider`, `WeatherViewModel` (`ObservableObject`), correções de dados (6.5) | Unit + integração (TDD) | Médio |
| 5 | `FormatStyle` / `Measurement` (corrige `YYYY`, remove `Conversions`) | `FormattingTests` | Baixo |
| 6 | Etapa B: views SwiftUI em `UIHostingController` | Snapshots + previews | Médio |
| 7 | Etapa C: `RainStormApp`, remover storyboards/`SceneDelegate`/`AppDelegate` | UI tests (XCUITest) | Médio |
| 8 | Swift Charts, String Catalog, Privacy Manifest | Config `en-US` + audit de acessibilidade + nightly no CI | Baixo |
| 9 | Widget "Clima atual" (seção 11): `Shared/`, App Group, `hourly` na API, extensão WidgetKit | Timeline builder, store, loader, sync, snapshots por família, deep link | Médio |

> Com o SwiftUI, a seção 5.6 (UIKit moderno) **não entra no roteiro**.

---

## 9. Riscos e Cuidados

- **SwiftUI no iOS 16.0–16.3 tem bugs conhecidos** em `List` e `NavigationStack`. Por isso os UI tests rodam no runtime 16.x e há regressão manual num iPhone 8 físico antes de cada release.
- **`ObservableObject` redesenha a view inteira** a cada `@Published`. Com um único `state` isso não é problema; evite espalhar vários `@Published` que mudam juntos.
- **Swift 6 pode gerar muitos erros de isolamento** nos delegates do `CLLocationManager`. Use `nonisolated` + `Task { @MainActor in ... }`, ou ative o default isolation `MainActor` (seção 4).
- **Snapshots são frágeis entre versões de iOS.** Grave em um único destino fixo e regrave de propósito ao atualizar o Xcode.
- **UI tests nunca acessam a rede real.** Sempre `-ui-testing` + cenário mockado; a Open-Meteo pode ficar lenta ou fora do ar e derrubar o CI.
- **Mocks só no build DEBUG** (`#if DEBUG`), para não vazarem para a App Store.
- **Remover código morto** (blocos comentados com a resposta da DarkSky, `WeekDayRepresentable` sem uso) antes da fase 3 para reduzir o ruído.

---

## 11. Widget "Clima atual" (WidgetKit)

O primeiro card do app, na tela inicial (pequeno e médio) e na tela de bloqueio (circular, retangular e inline), todos disponíveis desde o iOS 16.

### 11.1 Arquitetura

- **`Shared/`** é compilado nos dois targets (XcodeGen: `sources: [RainStormWidget, Shared]`). Domínio, serviço, formatadores, cores e as views do widget ficam lá. Assim os snapshot tests do app renderizam exatamente o que a extensão desenha. Só o app tem `LocationProviding`, o ViewModel e as telas.
- **Fluxo:** o app, depois de cada busca bem-sucedida, chama `WidgetSyncing.didFetch(_:deviceCoordinate:)`. Isso grava o snapshot e (só se a posição for real) a coordenada no App Group, e depois chama `WidgetCenter.reloadTimelines(ofKind:)`. O widget (`WeatherWidgetLoader`) busca na rede com essa coordenada. Se não houver rede, usa o cache, marcado como desatualizado. Se não houver cache, mostra "Abra o RainStorm…".
- **Timeline:** `WeatherTimelineBuilder` é uma função pura. Gera uma entrada para agora e uma por hora futura do `hourly` (até 6), cada uma com a mínima e a máxima do dia daquela hora no fuso do local, e usa a política `.after(agora + 60 min)`. Se o iOS adiar a recarga, as entradas horárias mantêm o widget coerente por até 6 h.
- **API:** `hourly=temperature_2m,weathercode,windspeed_10m,is_day&forecast_hours=12`. O `hourly` é decodificado com `decodeIfPresent` e validado com as mesmas regras do `daily`.

### 11.2 Decisões e desvios em relação ao plano

| Plano | Implementado | Motivo |
|-------|-------------|--------|
| `didFetch(snapshot, coordinate:, source:)` | `didFetch(_:deviceCoordinate:)` (`nil` = fallback) | `LocationSource` está no `WeatherViewModel`, que é só do app, e o `Shared` não pode referenciá-lo |
| `XCUIApplication().open(url)` no UI test | `XCUIDevice.shared.system.open(url)` | `app.open` passava **sem** o `CFBundleURLTypes`: ele entrega a URL direto ao app. `system.open` roteia pelo esquema, como o SpringBoard |
| Ícones do catálogo em todas as famílias | SF Symbols na tela de bloqueio (`WeatherCodeMapper.systemImageName`) | O `accessoryInline` só desenha SF Symbols |
| "15,9 °C" em todas as famílias | "16°C" no gauge circular (`compactTemperature`) | Não cabe em 72 pt |
| Layout fixo | `ViewThatFits` completo → compacto (pequeno e médio) | O snapshot em XXXL cortava a data e o vento |
| Cache sem limite de idade | Cache válido por 12 h (`maxCacheAge`); depois, `.unavailable` | Revisão final: um dia sem rede mostraria o clima de ontem como se fosse atual |
| "Agora" do cache = observação salva | "Agora" do cache = hora prevista mais recente ≤ agora | Revisão final: um cache das 08:00 mostrava a temperatura da manhã às 14:20 |
| `URLSession.shared` (timeout de 60 s) | `URLSession.widget` (15 s por requisição, 20 s no total) | Revisão final: numa rede ruim a extensão podia ser encerrada antes do fallback para o cache |
| — | `nonisolated(unsafe)` na captura do `completion` do provider | O SDK não marca o `completion` como `@Sendable`, e o WidgetKit aceita chamá-lo de qualquer thread |

### 11.3 Verificação manual pendente

- Adicionar os widgets pequeno, médio e de bloqueio no iPhone 17 / iOS 26.5 (scheme `RainStormWidget`) e conferir a paridade com o card, Dark Mode e pt-BR/en-US.
- Modo avião: o widget deve mostrar o cache com "Atualizado às …", e o toque deve abrir o app e recarregar.
- Primeiro build em aparelho: registrar o App Group `group.com.guimagames.ios.RainStorm` no Developer Portal.

---

## 10. Fontes

**Mercado**
- [Apple Reveals How Many iPhones Were Running iOS 26 Before WWDC — MacRumors (jun/2026)](https://www.macrumors.com/2026/06/09/ios-26-adoption-stats-wwdc/)
- [iOS 26 adoption grows, but still lags slightly behind iOS 18 — 9to5Mac](https://9to5mac.com/2026/06/10/ios-26-adoption-grows-but-still-lags-slightly-behind-ios-18/)
- [Apple Reveals How Many iPhones Are Running iOS 26 — MacRumors (fev/2026)](https://www.macrumors.com/2026/02/13/apple-shares-ios-26-adoption-stats/)
- [Mobile & Tablet iOS Version Market Share Brazil — StatCounter](https://gs.statcounter.com/ios-version-market-share/mobile-tablet/brazil)
- [Apple iOS mobile market share Brazil, by version — Statista](https://www.statista.com/statistics/1418537/apple-ios-market-share-by-version-brazil/)
- [iOS Versions Market Share in 2026 — TelemetryDeck](https://telemetrydeck.com/survey/apple/iOS/majorSystemVersions/)
- [iOS version usage — iOS Ref](https://iosref.com/ios-usage)

**SwiftUI e testes**
- [Swift Testing — Apple Developer](https://developer.apple.com/documentation/testing)
- [Migrating a test from XCTest — Apple Developer](https://developer.apple.com/documentation/testing/migratingfromxctest)
- [Improving code assessment by organizing tests into test plans — Apple Developer](https://developer.apple.com/documentation/xcode/organizing-tests-to-improve-feedback)
- [performAccessibilityAudit — Apple Developer](https://developer.apple.com/documentation/xctest/xcuiapplication/performaccessibilityaudit(for:_:))
- [Migrating from the Observable Object protocol to the Observable macro — Apple Developer](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
- [Swift Charts — Apple Developer](https://developer.apple.com/documentation/charts)
- [swift-snapshot-testing — Point-Free](https://github.com/pointfreeco/swift-snapshot-testing)
