data {
  int<lower=0> N;
  vector[N] x;
  vector[N] y;
}
parameters {
  real<lower=0, upper=1> alpha1;
  real<lower=0, upper=1> alpha2;
  real<lower=0, upper=1> alpha3;
  real<lower=0, upper=1> a1;
  real<lower=0, upper=1> a2;
  real<lower=0, upper=1> a3;
  real<lower=0, upper=1> c;
  real<lower=0> mu2;
  real<lower=0> mu3;
  real<lower=0, upper=1> gamma2;
  real<lower=0, upper=1> gamma3;
  real<lower=0> sigma;
}

model {
  // likelihood
  y ~ normal(a1*exp(-alpha1*x) + a2*exp(-alpha2*(x - mu2) - exp(-gamma2*(x - mu2))) + a3*exp(-alpha3*(x - mu3) - exp(-gamma3*(x - mu3))) + c, sigma);
  
  //priors
  alpha1 ~ normal(0,1);
  alpha2 ~ normal(0,1);
  alpha3 ~ normal(0,1);
  a1 ~ normal(0,1);
  a2 ~ normal(0,1);
  a3 ~ normal(0,1);
  c ~ normal(0,1);
  mu2 ~ normal(25,3);
  mu3 ~ normal(50,3);
  gamma2 ~ normal(0,1);
  gamma3 ~ normal(0,1);
  sigma ~ normal(0,1);
}
