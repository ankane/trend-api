prepareSeries <- function(series, frequency, name="series") {
  if (is.null(series)) {
    stop(paste("[400] Missing parameter:", name))
  }

  # remove null values
  series[sapply(series, is.null)] <- NULL

  if (length(series) < 10) {
    stop(paste("[400] Invalid parameter:", name, "must have at least 10 data points"))
  }

  tryCatch({
    ds <- names(series)
    y <- as.numeric(series)

    if (any(nchar(ds) > 10)) {
      ds <- anytime(ds)
    } else {
      ds <- anydate(ds)
    }
  }, error=function(err) {
    stop(paste("[400] Missing parameter:", name))
  })

  if (any(duplicated(ds)) || any(sapply(ds, is.na))) {
    stop(paste("[400] Missing parameter:", name))
  }

  data <- data.frame(ds=ds, y=y)
  data <- data[order(data$ds), ]

  interval <- get_interval(data$ds)

  if (is.null(frequency)) {
    if (interval == "day") {
      frequency <- 7
    } else if (interval == "month") {
      frequency <- 12
    } else {
      frequency <- detectFrequency(data$y)
    }
  }

  data <- data %>% pad(interval=interval)

  if (nrow(data) > 1000) {
    stop(paste("[400] Invalid parameter: computed", name, "can have a max of 1000 data points"))
  }

  missing_p <- sum(is.na(data$y)) / nrow(data)
  if (missing_p > 0.2) {
    stop(paste("[400] Invalid parameter:", name, "missing too much data"))
  }

  ts <- ts(data$y, frequency=frequency)

  bad <- FALSE
  tryCatch({
    ts <- na.interp(ts)
  }, warning=function(w) {
    bad <<- TRUE
  })

  list(ts=ts, ds=data$ds, bad=bad, interval=interval, frequency=frequency)
}

detectFrequency <- function(y) {
  if (is.constant(y)) {
    1
  } else {
    findfrequency(y)
  }
}

formatTime <- function(ds) {
  r <- rfc3339(ds)
  stri_sub(r[nchar(r) == 24], -2, -3) <- ":"
  r
}
