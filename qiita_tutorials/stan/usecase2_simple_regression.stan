// dataブロック（データの定義）
data {
  int N;       //データ数
  vector[N] petal_width;//花弁の幅(応答変数)
  vector[N] petal_length;//花弁の長さ(説明変数)
  
  int N_pred;  //予測の横軸要素数
  vector[N_pred] petal_length_pred;  //予測の横軸となる説明変数のベクトル
}

// parametersブロック（パラメータの定義）
parameters {
  real Intercept;//切片
  real beta; //係数
  real<lower=0> sigma;//標準偏差
}

// transformed parametersブロック（中間パラメータの計算式を記述）
transformed parameters {
  //平均mu = intercept + beta*petal_length
  vector[N] mu = Intercept + beta*petal_length;
}

// modelブロック（モデル式を記述）
model {
  //平均mu、標準偏差sigmaの正規分布
  petal_width ~ normal(mu, sigma);
}

// generated quantitiesブロック（事後予測分布を記述）
generated quantities {
  vector[N_pred] mu_pred; // 期待値muの事後分布
  vector[N_pred] petal_width_pred; // 応答変数の事後分布（事後予測分布）
  // 事後予測分布を得る
  for (i in 1:N_pred){
    mu_pred[i] = Intercept + beta*petal_length_pred[i];
    petal_width_pred[i] = normal_rng(mu_pred[i], sigma);
  }
}