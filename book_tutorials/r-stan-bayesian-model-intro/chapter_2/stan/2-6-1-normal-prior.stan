// dataブロック（データの定義）
data {
  int N;//サンプルサイズ
  vector[N] sales;//データ
}

// parametersブロック（パラメータの定義）
parameters {
  real mu;//平均
  real<lower=0> sigma;//標準偏差
}

// modelブロック（モデル式を記述）
model {
  //事前分布
  mu ~ normal(0, 1000000);
  sigma ~ normal(0, 1000000);
  //モデル式
  for (i in 1:N){
    sales[i] ~ normal(mu, sigma);
  }
}