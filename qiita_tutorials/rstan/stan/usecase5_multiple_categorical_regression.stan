// dataブロック（データの定義）
data {
  int N;       //データ数
  int N_cat_1; // カテゴリ変数1(品種=説明変数2)の要素数
  vector[N] sepal_width;//がくの幅(応答変数)
  vector[N] sepal_length;//がくの長さ(説明変数1)
  matrix[N, N_cat_1-1] species;//品種(説明変数2)
  
  int N_num_1; //予測の横軸要素数(説明変数1)
  vector[N_num_1] sepal_length_pred; //予測の横軸となる説明変数1のベクトル
  matrix[N_cat_1, N_cat_1-1] species_pred; //予測時の色分けに使用するカテゴリ変数(説明変数2)の行列
}

// parametersブロック（パラメータの定義）
parameters {
  real Intercept;//切片
  real b_sepal_length; //説明変数1の係数
  vector[N_cat_1-1] b_species; //説明変数2の係数(カテゴリ変数なので複数=ベクトルで保持)
  real<lower=0> sigma;//標準偏差
}

// transformed parametersブロック（中間パラメータの計算式を記述）
transformed parameters {
  //平均mu = Intercept + b_sepal_length*sepal_length + species*b_species
  //※ speciesは行列なので、係数ベクトルの前に行列を掛ける必要がある
  vector[N] mu = Intercept + b_sepal_length*sepal_length + species*b_species;
}

// modelブロック（モデル式を記述）
model {
  //標準偏差sigmaの正規分布
  sepal_width ~ normal(mu, sigma);
}

// generated quantitiesブロック（事後予測分布を記述）
generated quantities {
  vector[N_cat_1] mu_pred[N_num_1]; // muの事後分布(1次元目が説明変数1、2次元目が説明変数2)
  vector[N_cat_1] sepal_width_pred[N_num_1]; // 応答変数の事後分布（事後予測分布、1次元目が説明変数1、2次元目が説明変数2)
  // 事後予測分布を得る
  for (i_num_1 in 1:N_num_1){
    for (i_cat_1 in 1:N_cat_1){
      // muの事後分布
      mu_pred[i_num_1][i_cat_1] = Intercept + b_sepal_length*sepal_length_pred[i_num_1] + species_pred[i_cat_1]*b_species;
      // 事後予測分布
      sepal_width_pred[i_num_1][i_cat_1] = normal_rng(mu_pred[i_num_1][i_cat_1], sigma);
    }
  }
}