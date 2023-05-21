## generate data which follow GMM
set.seed(2019)
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
    mean      <- rnorm(p,0,1)+5*p
    sigma_mat <- function(p,rho){diag(1-rho,p,p)+rho}
    sigma     <- sigma_mat(p,rho[i])
    temp      <- MASS::mvrnorm(n_samples, mean, sigma)
    x         <- rbind(x,temp)
    means     <- c(means,list(mean))
    sigmas    <- c(sigmas,list(sigma))
  }
  return(list(x = x[1:n,],w = w,means = means,sigma = sigmas,rho = rho))
}

result <- gene_data(100,5)

## CGS for DPMM

# get the number of k cluster
get_n_k_i <- function(arr,i,k){
  if(i<1){
    return(0)
  }
  else{
    mat <-  as.data.frame(table(arr[1:i]),names=c("Var1","Freq"))
    res <- mat$Freq[mat$Var1==k]
    return(res)
  }
}

crp_cgs <- function(x,T = 10,alpha = 1){
  
  # xi: data
  # zi: clusters
  
  # caculate Phi_n_k
  Phi <- function(nk){
    munk <- (lambda*mu0+nk*x_bar)/(lambda+nk)
    #res  <- Phi0+lambda*mu0%*%t(mu0)-(lambda+nk)*(munk)%*%t(munk)
    res  <- Phi0
    for(j in ns_k){res = res+as.matrix(t(x[ns_k,]))%*%as.matrix(x[ns_k,])}
    return(res)
  }
  
  # initial value
  N = dim(x)[1]
  D = dim(x)[2]
  K = 20
  Z      <- sample(c(1:K),size = N,replace = TRUE)
  mat    <-  as.data.frame(table(Z),names=c("Var1","Freq"))
  lambda <- 10
  nu     <- 10
  mu0    <- rep(10,D)
  Phi0   <- diag(10,D)
  p2old = rep(1,K+1)
  
  for (t in 1:T) {
    print(t)
    for (i in 1:N) {
      cat("i=",i,"\n")
      p1 = c()
      p2 = c()
      p3 = c()
      K = length(unique(Z))
      for (k in 1:K) {
        ns_k = which(Z==k)
        x_bar = colMeans(x[ns_k,])
        # p(z_i=k|z_-i,alpha) == p1
        p1tem = get_n_k_i(Z,i-1,k)/(i-1+alpha)
        p1=c(p1,p1tem)
        #cat("p1=",p1,"\n")
        
        # p(x_i|x_-i,k,Phi) == p2
        nk = get_n_k_i(Z,i,k)
        p2tem = pi^(-D/2)*((lambda+nk)/(lambda+nk-1))^(-D/2)*
          det(Phi(nk))^(-(nu+nk)/2)/det(Phi(nk-1))^(-(nu+nk-1)/2)*
          gamma((nu+nk)/2)/gamma((nu+nk-D)/2)
        p2 = c(p2,log(p2tem)*p2old[k])
        #cat("p2=",p2,"\n")
        
        # p(z_i=k|z_-i,x_i,alpha,Phi)== p3
        p3tem = p1[k] * p2[k]
        p3 = c(p3,p3tem)
        #cat("p3=",p3,"\n")
        
      }
      p1tem =alpha/(i-1+alpha)
      p1 = c(p1,log(p1tem))
      p2tem = pi^(-D/2)*((lambda+1)/(lambda+1-1))^(-D/2)*
        det(Phi(1))^(-(nu+1)/2)/det(Phi(1-1))^(-(nu+1-1)/2)*
        gamma((nu+1)/2)/gamma((nu+1-D)/2)
      p2 = c(p2,log(p2tem)*p2old[K+1])
      p3tem = p1[K+1]* p2[K+1]
      p3 = c(p3,p3tem)
    }
    p2old <- p2
    print(p3)
    print(K)
    p3[is.finite(p3)==FALSE]=0
    print(p3)
    Z[i] <- sample(1:(K+1),size = 1,prob = p3)
    print(Z)
  }
  return(Z)
}

res <- crp_cgs(result$x)
