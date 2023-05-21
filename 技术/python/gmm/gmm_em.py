import time
a = time.time()

# 生成GMM数据
import numpy as np
def generate_data(n,p):
    '''
    计算服从均值为mean，协方差为cov的多元正态分布的数据
    :param mean: 均值
    :param cov: 协方差
    :return: x，服从GMM分布的数据
    '''
    global x
    global rho_list # 变量相关性
    global cov_list
    global mean_list
    global w
    
    w = np.random.random(p)
    w = w/sum(w)
    xx = list()
    rho_list = list()
    cov_list = list()
    mean_list = list()
    for i in range(p):
        #n_samples = int(n*w[i])
        n_samples = int(round(n*w[i]))
        mean = np.random.random(p)
        rho = np.random.random()
        cov = np.diag(np.repeat(1-rho,p))+rho
        temp = np.random.multivariate_normal(mean,cov,n_samples)
        rho_list.append(rho)
        cov_list.append(cov)
        mean_list.append(mean)
        xx.append(temp)
    x = np.vstack((xx[0],xx[1]))
    for i in range(2,p):
        x = np.vstack((x,xx[i]))
    return x
        
if __name__ == '__main__':
    p = 5    # 五维数据
    n = 500 # 数据长度
    generate_data(n,p) 
    
    


# 计算高斯函数
def Gaussian(data,mean,cov):
    dim = np.shape(cov)[0]      # 计算维度
    covdet = np.linalg.det(cov) # 计算|cov|
    covinv = np.linalg.inv(cov) # 计算cov的逆
    if covdet==0:               # 以防行列式为0
        covdet = np.linalg.det(cov+np.eye(dim)*0.01)
        covinv = np.linalg.inv(cov+np.eye(dim)*0.01)
    m = data - mean
    z = -0.5 * np.dot(np.dot(m, covinv),m)    # 计算exp()里的值
    # 返回概率密度值
    return 1.0/(np.power(np.power(2*np.pi,dim)*abs(covdet),0.5))*np.exp(z)


def GMM(data,K):
    N = data.shape[0]
    dim = data.shape[1]

    convs=[0]*dim
    means=[0]*dim

    # 初始方差等于整体data的方差
    for i in range(K):
        convs[i]=np.cov(data.T)+np.random.random()/10
        means[i]=np.mean(data.T)+np.random.random()/10
        #convs[i]=np.diag(np.repeat(1-0.1,p))+0.1
        #means[i]=np.random.random(dim)+np.mean(data.T)       
        # means[i]=np.zeros(dim)
    
    pis = [1.0/K] * K
    gammas = [np.zeros(K) for i in range(N)]
    
    loglikelyhood = 0
    oldloglikelyhood = 1

    while np.abs(loglikelyhood - oldloglikelyhood) > 0.0001:
        oldloglikelyhood = loglikelyhood
        
        # E步
        for i in range(N):
            res = [pis[k] * Gaussian(data[i],means[k],convs[k]) for k in range(K)]
            sumres = np.sum(res)
            for k in range(K):      # gamma表示第n个样本属于第k个混合高斯的概率
                gammas[i][k] = res[k] / sumres
        # M步
        for k in range(K):
            Nk = np.sum([gammas[n][k] for n in range(N)])  # N[k] 表示N个样本中有多少属于第k个高斯
            pis[k] = 1.0 * Nk/N
            means[k] = (1.0/Nk)*np.sum([gammas[n][k] * data[n] for n in range(N)],axis=0)
            xdiffs = data - means[k]
            convs[k] = (1.0/ Nk)*np.sum([gammas[n][k]* xdiffs[n].reshape(dim,1) * xdiffs[n] for  n in range(N)],axis=0)
        # 计算最大似然函数
        loglikelyhood = np.sum([np.log(np.sum([pis[k] * Gaussian(data[n], means[k], convs[k]) for k in range(K)])) for n in range(N)])
        print(loglikelyhood)
    print("pi :" ,end = " ")
    print(pis)
    print("means :")
    for item in means:
        print(item)
    print("convs :")
    for item in convs:
        print(item)
    print("loglikelyhood :",end = " ")
    print (loglikelyhood)
    
GMM(x,5)

b = time.time()
print(b-a)
