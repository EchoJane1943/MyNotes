# 生成GMM
def generate_data(n,p):
    global x
    global rho_list
    global cov_list
    global mean_list
    global w
    
    w = np.random.random(p)
    w = w/sum(w)
    x = list()
    rho_list = list()
    cov_list = list()
    mean_list = list()
    for i in range(p):
        n_samples = int(n*w[i])
        mean = np.random.random(p)
        rho = np.random.random()
        cov = np.diag(np.repeat(1-rho,p))+rho
        temp = np.random.multivariate_normal(mean,cov,n_samples)
        rho_list.append(rho)
        cov_list.append(cov)
        mean_list.append(mean)
        x.append(temp)
    return x
        
if __name__ == '__main__':
    p = 5
    n = 5000
    generate_data(n,p) 
