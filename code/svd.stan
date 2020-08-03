data {
  int X;
  int S;
  int T;
  int K;
  int N;
  int deaths[N];
  vector[N] log_pop;
  int age_i[N];
  int state_i[N];
  int year_i[N];
  real Y[X,K];
}
parameters {
  real beta[S,T,K];
  real mu_beta[T,K];
  real<lower=0> sigma;
  real<lower=0> sigma_beta[K];
  real<lower=0> sigma_mu_beta[K];
}
transformed parameters{
  real yhat[X,S,T];
  vector[N] mu;
  
  for(x in 1:X){
    for(s in 1:S){
      for(t in 1:T){
        yhat[x,s,t] = beta[s,t,1]*Y[x,1]+ beta[s,t,2]*Y[x,2]+beta[s,t,3]*Y[x,3]; //+ eps[x,s,t] <- could add this for more flexibility
      }
    }
  }
  
  for(i in 1:N){
    mu[i] = yhat[age_i[i], state_i[i], year_i[i]] + log_pop[i];
  }
  
}
model {
  
  deaths ~ poisson_log(mu);
  
  for(s in 1:S){
    for(k in 1:K){
        beta[s,,k] ~ normal(mu_beta[,k], sigma_beta[k]); 
      }
    }
    
    for(k in 1:K){
        mu_beta[1,k] ~ normal(0,10); 
        mu_beta[2:T,k] ~ normal(mu_beta[1:(T-1),k],sigma_mu_beta[k]); 
    }
    sigma ~ normal(0,1);
    sigma_beta ~ normal(0,1);
    sigma_mu_beta ~ normal(0,1);
  
  
}
generated quantities{


}