// dataブロック（データの定義）
data {
  int N;       //データ数
  int K;       //デザイン行列の列数(説明変数の数+1)
  int Y[N];    //応答変数(釣獲尾数、ポアソン分布なので整数型)
  matrix[N, K] X;//デザイン行列
}

// parametersブロック（パラメータの定義）
parameters {
  vector[K] b; //切片を含む係数ベクトル
}

// modelブロック（モデル式を記述）
model {
  vector[N] log_lambda = X * b; //log(lambda)=デザイン行列*係数ベクトル
  Y ~ poisson_log(log_lambda); //ポアソン分布+リンク関数(対数関数)
}