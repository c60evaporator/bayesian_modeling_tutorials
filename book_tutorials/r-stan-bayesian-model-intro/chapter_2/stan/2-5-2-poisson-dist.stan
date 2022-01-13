// dataブロック（データの定義）
data {
  int N;//サンプルサイズ
  int animal_num[N];//データ
}

// parametersブロック（パラメータの定義）
parameters {
  real<lower=0> lambda;//強度
}

// modelブロック（モデル式を記述）
model {
  // 強度lambdaのポアソン分布
  animal_num ~ poisson(lambda);
}

// generated quantitiesブロック（事後予測分布を記述）
generated quantities {
  // 事後予測分布を得る
  vector[N] pred;
  for (i in 1:N){
    pred[i] = poisson_rng(lambda);
  }
}