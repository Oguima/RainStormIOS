# RainStorm iOS

Aplicativo iOS para consulta de previsão do tempo, desenvolvido em Swift com arquitetura MVVM.

## Sobre o Projeto

RainStorm é um app de previsão meteorológica que exibe:
- **Clima atual**: temperatura, condição do tempo, velocidade do vento
- **Previsão semanal**: temperatura mínima/máxima para os próximos dias

## Serviço Meteorológico

### Open-Meteo API

O projeto utiliza a [Open-Meteo API](https://open-meteo.com/) como fonte de dados meteorológicos.

**Características:**
- ✅ Gratuita para uso não-comercial
- ✅ Sem necessidade de API key ou registro
- ✅ Dados em Celsius e km/h por padrão
- ✅ Alta disponibilidade e precisão
- ✅ Código aberto

**Endpoint utilizado:**
```
https://api.open-meteo.com/v1/forecast
```

**Parâmetros:**
| Parâmetro | Descrição |
|-----------|-----------|
| `latitude` | Latitude da localização |
| `longitude` | Longitude da localização |
| `current_weather` | Retorna dados do clima atual |
| `daily` | Campos da previsão diária |
| `timezone` | Fuso horário (auto = automático) |
| `hourly` | Campos da previsão horária (timeline do widget) |
| `forecast_hours` | Quantidade de horas a partir da hora atual (12) |

**Exemplo de requisição:**
```
https://api.open-meteo.com/v1/forecast?latitude=-23.55&longitude=-46.63&current_weather=true&daily=temperature_2m_max,temperature_2m_min,weathercode,windspeed_10m_max&timezone=auto&hourly=temperature_2m,weathercode,windspeed_10m,is_day&forecast_hours=12
```

**Dados retornados:**
- `current_weather.temperature` - Temperatura atual (°C)
- `current_weather.windspeed` - Velocidade do vento (km/h)
- `current_weather.weathercode` - Código da condição climática
- `daily.temperature_2m_min/max` - Temperaturas mínima/máxima
- `daily.weathercode` - Códigos de condição para cada dia
- `hourly.*` - Próximas 12 horas, começando na hora atual, no fuso local (opcional no decode)

### Mapeamento de Weather Codes

Os códigos numéricos da Open-Meteo são convertidos para ícones:

| Código | Condição | Ícone |
|--------|----------|-------|
| 0 | Céu limpo | clear-day |
| 1-3 | Parcialmente nublado | cloudy |
| 45, 48 | Nevoeiro | fog |
| 51-67 | Chuva/Chuvisco | rain |
| 71-77 | Neve | snow |
| 80-82 | Pancadas de chuva | rain |
| 95-99 | Tempestade | rain |

## Arquitetura

SwiftUI (ciclo de vida `App`) + MVVM, iOS 16+, Swift 6 com isolamento padrão `MainActor`:

```
Shared/                             # Compilado no app E no widget (módulos separados)
├── Configuration.swift             # URL da API, localização padrão, deep link, cores
├── Domain/
│   ├── WeatherSnapshot.swift       # Modelo de UI (Codable, com previsão horária)
│   ├── WeatherSnapshot+Sample.swift # Dados de exemplo (placeholder do widget e base do `fixture`)
│   ├── WeatherTimelineBuilder.swift # Snapshot + agora → entradas do widget + próxima recarga
│   ├── WeatherDataError.swift
│   ├── WeatherCodeMapper.swift     # WMO code → ícone / SF Symbol / descrição localizada
│   └── WeatherFormatter.swift      # Measurement + Date.FormatStyle (pt-BR, °C/°F, km/h/mph)
├── Services/
│   ├── WeatherServicing.swift      # Protocolo + OpenMeteoWeatherService (async, typed throws)
│   ├── OpenMeteoResponse.swift     # DTO com validação no decode
│   ├── WeatherRequest.swift
│   ├── SharedWeatherStore.swift    # App Group: última coordenada real + último clima
│   ├── WidgetSyncing.swift         # App → widget: grava e chama reloadTimelines
│   └── WeatherWidgetLoader.swift   # Rede → cache → "abra o app"
├── WidgetUI/                       # Views do widget por família (testadas por snapshot)
└── Resources/                      # Localizable.xcstrings, WeatherIcons.xcassets

RainStorm/                          # App
├── App/
│   ├── RainStormApp.swift          # @main + escolha de dependências (real × mock)
│   └── Debug/                      # Mocks e fixtures (só em DEBUG): previews, testes, UI tests
├── Services/LocationProviding.swift # Wrapper async sobre CLLocationManager (só o app pede localização)
├── Features/Weather/               # WeatherViewModel (ObservableObject) + views SwiftUI + Swift Charts
└── Resources/                      # AppIcon, InfoPlist.xcstrings, PrivacyInfo.xcprivacy

RainStormWidget/                    # Extensão WidgetKit
├── RainStormWidgetBundle.swift     # @main
├── CurrentWeatherWidget.swift      # StaticConfiguration + famílias + previews
├── WeatherTimelineProvider.swift   # Casca sobre o WeatherWidgetLoader
└── Info.plist, entitlements, PrivacyInfo.xcprivacy
```

## Widget "Clima atual"

O primeiro card do app (data, hora, ícone, temperatura, descrição e vento) na tela inicial e na tela de bloqueio, com os mesmos formatadores, ícones, cores AA e traduções.

| Família | Conteúdo |
|---------|----------|
| Pequeno | Ícone, temperatura, descrição, mínima–máxima do dia |
| Médio | Réplica do card: data, hora, descrição, vento, ícone, temperatura e faixa do dia |
| Circular (bloqueio) | `Gauge` da mínima à máxima com a temperatura no centro |
| Retangular (bloqueio) | Ícone + temperatura, descrição, vento |
| Inline (bloqueio) | "☁ 15,9 °C · Nublado" |

- **Localização:** o widget não pede permissão. Usa a última coordenada **real** que o app salvou no App Group `group.com.guimagames.ios.RainStorm` (o fallback de São Paulo nunca sobrescreve uma posição real); sem nenhuma, usa São Paulo.
- **Timeline:** uma entrada para agora e uma por hora futura (até 6), cada uma com a faixa do dia daquela hora; nova busca após 60 min (`WeatherTimelinePolicy.standard`).
- **Sem rede:** mostra o último clima em cache (até 12 h; "agora" vem da hora prevista) com "Atualizado às 19:45". Sem cache válido: "Abra o RainStorm para carregar o clima". A busca do widget tem timeout de 15 s.
- **Toque:** abre `rainstorm://weather`, que volta ao app e recarrega (e o app atualiza o widget).
- **Rodar:** scheme `RainStormWidget` (pergunta o app hospedeiro). Na primeira execução num aparelho, a assinatura automática precisa registrar o App Group no Developer Portal (time `HB54SB8ZZ9`).

## Requisitos

- iOS 16.0+ (iPhone 8 / X em diante)
- Xcode 26+
- Swift 6
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Como compilar

O `RainStorm.xcodeproj` é **gerado** a partir do `project.yml` pelo [XcodeGen](https://github.com/yonaskolb/XcodeGen). O repositório só traz os schemes e o `Package.resolved`: sem rodar `xcodegen`, a pasta existe, mas o Xcode não abre o projeto.

```bash
brew install xcodegen                              # uma vez por máquina
git clone https://github.com/Oguima/RainStormIOS.git
cd RainStormIOS
xcodegen                                           # gera o RainStorm.xcodeproj
open RainStorm.xcodeproj
```

No Xcode, escolha o scheme:

| Scheme | Para quê |
|--------|----------|
| `RainStorm` | App e testes (⌘U roda o Test Plan `RainStorm`) |
| `RainStormWidget` | Roda o widget direto no simulador (o Xcode pergunta o app hospedeiro) |

Pela linha de comando:

```bash
xcodebuild build -project RainStorm.xcodeproj -scheme RainStorm \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

**Rode `xcodegen` de novo sempre que:**
- fizer `git pull` ou trocar de branch (outra pessoa pode ter adicionado ou movido arquivos);
- adicionar, remover ou mover arquivos (inclusive fixtures `.json` e imagens), ou mudar build settings no `project.yml`.

Se o build falhar com *"cannot find … in scope"* ou *"file not found"* logo depois de um pull, quase sempre é o projeto desatualizado: rode `xcodegen`.

Não edite o `.xcodeproj` pelo Xcode: as alterações somem na próxima geração. Mudanças de configuração vão no `project.yml`.

**Aparelho físico:** no primeiro build, a assinatura automática precisa registrar o App Group `group.com.guimagames.ios.RainStorm` (usado pelo widget) no Developer Portal do time `HB54SB8ZZ9`. No simulador não é preciso.

## Testes

| Camada | Framework | Onde |
|--------|-----------|------|
| Unitários e integração | Swift Testing | `RainStormTests/Domain`, `Services`, `Features`, `Widget` |
| Snapshot | swift-snapshot-testing | `RainStormTests/Snapshots` (referências em `__Snapshots__/`, gravadas no iPhone 17 / iOS 26.5) |
| UI, permissão de localização, deep link do widget, acessibilidade, performance | XCUITest | `RainStormUITests` |

Test Plans:
- **`RainStorm`** (padrão, ⌘U): configurações pt-BR e en-US, cobertura de código, ordem aleatória. Pula `LaunchPerformanceTests`.
- **`Nightly`**: tudo, mais Thread Sanitizer e *retry on failure* (até 3x) para detectar testes instáveis.

```bash
# Dia a dia
xcodebuild test -project RainStorm.xcodeproj -scheme RainStorm -testPlan RainStorm \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5'

# Nightly
xcodebuild test -project RainStorm.xcodeproj -scheme RainStorm -testPlan Nightly \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5'
```

- **Regravar snapshots de propósito:** em `WeatherSnapshotTests` / `WidgetSnapshotTests`, troque `.snapshots(record: .missing)` por `.all`, rode, revise as imagens e volte para `.missing`.
- **Rodar o app com dados falsos:** launch arguments `-ui-testing -scenario success|loading|locationDenied|offline|serviceUnavailable|invalidData`.

## Permissões

O app pede acesso à localização **durante o uso** (`NSLocationWhenInUseUsageDescription`, traduzido em `InfoPlist.xcstrings`). Se o usuário negar, o app mostra a previsão de São Paulo com um aviso e um atalho para os Ajustes. O widget não pede permissão: reaproveita a última coordenada salva pelo app. Os `PrivacyInfo.xcprivacy` do app e do widget declaram a localização aproximada enviada à Open-Meteo e o uso de `UserDefaults` do App Group (motivo `1C8F.1`).

## Histórico de Alterações

### Setembro 2026
- **Widget "Clima atual"** (WidgetKit, iOS 16): pequeno, médio e tela de bloqueio (circular, retangular, inline); código compartilhado em `Shared/`, App Group, cache offline e deep link `rainstorm://weather`
- **iOS 16 + Swift 6 + Xcode 26**: target mínimo de 13.0 para 16.0 (maior alcance no Brasil com toolchain atual)
- **Migração para SwiftUI**: remoção de UIKit, storyboards, `AppDelegate`/`SceneDelegate`
- `async/await`, typed throws, strict concurrency `complete`
- Localização pt-BR/en com String Catalogs; °C/°F e km/h/mph conforme o locale
- Gráfico semanal com Swift Charts; Dark Mode, Dynamic Type e auditoria de acessibilidade
- Suíte de testes: Swift Testing, snapshots, XCUITest e Test Plans
- Correções: datas no fuso do local consultado, validação do JSON (arrays desalinhados e datas inválidas), bug do ano "YYYY", contraste da cor da marca

### Janeiro 2026
- **Migração de API**: Substituição do DarkSky (descontinuado) pelo Open-Meteo
- Remoção da necessidade de API key
- Dados já retornados em Celsius/km/h (sem conversões)
- Adição do campo de temperatura atual (antes indisponível)

## Documentação

Para mais detalhes sobre a migração, consulte:
- [Plano de Migração Open-Meteo](Docs/MigrationPlan_OpenMeteo.md)
- [Análise de Target, Migração SwiftUI e Plano de Testes](Docs/TargetUpgrade_Analysis.md)

## Licença

Projeto desenvolvido para fins de estudo.

---
*Desenvolvido por Guima Games*
