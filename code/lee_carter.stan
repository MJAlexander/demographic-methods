data {
  int<lower=0> nages;
  int<lower=0> nyears;
  int<lower=0> nprojyears;
  int<lower=0> D[nyears, nages];
  real<lower=0> P[nyears, nages];
  vector[nages] ax;
  vector[nages] bx;
  vector[nyears] kt;
}
parameters {
  //real<lower=0> sigma;
  real<lower=0> sigma_k;
  vector[nyears] mu_k;
}
transformed parameters{
  real log_mu[nyears, nages];
  
  for(y in 1:nyears){
    for(x in 1:nages){
        log_mu[y,x] = ax[x] + bx[x]*mu_k[y];
    }
  }
}
model {
  for(y in 1:nyears){
    for(x in 1:nages){
      D[y,x] ~ poisson(P[y,x]*exp(log_mu[y,x])); 
    }
  }

  
  // model for kts
  kt ~ normal(mu_k, 0.01);
  
  //RW2 model on mu_k
  mu_k[1] ~ normal(0, sigma_k);
  mu_k[2:nyears] ~ normal(mu_k[1:(nyears - 1)], sigma_k);
  mu_k[3:nyears] ~ normal(2*mu_k[2:(nyears - 1)]-mu_k[1:(nyears - 2)], sigma_k);
  sigma_k ~ normal(0,1);
  
}
generated quantities{
  vector[nprojyears] mu_k_proj;
  real log_mu_proj[nprojyears, nages];
  
  mu_k_proj[1] = normal_rng(2*mu_k[nyears]- mu_k[nyears-1], sigma_k);
  mu_k_proj[2] = normal_rng(2*mu_k_proj[1]-mu_k[nyears], sigma_k);
  for(p in 3:nprojyears){
    mu_k_proj[p] = normal_rng(2*mu_k_proj[p-1]-mu_k_proj[p-2], sigma_k);
  }
  
  for(p in 1:nprojyears){
    for(x in 1:nages){
      log_mu_proj[p, x] = ax[x] + bx[x]* mu_k_proj[p];
    }
  }
}