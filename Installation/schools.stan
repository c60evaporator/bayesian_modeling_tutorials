data {
  int<lower=0> J;         // 学校の数
  real y[J];              // 推定されている教育の効果
  real<lower=0> sigma[J]; // 教育の効果の標準誤差
}

parameters {
  real mu;                // 処置の効果（全体平均）
  real<lower=0> tau;      // 処置の効果の標準偏差
  vector[J] eta;          // 学校ごとのスケール前のバラつき
}

transformed parameters {
  vector[J] theta = mu + tau * eta;        // 学校ごとの処置の効果
}

model {
  target += normal_lpdf(eta | 0, 1);       // 事前分布の対数密度
  target += normal_lpdf(y | theta, sigma); // 対数尤度
}