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

O projeto segue o padrão **MVVM** (Model-View-ViewModel):

```
RainStorm/
├── Application Delegate/
├── Configuration/
│   ├── Configuration.swift      # URL base da API
│   └── Styles.swift             # Cores e fontes
├── Models/
│   ├── OpenMeteoResponse.swift  # Modelo de resposta da API
│   └── WeatherRequest.swift     # Construção de URLs
├── Protocols/
│   └── WeatherData.swift        # Protocolos de dados
├── Utils/
│   ├── Conversions.swift        # Conversões de unidades
│   └── WeatherCodeMapper.swift  # Mapeamento de códigos
├── Extensions/
│   └── UIImage.swift            # Ícones do clima
└── View Controllers/
    ├── Root View Controller/
    │   └── View Models/
    │       └── RootViewModel.swift
    └── Weather View Controller/
        ├── Day View Controller/
        │   └── View Models/
        │       └── DayViewModel.swift
        └── Week View Controller/
            └── View Models/
                ├── WeekViewModel.swift
                └── WeekDayViewModel.swift
```

## Requisitos

- iOS 13.0+
- Xcode 11.2+
- Swift 5.0+

## Permissões

O app solicita acesso à localização do usuário para exibir o clima da região atual. Configure no `Info.plist`:

- `Privacy - Location When In Use Usage Description`
- `Privacy - Location Always and When In Use Usage Description`

## Histórico de Alterações

### Janeiro 2026
- **Migração de API**: Substituição do DarkSky (descontinuado) pelo Open-Meteo
- Remoção da necessidade de API key
- Dados já retornados em Celsius/km/h (sem conversões)
- Adição do campo de temperatura atual (antes indisponível)

## Documentação

Para mais detalhes sobre a migração, consulte:
- [Plano de Migração](Docs/MigrationPlan_OpenMeteo.md)

## Licença

Projeto desenvolvido para fins de estudo.

---
*Desenvolvido por Guima Games*
