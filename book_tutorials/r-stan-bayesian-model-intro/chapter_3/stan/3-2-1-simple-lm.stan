// dataブロック（データの定義）
data {
  int N;//サンプルサイズ
  vector[N] sales;//売上データ(応答変数)
  vector[N] temperature;//気温データ(説明変数)
}

// parametersブロック（パラメータの定義）
parameters {
  real intercept;//切片
  real beta; //係数
  real<lower=0> sigma;//標準偏差
}

// modelブロック（モデル式を記述）
model {
  //平均intercept + beta*temperature、標準偏差sigma
  for (i in 1:N){
    sales[i] ~ normal(intercept + beta*temperature[i], sigma);
  }
}