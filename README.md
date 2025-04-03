# Trend

An anomaly detection and forecasting API. Get started quickly with state-of-the-art algorithms.

## Installation

### Docker

An image is available on [Docker Hub](https://hub.docker.com/r/ankane/trend/). Run:

```sh
docker run -ti -p=8000:8000 ankane/trend
```

### Non-Docker

Download the latest code

```sh
git clone https://github.com/ankane/trend-api.git
cd trend-api
```

Install [Jetpack](https://github.com/ankane/jetpack) and run:

```sh
Rscript -e 'jetpack::install()'
```

And start the server

```sh
Rscript server.R
```

## Anomaly Detection

Detect anomalies in a time series.

- Works with dates and times
- Accounts for seasonality and trend
- Robust to missing values

The current version uses STL with [multiple seasonal components](https://otexts.org/fpp2/complexseasonality.html#stl-with-multiple-seasonal-periods) for decomposition.

```http
POST /anomalies HTTP/1.1
Content-Type: application/json

{
  "series": {
    "2025-01-01": 150,
    "2025-01-02": 125,
    "2025-01-03": 133
  }
}
```

Returns JSON structured like this:

```json
{
  "anomalies": [
    "2025-01-10",
    "2025-01-13"
  ]
}
```

## Forecasting

Get future predictions for a time series.

- Works with dates and times
- Accounts for seasonality and trend
- Robust to missing values
- No need to remove outliers beforehand

The current version uses [TBATS](https://robjhyndman.com/papers/ComplexSeasonality.pdf) for predictions.

```http
POST /forecast HTTP/1.1
Content-Type: application/json

{
  "series": {
    "2025-01-01": 150,
    "2025-01-02": 125,
    "2025-01-03": 133
  },
  "count": 3
}
```

Returns JSON structured like this:

```json
{
  "forecast": {
    "2025-03-01": 137.5,
    "2025-03-02": 122.9,
    "2025-03-03": 144.1
  }
}
```

If you get a [flat or linear forecast](https://robjhyndman.com/hyndsight/flat-forecasts/), this is expected. It means no seasonality is detected in the series.

## Correlation (Experimental)

Get the correlation between two time series.

The current version uses [normalized cross correlation](https://en.wikipedia.org/wiki/Cross-correlation#Time_series_analysis).

```http
POST /correlation HTTP/1.1
Content-Type: application/json

{
  "series": {
    "2025-01-01": 150,
    "2025-01-02": 125,
    "2025-01-03": 133
  },
  "series2": {
    "2025-01-01": 150,
    "2025-01-02": 176,
    "2025-01-03": 145
  }
}
```

Returns JSON structured like this:

```json
{
  "correlation": 0.95
}
```

## Errors

The API uses HTTP status codes to indicate errors.

Code | Description
--- | ---
400 | There’s an issue with the request parameters
500 | There’s an issue with the server


The body will contain details about the specific error.

```json
{
  "error": "Missing parameter: series"
}
```

## Clients

A client library is available for [Ruby](https://github.com/ankane/trend).

Here’s an example with jQuery:

```js
var series = {}, i, date, data;
for (i = 1; i < 30; i++) {
  date = new Date(2025, 1, i);
  series[date.toISOString()] = date.getDay();
}
data = {series: series};

$.post({
  url: "http://localhost:8000/forecast",
  data: JSON.stringify(data),
  dataType: "json",
  contentType: "application/json",
  success: function(resp) { console.log(resp); }
});
```

## Credits

A special thanks to [Rob J Hyndman](https://robjhyndman.com) for his incredible work on forecasting. Learn more about the topic from his [free online book](https://otexts.org/fpp2/).

## History

View the [changelog](https://github.com/ankane/trend-api/blob/master/CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/trend-api/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/trend-api/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
