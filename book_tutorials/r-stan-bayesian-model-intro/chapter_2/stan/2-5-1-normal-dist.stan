// dataブロック（データの定義）
data {
  int N;//サンプルサイズ
  vector[N] animal_num;//データ
}

// parametersブロック（パラメータの定義）
parameters {
  real<lower=0> mu;//平均
  real<lower=0> sigma;//標準偏差
}

// modelブロック（モデル式を記述）
model {
  // 平均mu, 標準偏差sigmaの正規分布
  animal_num ~ normal(mu, sigma);
}

// generated quantitiesブロック（事後予測分布を記述）
generated quantities {
  // 事後予測分布を得る
  vector[N] pred;
  for (i in 1:N){
    pred[i] = normal_rng(mu, sigma);
  }
}