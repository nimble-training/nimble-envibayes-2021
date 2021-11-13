# nimble-envibayes-2021

Materials for NIMBLE (virtual) tutorial for the enviBayes section of ISBA 

Time: 11 am - 1 pm, Eastern U.S. time, Thursday November 18.

[2021-11-11: Content is mostly stable, except for module 7.]

All materials for the workshop will be here. If you're familiar with Git/GitHub, you already know how to get all the materials on your computer. If you're not, simply click [here](https://github.com/nimble-training/nimble-envibayes-2021/archive/main.zip).

## Summary

Programming with hierarchical statistical models: Using the flexible NIMBLE system for MCMC and more

NIMBLE (r-nimble.org) is a system for fitting and programming with hierarchical models in R that builds on (a new implementation of) the BUGS language for declaring models. NIMBLE provides analysts with a flexible system for using MCMC, sequential Monte Carlo, MCEM, and other techniques on user-specified models. It provides developers and methodologists with the ability to write algorithms in an R-like syntax that can be easily disseminated to users. C++ versions of models and algorithms are created for speed, but these are manipulated from R without any need for analysts or algorithm developers to program in C++. While analysts can use NIMBLE as a nearly drop-in replacement for WinBUGS or JAGS, NIMBLE provides enhanced functionality in a number of ways.

This workshop will demonstrate how one can use NIMBLE to:
 - flexibly specify an MCMC for a specific model, including choosing samplers and blocking approaches (and noting the potential usefulness of this for teaching);
 - tailor an MCMC to a specific model using user-defined distributions, user-defined functions, and vectorization;
 - write your own MCMC sampling algorithms and use them in combination with samplers from NIMBLE's library of samplers;
 - develop and disseminate your own algorithms, building upon NIMBLE's existing algorithms; and
 - use specialized model components such as Dirichlet processes, conditional auto-regressive (CAR) models, and reversible jump for variable selection.
 
## Preparation

[Get started here](https://htmlpreview.github.io/?https://github.com/nimble-training/nimble-envibayes-2021/blob/main/overview.html) with logistical information and an outline of the workshop content. Links to all the modules appear at the bottom of the document.

The tutorial will assume familiarity with hierarchical models and basic principles of MCMC. 

Given we only have two hours, we'll go through the introductory material quickly, so you might want to look through Modules 1-2 on your own in advance. In particular, if you're not familiar with writing models in the model language used in BUGS, JAGS, and NIMBLE, I recommend you take some time to look through Module 2.

## Installing NIMBLE

Ideally you'll have installed NIMBLE in advance so that you can follow along in a hands-on fashion. However, given this is a short tutorial, there won't be much time for hands-on work, so you'll be able to follow along without having NIMBLE installed.

NIMBLE is an R package on CRAN, so in general it will be straightforward to install as with any R package, but you do need a compiler and related tools on your system.  

In summary, here are the steps.

1. Install compiler tools on your system. [https://r-nimble.org/download](https://r-nimble.org/download) has more details on how to install *Rtools* on Windows and how to install the command line tools of *Xcode* on a Mac. Note that if you have packages requiring a compiler (e.g., *Rcpp*) on your computer, you should already have the compiler tools installed.

2. Install the *nimble* package from CRAN in the usual fashion for an R package. More details (including troubleshooting tips) can also be found in Section 4 of the [NIMBLE manual](https://r-nimble.org/html_manual/cha-installing-nimble.html).

3) To test that things are working please run the following code  in R:

```
library(nimble)
code <- nimbleCode({
  y ~ dnorm(0,1)
})
model <- nimbleModel(code)
cModel <- compileNimble(model)
```

If that runs without error, you're all set. If not, please see the troubleshooting tips and email me directly if you can't get things going. 
