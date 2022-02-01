// dataブロック（データの定義）
data {
  int N;       //データ数
  vector[N] petal_width;//花弁の幅(応答変数)
  vector[N] petal_length;//花弁の長さ(説明変数1)
  vector[N] sepal_length;//がくの長さ(説明変数2)
  
  int N_pred_1;  //予測の横軸要素数(説明変数1)
  int N_pred_2;  //図プロット縦軸要素数(説明変数2)
  vector[N_pred_1] petal_length_pred;  //予測の横軸となる説明変数1のベクトル
  vector[N_pred_2] sepal_length_pred;  //図プロット縦軸となる説明変数2のベクトル
}

// parametersブロック（パラメータの定義）
parameters {
  real Intercept;//切片
  real b_petal_length; //説明変数1の係数
  real b_sepal_length; //説明変数2の係数
  real<lower=0> sigma;//標準偏差
}

// transformed parametersブロック（中間パラメータの計算式を記述）
transformed parameters {
  //平均mu = Intercept + b_petal_length*petal_length + b_sepal_length*sepal_length
  vector[N] mu = Intercept + b_petal_length*petal_length + b_sepal_length*sepal_length;
}

// modelブロック（モデル式を記述）
model {
  //標準偏差sigmaの正規分布
  petal_width ~ normal(mu, sigma);
}

// generated quantitiesブロック（事後予測分布を記述）
generated quantities {
  vector[N_pred_2] mu_pred[N_pred_1]; // muの事後分布(1次元目が説明変数1、2次元目が説明変数2)
  vector[N_pred_2] petal_width_pred[N_pred_1]; // 応答変数の事後分布（事後予測分布、1次元目が説明変数1、2次元目が説明変数2)
  // 事後予測分布を得る
  for (i_1 in 1:N_pred_1){
    for (i_2 in 1:N_pred_2){
      // muの事後分布
      mu_pred[i_1][i_2] = Intercept + b_petal_length*petal_length_pred[i_1] + b_sepal_length*sepal_length_pred[i_2];
      // 事後予測分布
      petal_width_pred[i_1][i_2] = normal_rng(mu_pred[i_1][i_2], sigma);
    }
  }
}