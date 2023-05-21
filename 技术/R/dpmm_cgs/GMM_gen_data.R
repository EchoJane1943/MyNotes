# 生产多维高斯混合分布数据
set.seed(410)

gene_data <- function(n,p){
  # n: length of data
  # p: dimention of x
  # rho: Covariance matrix correlation
  rho       <- runif(p,0,1)
  sigma_mat <- function(p,rho){diag(1-rho,p,p)+rho}
  w         <- DIRECT::rDirichlet(1,rep(1,p)) # weights of every distribution
  x         <- data.frame()
  for (i in (1:p)) {
    n_samples <- ceiling(n*w[i])
    means     <- rnorm(p,0,1)
    sigma     <- sigma_mat(p,rho[i])
    temp      <- MASS::mvrnorm(n_samples, means, sigma)
    x         <- rbind(x,temp)
  }
  return(list(x = x[1:n,],w = w,means = means,sigma = sigma,rho = rho))
}

result <- gene_data(1000,7)
