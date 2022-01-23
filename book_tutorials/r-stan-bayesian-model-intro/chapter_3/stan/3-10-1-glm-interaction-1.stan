// dataブロック（データの定義）
data {
  int N;        //データ数
  vector[N] sales; //応答変数(売上)
  vector[N] publicity;//説明変数(宣伝ダミー変数)
  vector[N] bargen;//説明変数(安売りダミー変数)
    
  int N_bool_1; // カテゴリ変数1(宣伝)の要素数
  int N_bool_2; // カテゴリ変数2(安売り)の要素数
  int publicity_pred[N_bool_1];  //カテゴリ変数1(宣伝)の予測値格納用(1と0のリスト)
  int bargen_pred[N_bool_2];  //カテゴリ変数2(安売り)の予測値格納用(1と0のリスト)
}

// parametersブロック（パラメータの定義）
parameters {
  real Intercept;     //切片
  real b_publicity;   //宣伝ダミー変数の係数
  real b_bargen;      //安売りダミー変数の係数
  real b_inter;       //交互作用の係数
  real<lower=0> sigma;//標準偏差
}

// modelブロック（モデル式を記述）
model {
  // 平均muの計算式(交互作用の項ではベクトルの要素同士の積.*を使うので注意)
  vector[N] mu = Intercept + b_publicity*publicity + b_bargen*bargen + b_inter*publicity .* bargen;
  sales ~ normal(mu, sigma); //正規分布
}

// generated quantitiesブロック（事後予測分布を記述）
generated quantities {
  vector[N_bool_2] mu_pred[N_bool_1]; // muの事後分布(1次元目が宣伝、2次元目が安売り)
  vector[N_bool_2] sales_pred[N_bool_1]; // 応答変数の事後分布（事後予測分布、1次元目が宣伝、2次元目が安売り)
  // 事後予測分布を得る
  for (i_1 in 1:N_bool_1){
    for (i_2 in 1:N_bool_2){
      // muの事後分布
      mu_pred[i_1][i_2] = Intercept + b_publicity*publicity_pred[i_1] + b_bargen*bargen_pred[i_2] + b_inter*publicity_pred[i_1] .*bargen_pred[i_2];
      // 事後予測分布
      sales_pred[i_1][i_2] = normal_rng(mu_pred[i_1][i_2], sigma);
    }
  }
}