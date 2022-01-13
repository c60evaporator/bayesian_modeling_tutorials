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
  for (i in 1:N){
    sales[i] ~ normal(mu, sigma);
  }
}