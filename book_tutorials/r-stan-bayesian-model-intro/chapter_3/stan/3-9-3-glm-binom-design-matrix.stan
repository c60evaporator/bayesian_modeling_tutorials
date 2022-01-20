// dataブロック（データの定義）
data {
  int N;       //データ数
  int K;       //デザイン行列の列数(説明変数の数+1)
  int Y[N];    //応答変数(発芽数、二項分布なので整数型)
  int binom_size[N]; // 二項分布の試行回数
  matrix[N, K] X;//デザイン行列
}

// parametersブロック（パラメータの定義）
parameters {
  vector[K] b; //切片を含む係数ベクトル
}

// modelブロック（モデル式を記述）
model {
  vector[N] logit_p = X * b; //log(lambda)=デザイン行列*係数ベクトル
  Y ~ binomial_logit(binom_size, logit_p); //二項分布+リンク関数(ロジット関数)
}