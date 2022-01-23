// dataブロック（データの定義）
data {
  int N;        //データ数
  vector[N] sales; //応答変数(売上)
  vector[N] clerk;//説明変数(店員数)
  vector[N] product;//説明変数(商品数)
  
  int N_numeric_1; // 数値変数1(店員数)の予測用要素数
  int N_numeric_2; // 数値変数2(商品数)の予測用要素数
  vector[N_numeric_1] clerk_pred;  //数値変数1(店員数)の予測用値格納用
  vector[N_numeric_2] product_pred;  //数値変数2(商品数)の予測用値格納用
}

// parametersブロック（パラメータの定義）
parameters {
  real Intercept;     //切片
  real b_clerk;       //店員数の係数
  real b_product;     //商品数の係数
  real b_inter;       //交互作用の係数
  real<lower=0> sigma;//標準偏差
}

// modelブロック（モデル式を記述）
model {
  // 平均muの計算式(交互作用の項では行列の要素同士の積.*を使うので注意)
  vector[N] mu = Intercept + b_clerk*clerk + b_product*product + b_inter*clerk .* product;
  sales ~ normal(mu, sigma); //正規分布
}

// generated quantitiesブロック（事後予測分布を記述）
generated quantities {
  vector[N_numeric_2] mu_pred[N_numeric_1]; // muの事後分布(1次元目が店員数、2次元目が商品数)
  vector[N_numeric_2] sales_pred[N_numeric_1]; // 応答変数の事後分布（事後予測分布、1次元目が店員数、2次元目が商品数)
  // 事後予測分布を得る
  for (i_num_1 in 1:N_numeric_1){
    for (i_num_2 in 1:N_numeric_2){
      // muの事後分布
      mu_pred[i_num_1][i_num_2] = Intercept + b_clerk*clerk_pred[i_num_1] + b_product*product_pred[i_num_2] + b_inter*clerk_pred[i_num_1] .*product_pred[i_num_2];
      // 事後予測分布
      sales_pred[i_num_1][i_num_2] = normal_rng(mu_pred[i_num_1][i_num_2], sigma);
    }
  }
}