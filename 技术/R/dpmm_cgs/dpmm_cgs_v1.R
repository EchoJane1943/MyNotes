## generate data which follow GMM

set.seed(2019)

gene_data <- function(n,p,K){
  # n: length of data
  # p: dimention of x
  # rho: Covariance matrix correlation
  rho       <- runif(K,0,1)
  w         <- DIRECT::rDirichlet(1,rep(1,K)) # weights of every distribution
  x         <- data.frame()
  means     <- list()
  sigmas    <- list()
  for (i in (1:K)) {
    n_samples <- ceiling(n*w[i])
    mean      <- rnorm(p,0,1)+10*p
    sigma_mat <- function(p,rho){diag(1-rho,p)+rho}
    sigma     <- sigma_mat(p,rho[i])
    temp      <- MASS::mvrnorm(n_samples, mean, sigma)
    x         <- rbind(x,temp)
    means     <- c(means,list(mean))
    sigmas    <- c(sigmas,list(sigma))
  }
  return(list(x = x[1:n,],w = w,means = means,sigma = sigmas,rho = rho))
}

result <- gene_data(100,2,3)

## GSDMM

# get the number of data points in k cluster N_{-i,k}
get_n_i_k <- function(arr,i,k){
  if(i<1){return(0)}
  else{
    mat <- as.data.frame(table(arr[-i]),names=c("Var1","Freq"))
    return(mat$Freq[mat$Var1==k])
  }
}

# define Z function
Z_func <- function(D,lambda,S,nu){
  p1 <- 2^((nu+1)*D/2)
  p2 <- pi^(D*(D+1)/4)
  p3 <- lambda^(-D/2)
  p4 <- det(S)^(-nu/2)
  p5 <- prod(unlist(lapply((nu+1-c(1:D))/2,gamma)))
  return(prod(p1,p2,p3,p4,p5))
}

crp_cgs <- function(x,T = 100,alpha = 10,K = 5){
  
  # xi: data
  # zi: clusters
  
  # caculate Phi_n_k
  Phi <- function(nk){
    x_bar = colMeans(x[ns_k,])
    munk <- (lambda*mu0+nk*x_bar)/(lambda+nk)
    res  <- Phi0+lambda*(mu0%*%t(mu0))-(lambda+nk)*(munk%*%t(munk))
    for(j in ns_k){res = res+as.matrix(t(x[ns_k,]))%*%as.matrix(x[ns_k,])}
    return(res)
  }
  
  # initial values
  N = dim(x)[1]
  D = dim(x)[2]
  
  lambda <- 0.1
  nu     <- -1
  mu0    <- colMeans(x)
  Phi0   <- diag(0.1,D)

  
  # inicialize z_i for y_i to a random table
  Z <- sample(c(1:K),size = N,replace = TRUE) 

  for (t in 1:T) {
    cat("t=",t,"\n")
    for (i in 1:N) {
      cat("i=",i,"\n")
      # inicialize vector p 
      p1 = c() # prior
      p2 = c() # likelihood
      p3 = c() # post
      # update K & Z 
      K = length(unique(Z))
     
      for (k in 1:K) {
        ns_k = which(Z==k)
        x_bar = colMeans(x[ns_k,])
        # p(z_i=k|z_-i,alpha) == p1
        p1tem = get_n_i_k(Z,i,k)/(N-1+alpha)
        p1=c(p1,-log(p1tem))
        
        # p(x_i|x_-i,k,Phi) == p2
        nk = get_n_i_k(Z,length(Z)+1,k)
        p2tem = (2*pi)^(-D/2)*(Z_func(D,lambda+nk,Phi(nk),nu+nk)/Z_func(D,lambda+nk-1,Phi(nk-1),nu+nk-1))
        p2 = c(p2,-log(p2tem))
        #cat("p2=",p2,"\n")
        
        # p(z_i=k|z_-i,x_i,alpha,Phi)== p3
        p3tem = p1[k] + p2[k]
        p3 = c(p3,p3tem)
        # cat("p3=",p3,"\n")
      }
      p1tem =alpha/(N-1+alpha)
      p1 = c(p1,-log(p1tem))
      
      p2tem = (2*pi)^(-D/2)*(Z_func(D,lambda+1,Phi(1),nu+1)/Z_func(D,lambda,Phi0,nu))
      p2 = c(p2,-log(p2tem))
      
      p3tem = p1[K+1] + p2[K+1]
      p3 = c(p3,p3tem)
    }
    
    p3[is.finite(p3)== FALSE | is.na(p3)== TRUE] = 0
    print(p3)
    Z[i] <- sample(1:(K+1),size = 1,prob = p3)
    
    print(Z)
    print(length(unique(Z)))
    
  }
  return(Z)
}

res <- crp_cgs(result$x,T = 100)
