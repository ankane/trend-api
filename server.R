library(plumber)

port <- Sys.getenv("PORT", unset="8000")
r <- plumb("app.R")
r$setErrorHandler(function(req, res, err){
  msg <- conditionMessage(err)
  if (startsWith(msg, "[400] ")) {
    msg <- substring(msg, 7)
    res$status <- 400
  } else {
    res$status <- 500
  }
  cat("ERROR:", msg, "\n")
  list(error=msg)
})
r$set404Handler(function(req, res){
  res$status <- 404
  list(error="Not found")
})
r$run(host="0.0.0.0", port=strtoi(port))
