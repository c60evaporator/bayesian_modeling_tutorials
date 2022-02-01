// dataブロック（データの定義）
data {
  int N;       //データ数
  int N_cat; // カテゴリ変数(品種)の要素数
  vector[N] sepal_width;//花弁の幅(応答変数)
  matrix[N, N_cat-1] species;//説明変数(品種ダミー変数)
  
  matrix[N_cat, N_cat-1] species_pred;  //予測の横軸となるカテゴリ説明変数の行列
}

// parametersブロック（パラメータの定義）
parameters {
  real Intercept;//切片
  vector[N_cat-1] b_species;//品種ダミー変数の係数
  real<lower=0> sigma;//標準偏差
}

// transformed parametersブロック（中間パラメータの計算式を記述）
transformed parameters {
  //平均mu = Intercept + species*b_species
  vector[N] mu = Intercept + species*b_species;
}

// modelブロック（モデル式を記述）
model {
  //平均mu、標準偏差sigmaの正規分布
  sepal_width ~ normal(mu, sigma); //正規分布
}

// generated quantitiesブロック（事後予測分布を記述）
generated quantities {
  vector[N_cat] mu_pred; // 平均の事後分布
  vector[N_cat] sepal_width_pred; // 応答変数の事後分布（事後予測分布）
  // 事後予測分布を得る
  for (i in 1:N_cat){
    mu_pred[i] = Intercept + species_pred[i]*b_species;
    sepal_width_pred[i] = normal_rng(mu_pred[i], sigma);
  }
}