# Plano de Migração: DarkSky para Open-Meteo (Projeto Existente)

## Visão Geral

Substituir a API DarkSky pela **Open-Meteo API** no projeto UIKit existente, mantendo a arquitetura MVVM atual. Apenas os arquivos de Models, Configuration e parte dos ViewModels precisarão ser ajustados.

## Open-Meteo API

**Endpoint:** `https://api.open-meteo.com/v1/forecast`

**Vantagens:**
- Gratuita e sem necessidade de API key
- Dados em Celsius e km/h por padrão (elimina conversões)
- Resposta JSON simples e bem estruturada

**URL de exemplo:**
```
https://api.open-meteo.com/v1/forecast?latitude=37.33&longitude=-122.00&current_weather=true&daily=temperature_2m_max,temperature_2m_min,weathercode,windspeed_10m_max&timezone=auto
```

## Arquivos Modificados

| Arquivo | Ação |
|---------|------|
| `Configuration.swift` | Atualizar baseUrl para Open-Meteo |
| `DarkSkyResponse.swift` → `OpenMeteoResponse.swift` | Substituir modelo de resposta |
| `WeatherRequest.swift` | Ajustar construção da URL com query parameters |
| `WeatherData.swift` | Atualizar protocolo para novo modelo |
| `RootViewModel.swift` | Ajustar decoder para novo JSON |
| `DayViewModel.swift` | Ajustar propriedades (temperatura agora disponível) |
| `WeekViewModel.swift` | Ajustar tipo do forecast |
| `WeekDayViewModel.swift` | Ajustar para novo modelo |
| `UIImage.swift` | Mapear weathercode (números) para ícones |

## Mapeamento de Dados

### Clima Atual
| DarkSky | Open-Meteo |
|---------|------------|
| `currently.temperature` | `current_weather.temperature` |
| `currently.windSpeed` (mph) | `current_weather.windspeed` (km/h) |
| `currently.icon` (string) | `current_weather.weathercode` (int) |
| `currently.time` (unix) | `current_weather.time` (ISO string) |

### Previsão Diária
| DarkSky | Open-Meteo |
|---------|------------|
| `daily.data[].temperatureMin` | `daily.temperature_2m_min[]` |
| `daily.data[].temperatureMax` | `daily.temperature_2m_max[]` |
| `daily.data[].icon` | `daily.weathercode[]` |
| `daily.data[].windSpeed` | `daily.windspeed_10m_max[]` |
| `daily.data[].time` | `daily.time[]` |

### Mapeamento de Weathercode para Ícones

```swift
// weathercode -> nome do ícone existente
0: "clear-day"           // Céu limpo
1-3: "cloudy"            // Parcialmente nublado
45, 48: "fog"            // Nevoeiro
51-67: "rain"            // Chuva/Chuvisco
71-77: "snow"            // Neve
80-82: "rain"            // Pancadas de chuva
95-99: "rain"            // Tempestade
```

## Nota sobre Conversões

Open-Meteo retorna temperatura em **Celsius** e velocidade do vento em **km/h** por padrão. As funções de conversão em `Conversions.swift` não serão mais necessárias para esses campos, simplificando os ViewModels.

---
*Plano criado em: Janeiro 2026*
