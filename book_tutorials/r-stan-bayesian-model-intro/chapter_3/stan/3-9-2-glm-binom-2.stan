// dataブロック（データの定義）
data {
  int N;        //データ数
  int germination[N]; //応答変数(発芽数、二項分布なので整数型)
  int binom_size[N]; // 二項分布の試行回数
  vector[N] nutrition;//説明変数(栄養量)
  vector[N] solar;//説明変数(晴れダミー変数)
  
  int N_pred_nutr;  //予測対象データの大きさ(栄養量)
  int N_pred_size;  //予測対象データの大きさ(二項分布試行数)
  vector[N_pred_nutr] nutr_pred;  //予測の横軸となる栄養量
  int size_pred[N_pred_size];  //予測の横軸となる二項分布試行数
}

// parametersブロック（パラメータの定義）
parameters {
  real Intercept;   //切片
  real b_nutrition; //栄養量の係数
  real b_solar;     //晴れダミー変数の係数
}

// modelブロック（モデル式を記述）
model {
  vector[N] logit_p = Intercept + b_solar*solar + b_nutrition*nutrition; //logit(p)
  germination ~ binomial_logit(binom_size, logit_p); //二項分布+リンク関数(ロジット関数)
}

// generated quantitiesブロック（事後予測分布を記述）
generated quantities {
  vector[N_pred_nutr] p_pred_sunshine; // 晴れ時のpの事後分布
  vector[N_pred_nutr] germ_pred_sunshine[N_pred_size]; // 晴れ時の応答変数事後分布
  vector[N_pred_nutr] p_pred_shade; // 曇り時のpの事後分布
  vector[N_pred_nutr] germ_pred_shade[N_pred_size]; // 曇り時の応答変数事後分布
  // 事後予測分布を得る
  //(pの事後分布を信用区間用に求めたいので、ロジット変換することに注意)
  for (i in 1:N_pred_nutr){
    // 確率期待値pの事後分布
    p_pred_sunshine[i] = inv_logit(Intercept + b_nutrition*nutr_pred[i] + b_solar); // 晴れ
    p_pred_shade[i] = inv_logit(Intercept + b_nutrition*nutr_pred[i]); // 曇り
    for (j in 1:N_pred_size){
      // 事後予測分布
      germ_pred_sunshine[j][i] = binomial_rng(size_pred[j], p_pred_sunshine[i]); // 晴れ
      germ_pred_shade[j][i] = binomial_rng(size_pred[j], p_pred_shade[i]); // 曇り
    }
  }
}