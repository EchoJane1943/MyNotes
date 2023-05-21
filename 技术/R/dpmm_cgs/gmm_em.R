# 生产多维高斯混合分布数据
set.seed(410)

gene_data <- function(n,p){
  # n: length of data
  # p: dimention of x
  # rho: Covariance matrix correlation
  rho       <- runif(p,0,1)
  w         <- DIRECT::rDirichlet(1,rep(1,p)) # weights of every distribution
  x         <- data.frame()
  means     <- list()
  sigmas    <- list()
  for (i in (1:p)) {
    n_samples <- ceiling(n*w[i])
    mean      <- rnorm(p,0,1)
    sigma_mat <- function(p,rho){diag(1-rho,p,p)+rho}
    sigma     <- sigma_mat(p,rho[i])
    temp      <- MASS::mvrnorm(n_samples, mean, sigma)
    x         <- rbind(x,temp)
    means     <- c(means,list(mean))
    sigmas    <- c(sigmas,list(sigma))
  }
  return(list(x = x[1:n,],w = w,means = means,sigma = sigmas,rho = rho))
}

result <- gene_data(1000,5)

# EM算法
# https://www.jianshu.com/p/8acf6ec8193e

# 计算多元高斯分布概率值
Gaussian <- function(data,mean,cov){
  data = as.matrix(data)
  mean = as.numeric(mean)
  cov  = as.matrix(cov)
  
  dime   <- dim(cov)[1]
  covdet <- det(cov)
  covinv <- solve(cov)
  if (covdet == 0){
    covdet = det(cov+diag(dime)*0.01)
    covinv = solve(cov+diag(dime)*0.01)}
  m  = as.matrix(data - mean)
  z1 = -0.5*(m %*% covinv %*% t(m))
  z2 = ((((2*pi)^dime)*abs(covdet))^0.5)
  return(exp(z1)/z2)
}

gmm <- function(data,k){
  n     = dim(data)[1]
  # 设定初始迭代值（均值，协方差）
  convs = list()
  means = list()
  temp1 <- cov(data)
  temp2 <- sapply(data,mean)
  for (i in 1:k){
    convs[[i]] <- temp1 + rnorm(1,0,0.1)
    means[[i]] <- temp2 + rnorm(1,0,0.1)
  }
  # 初始权重
  pis    <- rep(1.0/k,k)
  gammas <- matrix(rep(0,k*n),n,k)
  
  loglikelihood    <- 0
  oldloglikelihood <- 1
  res   = matrix(rep(0,k*n),n,k)
  
  count = 0
  while (abs(loglikelihood-oldloglikelihood) > 0.0001 & count < 10){
    count = count +1
    cat("count = ",count,"  ","loglikelihood = ",loglikelihood,"\n")
    oldloglikelihood = loglikelihood
    # E step 求解gammas[n,k],即第n个样本落在第k个高斯分布的概率，对数似然
    for (i in 1:n) {
      for (j in 1:k){res[i,j] = pis[j]*Gaussian(data[i,],means[[j]],convs[[j]])}
      sumres <- sum(res[i,])
      for (j in 1:k){gammas[i,j] = res[i,j]/sumres}
    }
    # M step update parameters
    for (j in 1:k){
      Nj     <- sum(gammas[,j])
      pis[j] <- 1.0*Nj/n
      
      summea <- 0
      for (i in 1:n) {summea <- summea +  gammas[i,j]*data[i,]}
      means[j] <- list(summea/Nj)
      xdiffs   <- list()
      for (i in 1:n) {xdiffs[[i]] <- data[i,] - summea/Nj}
      sumcov   <- 0
      for (i in 1:n) {sumcov <- sumcov +  gammas[i,j]*t(as.matrix(xdiffs[[i]]))%*%as.matrix(xdiffs[[i]])}
      convs[j] <- list((1.0/Nj)*sumcov)
    }
    loglikelihood <- 0
    for (i in 1:n){
      temp <- 0
      for (j in 1:k){
        temp <- temp + pis[j]*Gaussian(data[i,],means[[j]],convs[[j]])
      }
      loglikelihood <- loglikelihood + log(temp)
    }
  } 
  return(list(loglikelihood = loglikelihood,pis = pis,means = means,convs = convs,gammas = gammas))
}

a = Sys.time()
resofgmm <- gmm(result$x,5)
print(Sys.time()-a)

# 数据分割及采样
mysample <- function(lst1,lst2){
  x = lst1$x
  k = dim(x)[2]
  gammas <- lst2$gammas
  newx = list()
  newgammas <- ismax(gammas)
  for (i in 1:k){
    xi = x[newgammas[,i]==1,]
    newx = c(newx,list(xi))
  }
  return(newx)
}

# 定义判断最大值矩阵
ismax <- function(d){
  l = dim(d)[1]
  p = dim(d)[2]
  for (i in 1:l) {
    ma = max(d[i,])
    for (j in 1:p) {d[i,j] <- if (d[i,j] == ma) TRUE else FALSE}
  }
  return(d)
}

res = mysample(result,resofgmm)

