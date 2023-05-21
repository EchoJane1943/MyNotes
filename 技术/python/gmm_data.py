import pandas as pd
import numpy as np

np.random.seed(2019)

def gene_data(k,n_samples):
    global x
    global y
    x = list()
    w = np.random.random(k)
    w = w/sum(w)

    miu =  np.zeros(k)
    sigma = np.zeros(k)
    beta = np.zeros(k)
    for i in range(k):
        miu[i] = np.random.random()
        sigma[i] = np.random.random()
        beta[i] = np.random.random()*100
        temp = np.random.normal(miu[i],sigma[i],size = n_samples)
        x.append(temp)
    x = pd.DataFrame(x).T 
    a = np.dot(x,beta)+np.random.random()
    y = np.zeros(len(a))
    for i in range(len(a)):
        y[i] = 1 if a[i] > 0 else 0
    return x,y
# c = a if a>b else b
result = gene_data(6,5000)


import seaborn as sns
%matplotlib inline

sns.distplot(x[0],color="g")
sns.distplot(x[1],color="b")
sns.distplot(x[2],color="r")
sns.distplot(x[3],color="y")
sns.distplot(x[4],color="c")
sns.distplot(x[5],color="m")
