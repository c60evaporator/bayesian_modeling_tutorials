// dataブロック（データの定義）
data {
  int N_setosa;       //setosaのデータ数
  int N_versicolor;       //versicolorのデータ数
  int N_virginica;       //virginicaのデータ数
  vector[N_setosa] sepal_width_setosa;//花弁の幅(setosa)
  vector[N_versicolor] sepal_width_versicolor;//花弁の幅(versicolor)
  vector[N_virginica] sepal_width_virginica;//花弁の幅(virginica)
}

// parametersブロック（パラメータの定義）
parameters {
  real mu_setosa;       //setosaの平均
  real mu_versicolor;       //versicolorの平均
  real mu_virginica;       //virginicaの平均
  real<lower=0> sigma_setosa;     //setosaの標準偏差
  real<lower=0> sigma_versicolor; //versicolorの標準偏差
  real<lower=0> sigma_virginica;  //virginicaの標準偏差
}

// modelブロック（モデル式を記述）
model {
  sepal_width_setosa ~ normal(mu_setosa, sigma_setosa);
  sepal_width_versicolor ~ normal(mu_versicolor, sigma_versicolor);
  sepal_width_virginica ~ normal(mu_virginica, sigma_virginica);
}

// generated quantitiesブロック（事後予測分布を記述）
generated quantities {
  real diff_virginica_setosa = mu_setosa - mu_virginica;
  real diff_virginica_versicolor = mu_versicolor - mu_virginica;
}