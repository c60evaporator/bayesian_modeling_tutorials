// dataブロック（データの定義）
data {
  int N;       //データ数
  int K;       //デザイン行列の列数(説明変数の数+1)
  vector[N] Y;//応答変数
  matrix[N, K] X;//デザイン行列
}

// parametersブロック（パラメータの定義）
parameters {
  vector[K] b; //切片を含む係数ベクトル
  real<lower=0> sigma;//標準偏差
}

// modelブロック（モデル式を記述）
model {
  vector [N] mu = X * b; //平均mu=デザイン行列*係数ベクトル
  Y ~ normal(mu, sigma); //平均mu、標準偏差sigmaの正規分布
}