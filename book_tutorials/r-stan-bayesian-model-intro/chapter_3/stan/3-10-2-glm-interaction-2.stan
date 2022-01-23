// dataブロック（データの定義）
data {
  int N;        //データ数
  int N_cat_1; // カテゴリ変数1(宣伝)の要素数
  vector[N] sales; //応答変数(売上)
  matrix[N, N_cat_1-1] publicity;//説明変数(宣伝ダミー変数)
  vector[N] temperature;//説明変数(気温)
    
  
  int N_numeric_1; // 数値変数1(気温)の予測用要素数
  matrix[N_cat_1, N_cat_1-1] publicity_pred;  //カテゴリ変数1(宣伝)の予測用値格納用
  vector[N_numeric_1] temp_pred;  //数値変数1(気温)の予測用値格納用
}

// parametersブロック（パラメータの定義）
parameters {
  real Intercept;     //切片
  vector[N_cat_1-1] b_publicity; //宣伝ダミー変数の係数
  real b_temperature;            //気温の係数
  vector[N_cat_1-1] b_inter;     //交互作用の係数
  real<lower=0> sigma;//標準偏差
}

// modelブロック（モデル式を記述）
model {
  // 平均muの計算式(交互作用の項では行列の要素同士の積.*を使うので注意)
  vector[N] mu = Intercept + publicity*b_publicity + b_temperature*temperature + publicity*b_inter .* temperature;
  sales ~ normal(mu, sigma); //正規分布
}

// generated quantitiesブロック（事後予測分布を記述）
generated quantities {
  vector[N_numeric_1] mu_pred[N_cat_1]; // muの事後分布(1次元目が宣伝、2次元目が気温)
  vector[N_numeric_1] sales_pred[N_cat_1]; // 応答変数の事後分布（事後予測分布、1次元目が宣伝、2次元目が気温)
  // 事後予測分布を得る
  for (i_cat_1 in 1:N_cat_1){
    for (i_num_1 in 1:N_numeric_1){
      // muの事後分布
      mu_pred[i_cat_1][i_num_1] = Intercept + publicity_pred[i_cat_1]*b_publicity + b_temperature*temp_pred[i_num_1] + publicity_pred[i_cat_1]*b_inter .*temp_pred[i_num_1];
      // 事後予測分布
      sales_pred[i_cat_1][i_num_1] = normal_rng(mu_pred[i_cat_1][i_num_1], sigma);
    }
  }
}