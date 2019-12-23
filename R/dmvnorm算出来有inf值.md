## mvtnorm包中的dmvnorm函数算出来有inf值是为什么

该函数的定义是给定均值向量和协方差矩阵，返回多元正太分布的概率密度。

These functions provide the density function and a random number generator for the multivariate normal distribution with mean equal to mean and covariance matrix sigma.


类比一维正态分布
```
> dnorm(1, mean = 0, sd = 1, log = FALSE)
[1] 0.2419707
> 1/sqrt(2*pi*1)*exp(-(1/2))
[1] 0.2419707
```

```
dmvnorm(x, mean = rep(0, p), sigma = diag(p), log = FALSE)

x vector or matrix of quantiles. If x is a matrix, each row is taken to be a quantile. 
mean mean vector, default is rep(0, length = ncol(x)).
sigma covariance matrix, default is diag(ncol(x)).
log logical; if TRUE, densities d are given as log(d).
```

首先看一下源码：
```
> dmvnorm
function (x, mean = rep(0, p), sigma = diag(p), log = FALSE) 
{
    if (is.vector(x)) 
        x <- matrix(x, ncol = length(x))
    p <- ncol(x)
    if (!missing(mean)) {
        if (!is.null(dim(mean))) 
            dim(mean) <- NULL
        if (length(mean) != p) 
            stop("mean and sigma have non-conforming size")
    }
    if (!missing(sigma)) {
        if (p != ncol(sigma)) 
            stop("x and sigma have non-conforming size")
        if (!isSymmetric(sigma, tol = sqrt(.Machine$double.eps), 
            check.attributes = FALSE)) 
            stop("sigma must be a symmetric matrix")
    }
    dec <- tryCatch(chol(sigma), error = function(e) e)
    if (inherits(dec, "error")) {
        x.is.mu <- colSums(t(x) != mean) == 0
        logretval <- rep.int(-Inf, nrow(x))
        logretval[x.is.mu] <- Inf
    }
    else {
        tmp <- backsolve(dec, t(x) - mean, transpose = TRUE)
        rss <- colSums(tmp^2)
        logretval <- -sum(log(diag(dec))) - 0.5 * p * log(2 * 
            pi) - 0.5 * rss
    }
    names(logretval) <- rownames(x)
    if (log) 
        logretval
    else exp(logretval)
}
<bytecode: 0x7f8740efd188>
<environment: namespace:mvtnorm>
```
