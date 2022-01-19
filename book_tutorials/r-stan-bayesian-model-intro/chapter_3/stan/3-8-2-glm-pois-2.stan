// dataブロック（データの定義）
data {
  int N;        //データ数
  int fish_num[N]; //応答変数(釣獲尾数、ポアソン分布なので整数型)
  vector[N] temp;//説明変数(気温)
  vector[N] sunny;//説明変数(晴れダミー変数)
  
  int N_pred;  //予測対象データの大きさ
  vector[N_pred] temp_pred;  //予測の横軸となる気温
}

// parametersブロック（パラメータの定義）
parameters {
  real Intercept; //切片
  real b_temp;    //気温の係数
  real b_sunny;   //晴れダミー変数の係数
}

// modelブロック（モデル式を記述）
model {
  vector[N] log_lambda = Intercept + b_temp*temp + b_sunny*sunny; //log(lambda)
  fish_num ~ poisson_log(log_lambda); //ポアソン分布+リンク関数(対数関数)
}

// generated quantitiesブロック（事後予測分布を記述）
generated quantities {
  vector[N_pred] lambda_pred_sunny; // 晴れ時のlambdaの事後分布
  vector[N_pred] fish_num_pred_sunny; // 晴れ時の応答変数事後分布(事後予測分布)
  vector[N_pred] lambda_pred_cloudy; // 曇り時のlambdaの事後分布
  vector[N_pred] fish_num_pred_cloudy; // 曇り時の応答変数事後分布(事後予測分布)
  // 事後予測分布を得る
  //(lambdaの事後分布を信用区間用に求めたいので、対数を取らないことに注意)
  for (i in 1:N_pred){
    // 晴れ時の事後予測分布
    lambda_pred_sunny[i] = exp(Intercept + b_temp*temp_pred[i] + b_sunny);
    fish_num_pred_sunny[i] = poisson_rng(lambda_pred_sunny[i]);
    // 曇り時の事後予測分布
    lambda_pred_cloudy[i] = exp(Intercept + b_temp*temp_pred[i]);
    fish_num_pred_cloudy[i] = poisson_rng(lambda_pred_cloudy[i]);
  }
}