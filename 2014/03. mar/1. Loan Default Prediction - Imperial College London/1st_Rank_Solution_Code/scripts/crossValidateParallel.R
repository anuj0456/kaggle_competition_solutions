crossValidate = function(input, target, train.model, predict.model, k, returnFits, packages, cores) {
  
  ## create folds and forecast draft ##
  l = c(1:length(input[,1]))
  forecast = l
  folds = createFolds(l, k , list = TRUE, returnTrain = FALSE)
  
  ## create cluster ##
  cl = makeCluster(rep("localhost",cores), type="SOCK")
  registerDoSNOW(cl)
  
  ## train models and do prediction ##
  models.and.forecasts = foreach(i = 1:k, .packages = packages) %dopar% {
    
    temp.fold = folds[[i]]
    
    input.train = as.data.frame(input[-temp.fold,])
    input.test = as.data.frame(input[temp.fold,])
    
    target.train = target[-temp.fold]
    target.test = target[temp.fold]
    
    fit = train.model(input.train, target.train, i)   
    
    fold.forecast = predict.model(fit, input.test, i)
    
    if(returnFits == T){
      return(list(model = fit, forecast = fold.forecast))
    }
    else{
      return(list(forecast = fold.forecast))
    }
  }
  
  ## stop cluster ##
  stopCluster(cl)
  
  
  ## merge out-of-sample predictions ##  
  for(i in 1:k){
    forecast[folds[[i]]] = models.and.forecasts[[i]]$forecast
  }
  
  ## collect all models in list ##  
  if(returnFits == T){
    models = list(1:k)
    
    for(i in 1:k){
      models[[i]] = models.and.forecasts[[i]]$model
    }
    
    cv = list(models = models, forecast = forecast)
  }
  else
    cv = list(forecast = forecast)
  
  return(cv)  
}