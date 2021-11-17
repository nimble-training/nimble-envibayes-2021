---
title: "Highlights of NIMBLE tools"
subtitle: "enviBayes 2021 tutorial"
author: "NIMBLE Development Team"
output:
  html_document:
    code_folding: show
---




# Introduction

This module briefly covers highlights of various functionality in NIMBLE, namely:

 - Bayesian nonparametric mixture modeling (e.g., Dirichlet processes)
 - Reversible jump for variable selection
 - Conditional autoregressive (CAR) modeling
 - WAIC for model comparison/selection
 - calling external code (e.g., C++ or R) in models or algorithms
 - using sequential Monte Carlo

# BNP

Bayesian nonparametrics encompass:

 - Bayesian nonparametric mixture modeling using Dirichlet processes and related techniques
    - Useful for clustering and flexibly modeling distributions
 - Gaussian processes and related techniques
    - Useful for flexibly modeling functions

The latter are available indirectly by using the multivariate normal density.

The former are provided using NIMBLE's BNP functionality.

  - The basic idea is to model an unknown distribution as a mixture of an unknown number of component distributions (e.g., normal densities).
  - The Dirichlet process construction allows one to estimate the number of components rther than having to specify it in advance as with finite mixture models. 

# BNP - example

BNP mixture models can be used to directly model data or to model random effects. Here's an example of some code for modeling random effects:


```r
for(i in 1:n) {
    gamma[i] ~ dnorm(mu[i], var = tau[i]) # mixture of normal densities
    mu[i] <- muTilde[xi[i]]               # mean for component assigned to i'th study
    tau[i] <- tauTilde[xi[i]]             # variance for component assigned to i'th study
}
xi[1:nStudies] ~ dCRP(conc, size = n)     # cluster the gamma[i]'s into groups
```

A few comments:

 - Each random effect `gamma[i]` comes from one of the component mixture densities, determined by `xi[i]`.
 - The 'Chinese Restaurant Process' (`dCRP`) clusters the random effects and relates to the Dirichlet process specification.
 - Prior specification for the mixture component parameters can be tricky to do well.
 - NIMBLE assigns specialized samplers to `xi[1:n]`. 
 

# Reversible jump for variable selection

 - RJMCMC is a method for sampling across different models.
 - Specifically it is about sampling between different numbers of dimensions.
 - In full generality, RJ requires one to figure out a way to propose reasonable parameter values when moving between models with different numbers of parameters. Often hard!
 - RJ for variable selection is relatively simple.

RJ in NIMBLE turns off and on variables in regression-style models. This can be done:

  - explicitly using indicator variables that are the on-off switch or
  - implicitly.

# Reversible jump for variable selection

Here are some code snippets for use without an indicator variable:


```r
code <- nimbleCode({
   for(i in 1:n) 
      y[i] ~ dnorm(beta0 + beta1*x1[i] + beta2*x2[i], sd = sigma)
   ## other code omitted
})

model <- nimbleModel(code, data = data, constants = constants)
conf <- configureMCMC(model)
configureRJ(conf,
            targetNodes = 'beta2',
            priorProb = 0.5,
            control = list(mean = 0, scale = 1))
```

# WAIC

WAIC is a popular metric for comparing/selecting models. It has various advantages over DIC.

DIC drawbacks:

 - Limited theoretical justification
 - DIC values are different for different parameterizations of the same model
 - DIC is based on the posterior mean so full posterior not used 

WAIC tries to estimate the expected pointwise log predictive density for a new dataset, $\{\tilde{y}_i\}$:

$$ \sum_{i=1}^n E_{\tilde{y}}(\log p_{post}(\tilde{y}_i)) $$

Two quantities are used:

  1) Pointwise log predictive density in-sample: $\sum_{i=1}^n \log \left(\frac{1}{M} \sum_{j=1}^M p(y_i | \theta^{(j)}) \right)$
  2) An estimate of the effective number of parameters (number of unconstrained parameters)

The second piece adjusts for the bias from overfitting.

WAIC uses the full posterior, so does not rely on the plug-in predictive density as in DIC.

# WAIC variations

NIMBLE provides:

 - a default WAIC that treats each observation as independent and seeks to predict new observations
 - a WAIC that allows one to group observations (e.g., treating all observations from a single patient as an "observation")
 - a WAIC that seeks to predict new random effects by marginalizing over latent variables

Here's some syntax for the different WAIC variations:


```r
## Conditional WAIC without data grouping:
conf <- configureMCMC(Rmodel, enableWAIC = TRUE)

## Conditional WAIC with data grouping
conf <- configureMCMC(Rmodel, enableWAIC = TRUE, controlWAIC = list(dataGroups = groups))

## Marginal WAIC (predict new 'mu' values) with data grouping:
conf <- configureMCMC(Rmodel, enableWAIC = TRUE, controlWAIC =
        list(dataGroups = groups, marginalizeNodes = 'mu'))
```

# Conditional auto-regressive (CAR) models

CAR models allow one to represent latent processes on a grid, ofen in space or time.

 - The model is often written conditionally -- as the distribution of each location given the others.
 - This provides a convenient sampling strategy for each location given the others.
 - However, there are technical requirements that have to be satisfied for the joint distribution to be valid.

NIMBLE provides the improper CAR and proper CAR models using a joint specification :


```r
x[1:N] ~ dcar_normal(adjacencies, weights, number_locations, precision, c, zero_mean)
x[1:N] ~ dcar_proper(mu, C, adj, num, M, tau, gamma)
```

The underlying MCMC sampler cycles through each location in turn, using univariate samplers. 

In some cases joint sampling may work better (particularly to improve mixing of the CAR process hyperparameter), but this is not directly available in NIMBLE. You may want to consider [this recent work](https://osf.io/3ey65) for setting up the model jointly in Stan.

# Calling external code

You can call out to essentially arbitrary external code from within model code or nimbleFunctions. This allows you to:

 - embed arbitrary calculations in a model (e.g., some "black box" calculation)
 - use external code as part of an algorithm

The external code could be:

 - C/C++ (or a C/C++ wrapper to other languages)
     - use `nimbleExternalCall`
 - arbitrary R code beyond the R syntax that NIMBLE can compile
     - use `nimbleRcall`

# Calling external code - example


```r
Rquantile <- nimbleRcall(function(x = double(1), probs = double(1)) {},
          returnType = double(1), Rfun = 'quantile')
## The 'Rfun' could you be your own R function too
```




```r
demoCode <- nimbleCode({       
   for(i in 1:n)
         x[i] ~ dnorm(0,1)
   q[1:2] <- Rquantile(x[1:4], c(.025, .975))
})
n <- 100
demoModel <- nimbleModel(demoCode, constants = list(n = n),
                         inits = list(x = rnorm(n)))
```

```
## Defining model
```

```
## Building model
```

```
## Setting data and initial values
```

```
## Running calculate on model
##   [Note] Any error reports that follow may simply reflect missing values in model variables.
```

```
## Checking model sizes and dimensions
```

```r
CdemoModel <- compileNimble(demoModel)
```

```
## Compiling
##   [Note] This may take a minute.
##   [Note] Use 'showCompilerOutput = TRUE' to see C++ compilation details.
```

```r
CdemoModel$q
```

```
## [1] -1.0591061  0.9873164
```

For C++ code, you'll provide the compiled object file and a header file, and you'll need to give us some type information. See `help(nimbleExternalCall)`.

# Sequential Monte Carlo

NIMBLE is not just an MCMC engine. Its core idea is to make programming and sharing algorithms for hierarchical models easier.

We have a variety of sequential Monte Carlo (aka 'particle filtering') algorithms in the `nimbleSMC` package, including:

 - bootstrap filter
 - auxiliary particle filter
 - ensemble Kalman Filter
 - iterated filter 2 (IF2; useful for parameter estimation)

In addition you can use particle filters to integrate over latent states in an overall MCMC algorithm using particle MCMC. We provide:

 - particle MCMC for univariate parameters (`RW_PF`)
 - particle MCMC for vector parameters (`RW_PF_block`)


 
