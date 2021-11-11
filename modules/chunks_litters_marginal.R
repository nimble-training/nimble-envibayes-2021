## @knitr dbetabin

dbetabin <- nimbleFunction(
    run = function(x = double(0), alpha = double(0), beta = double(0),
                   size = double(0), log = integer(0, default = 0)) {
        
        returnType(double(0))
        logProb <- lgamma(size+1) - lgamma(x+1) - lgamma(size - x + 1) +
            lgamma(alpha + beta) - lgamma(alpha) - lgamma(beta) +
            lgamma(x + alpha) + lgamma(size - x + beta) - lgamma(size + alpha + beta)
        if(log) return(logProb)
        else return(exp(logProb))
    })

rbetabin <- nimbleFunction(
    run = function(n = integer(0), alpha = double(0), beta = double(0),
                   size = double(0)) {
        
        returnType(double(0))
        if(n != 1) print("rbetabin only allows n = 1; using n = 1.")
        p <- rbeta(1, alpha, beta)
        return(rbinom(1, size = size, prob = p))
    })

## @knitr littersMarg-code

littersMargCode <- nimbleCode({
  for (i in 1:G) {
     for (j in 1:N) {
     	 # (marginal) likelihood (data model)
        r[i,j] ~ dbetabin(a[i], b[i], n[i,j])
     }
     # prior for hyperparameters
     a[i] ~ dgamma(1, .001)
     b[i] ~ dgamma(1, .001)
   }
})

## @knitr littersMarg-model

G <- 2
N <- 16
n <- matrix(c(13, 12, 12, 11, 9, 10, 
              9, 9, 8, 11, 8, 10, 13, 10, 12, 9, 10, 9, 10, 5, 9, 9, 13, 
              7, 5, 10, 7, 6, 10, 10, 10, 7), nrow = 2)
r <- matrix(c(13, 12, 12, 11, 9, 10, 9, 9, 8, 10, 8, 9, 
     12, 9, 11, 8, 9, 8, 9, 4, 8, 7, 11, 4, 4, 5, 5, 3, 7, 3, 7, 0), 
     nrow = 2)
              
littersConsts <- list(G = G, N = N, n = n)
littersData <- list(r = r)
littersInits <- list( a = c(2, 2), b=c(2, 2) )

littersMargModel <- nimbleModel(littersMargCode, 
          data = littersData, constants = littersConsts, inits = littersInits)

## @knitr littersMarg-model-compile

cLittersMargModel <- compileNimble(littersMargModel)

