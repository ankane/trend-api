library(forecast)
library(padr)
library(anytime)
library(stringi)

source("helpers.R")

#* Log some information about the incoming request
#* @filter logger
function(req) {
  cat(req$REQUEST_METHOD, req$PATH_INFO, "\n")
  plumber::forward()
}

#* Anomaly detection
#* @serializer unboxedJSON
#* @post /anomalies
function(res, series=NULL, frequency=NULL) {
  r <- prepareSeries(series, frequency)
  anomalies <- list()
  if (!r$bad) {
    ts <- r$ts
    outliers <- tsoutliers(ts)

    # get largest differences in replacement, and only use those
    max_anoms <- floor(0.1 * length(ts))
    diff <- abs(ts[outliers$index] - outliers$replacement)
    df <- data.frame(ds=r$ds[outliers$index], diff=diff)
    df <- df[diff > 0, ]
    df <- head(df[order(-df$diff), ], max_anoms)

    anomalies <- formatTime(df$ds)
  }
  list(anomalies=I(anomalies))
}

#* Forecast
#* @serializer unboxedJSON
#* @post /forecast
function(res, series=NULL, frequency=NULL, count=10) {
  r <- prepareSeries(series, frequency)
  ts <- r$ts

  preds <- NULL
  if (r$bad) {
    # use mean
    preds <- rep(mean(ts, na.rm=TRUE), count)
  } else {
    res <- tsclean(ts)
    res <- res %>% tbats(use.box.cox=TRUE, use.trend=TRUE, use.damped.trend=FALSE)
    res <- res %>% forecast(h=count)
    preds <- res$mean

    if (!any(series < 0)) {
      preds <- pmax(preds, 0)
    }
  }

  dates <- tail(seq(tail(r$ds, 1), by=r$interval, length.out=count + 1), count)
  forecast <- split(round(preds, 10), formatTime(dates))

  list(forecast=forecast)
}

#* Correlation
#* @serializer unboxedJSON
#* @post /correlation
function(res, series=NULL, series2=NULL, frequency=NULL) {
  r <- prepareSeries(series, frequency)
  r2 <- prepareSeries(series2, r$frequency, name="series2")

  if (r$interval != r2$interval) {
    stop("[400] Invalid parameters: series and series2 have different intervals")
  }

  if (!identical(r$ds, r2$ds)) {
    stop("[400] Invalid parameters: series and series2 must have identical keys")
  }

  corr <- ccf(r$ts, r2$ts, lag.max=0, pl=FALSE)

  list(correlation=corr$acf[1])
}
