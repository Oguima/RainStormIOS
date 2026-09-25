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

**Exemplo de requisição:**
```
https://api.open-meteo.com/v1/forecast?latitude=-23.55&longitude=-46.63&current_weather=true&daily=temperature_2m_max,temperature_2m_min,weathercode,windspeed_10m_max&timezone=auto
```

**Dados retornados:**
- `current_weather.temperature` - Temperatura atual (°C)
- `current_weather.windspeed` - Velocidade do vento (km/h)
- `current_weather.weathercode` - Código da condição climática
- `daily.temperature_2m_min/max` - Temperaturas mínima/máxima
- `daily.weathercode` - Códigos de condição para cada dia

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
RainStorm/
├── App/
│   ├── RainStormApp.swift          # @main + escolha de dependências (real × mock)
│   ├── Configuration.swift         # URL da API, localização padrão, cores
│   └── Debug/                      # Mocks e fixtures (só em DEBUG): previews, testes, UI tests
├── Domain/
│   ├── WeatherSnapshot.swift       # Modelo de UI
│   ├── WeatherDataError.swift
│   ├── WeatherCodeMapper.swift     # WMO code → ícone / descrição localizada
│   └── WeatherFormatter.swift      # Measurement + Date.FormatStyle (pt-BR, °C/°F, km/h/mph)
├── Services/
│   ├── WeatherServicing.swift      # Protocolo + OpenMeteoWeatherService (async, typed throws)
│   ├── LocationProviding.swift     # Wrapper async sobre CLLocationManager
│   ├── OpenMeteoResponse.swift     # DTO com validação no decode
│   └── WeatherRequest.swift
├── Features/Weather/               # WeatherViewModel (ObservableObject) + views SwiftUI + Swift Charts
└── Resources/                      # Assets, Localizable/InfoPlist.xcstrings, PrivacyInfo.xcprivacy
```

## Requisitos

- iOS 16.0+ (iPhone 8 / X em diante)
- Xcode 26+
- Swift 6
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Projeto (XcodeGen)

O `RainStorm.xcodeproj` é **gerado** a partir do `project.yml`. Depois de adicionar, remover ou mover arquivos, ou de mudar build settings:

```bash
xcodegen
```

Não edite o `.xcodeproj` à mão: as alterações são perdidas na próxima geração.

## Testes

| Camada | Framework | Onde |
|--------|-----------|------|
| Unitários e integração | Swift Testing | `RainStormTests/Domain`, `Services`, `Features` |
| Snapshot | swift-snapshot-testing | `RainStormTests/Snapshots` (referências em `__Snapshots__/`, gravadas no iPhone 17 / iOS 26.5) |
| UI, permissão de localização, acessibilidade, performance | XCUITest | `RainStormUITests` |

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

- **Regravar snapshots de propósito:** em `WeatherSnapshotTests`, troque `.snapshots(record: .missing)` por `.all`, rode, revise as imagens e volte para `.missing`.
- **Rodar o app com dados falsos:** launch arguments `-ui-testing -scenario success|loading|locationDenied|offline|serviceUnavailable|invalidData`.

## Permissões

O app pede acesso à localização **durante o uso** (`NSLocationWhenInUseUsageDescription`, traduzido em `InfoPlist.xcstrings`). Se o usuário negar, o app mostra a previsão de São Paulo com um aviso e um atalho para os Ajustes. O `PrivacyInfo.xcprivacy` declara a localização aproximada enviada à Open-Meteo.

## Histórico de Alterações

### Setembro 2026
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
