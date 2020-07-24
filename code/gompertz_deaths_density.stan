data {
  int<lower=0> nages;
  int<lower=0> ages[nages];
  int y[nages];
  real log_D;
}
parameters {
  real<lower=0.01, upper = 0.25> beta;
  real<lower=60, upper = 100> M;
}
transformed parameters{
  real log_dx[nages];
  real log_lx[nages];
  real log_hx[nages];
  
  //Note if you want dx to be a density, need to normalize
  //real denom[nages];
  //real log_denom[nages];
  
  
  for(x in 1:nages){
      log_hx[x] = log(beta*exp(beta*(ages[x] - M)));
      log_lx[x] = -exp(-beta*M)*(exp(beta*ages[x])-1);
      //denom[x] = exp(-exp(-beta*M)*(exp(beta*ages[1]) - 1)) - exp(-exp(-beta*M)*(exp(beta*ages[nages]) - 1));
      //log_denom[x] = log(denom[x]);
      log_dx[x] = log_hx[x]+ log_lx[x]; //- log_denom[x];
  }

  
}
model {
  y ~ poisson_log(log_D+to_vector(log_dx));
  
  //priors
  beta ~ normal(0.01,1);
  M ~ uniform(60,100);
  
}
generated quantities{

}