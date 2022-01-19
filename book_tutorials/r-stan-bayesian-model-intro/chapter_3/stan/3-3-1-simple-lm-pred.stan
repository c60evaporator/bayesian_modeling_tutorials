// dataブロック（データの定義）
data {
  int N;       //データ数
  vector[N] sales;//売上データ(応答変数)
  vector[N] temperature;//気温データ(説明変数)
  
  int N_pred;  //予測対象データの大きさ
  vector[N_pred] temperature_pred;  //予測の横軸となる気温
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

// generated quantitiesブロック（事後予測分布を記述）
generated quantities {
  vector[N_pred] mu_pred; // 売上平均の事後分布
  vector[N_pred] sales_pred; // 応答変数の事後分布（事後予測分布）
  // 事後予測分布を得る
  for (i in 1:N_pred){
    mu_pred[i] = intercept + beta*temperature_pred[i];
    sales_pred[i] = normal_rng(mu_pred[i], sigma);
  }
}