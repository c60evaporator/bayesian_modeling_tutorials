// dataブロック（データの定義）
data {
  int N;//データ数
  vector[N] sepal_width;//応答変数
}

// parametersブロック（パラメータの定義）
parameters {
  real mu;//平均
  real<lower=0> sigma;//標準偏差
}

// modelブロック（モデル式を記述）
model {
  for (i in 1:N){
    sepal_width[i] ~ normal(mu, sigma);//sepal_widthは平均mu、標準偏差sigmaの正規分布に従う
  }
}

// generated quantitiesブロック（事後予測分布を記述）
generated quantities {
  // 事後予測分布を得る
  vector[N] pred;
  for (i in 1:N){
    pred[i] = normal_rng(mu, sigma);
  }
}