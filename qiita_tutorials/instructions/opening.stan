data {
  int<lower=0> N;
  vector[N] y;
  vector[N] x;
  
  int<lower=0> N_pred;
  vector[N_pred] x_pred;
}

parameters {
  real Intercept;
  real beta;
  real<lower=0> sigma;
}

transformed parameters {
  vector[N] mu = Intercept + beta*x;
}

model {
  y ~ normal(mu, sigma);
  Intercept ~ normal(0, 1000000);//Interceptの事前分布
  beta ~ normal(0, 1000000);//betaの事前分布
  sigma ~ normal(0, 1000000);//sigmaの事前分布
}

generated quantities {
  vector[N_pred] mu_pred; // muの事後分布(1次元目が説明変数1、2次元目が説明変数2)
  vector[N_pred] y_pred; // 応答変数の事後分布（事後予測分布、1次元目が説明変数1、2次元目が説明変数2)
  for (i in 1:N_pred){
      // muの事後分布
      mu_pred[i] = Intercept + beta*x_pred[i];
      y_pred[i] = normal_rng(mu_pred[i], sigma);
  }
}