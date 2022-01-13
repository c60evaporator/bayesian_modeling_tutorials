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
  target += normal_lpdf(mu|0, 1000000);
  target += normal_lpdf(sigma|0, 1000000);
  //モデル式
  for (i in 1:N) {
    target += normal_lpdf(sales[i]|mu, sigma);
  }
}