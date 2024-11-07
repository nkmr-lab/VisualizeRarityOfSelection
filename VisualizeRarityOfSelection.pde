int num_of_times  = 1000000;

// 実験の選択肢の数
int num_of_choices = 4;

// 実験のN数
int num_of_trials = 1000;

float target_percent = 30.0;

// 1%を何分割して表示するか（N数/100の値だときれいになる）
int num_of_unit_1percent = 10; // 1695なら16.95で17

// それをどの大きさで表示するか
int x_unit_size = 4;
// 全体で何%から何%まで表示するか
int min_x_percent = 15;
int max_x_percent = 35;

int windowHeight = 900;
int windowWidth; // 横幅は自動で決まる
int graphBottomMargin = 40;

int[] graph_unit;

float calcSelectionRate(int num_of_selection, int num_of_trials)
{
  int count = 0;
  for (int i = 0; i < num_of_trials; i++) {
    if ((int)random(num_of_selection) == 0) {
      count++;
    }
  }
  return (float)count * 100 / num_of_trials;
}

void setup() 
{
  int windowWidth = (max_x_percent - min_x_percent + 1) * num_of_unit_1percent * x_unit_size;
  surface.setResizable(false);
  surface.setSize(windowWidth, windowHeight);
  textAlign(CENTER, CENTER);
  graph_unit = new int[num_of_unit_1percent * 100 + 1];
  for (int i = 0; i < graph_unit.length; i++) graph_unit[i] = 0;

  // ひたすら実施
  for (int i = 0; i < num_of_times; i++) {
    int xid = int(calcSelectionRate(num_of_choices, num_of_trials) * num_of_unit_1percent);
    graph_unit[xid]++;
    // 進捗を提示
    if((i % (num_of_times/10)) == 0) println("#" + i);
  }
}

void draw(){
  background(255);
  
  // 軸情報を表示
  textSize(20);
  fill(0);
  line(0, height-graphBottomMargin, width, height-graphBottomMargin);
  for (int p = min_x_percent; p <= max_x_percent; p++) {
    int x = (p - min_x_percent) * x_unit_size * num_of_unit_1percent;
    text(int(p), x, height-30);

    stroke(100);
    strokeWeight(1);
    line(x, height-graphBottomMargin, x, 0);
  }

  // 縦軸の調整のために最大値を求める
  int maxHeight = graph_unit[0];
  for (int i = 0; i < graph_unit.length; i++) {
    if(maxHeight < graph_unit[i]) maxHeight = graph_unit[i];
  }

  // 閾値の設定
  int[] threshold = new int[4];
  // 両側1%
  threshold[0] = (num_of_times * 1 / 200);
  threshold[1] = (num_of_times * 1 / 40);
  // 両側5%
  threshold[2] = (num_of_times * 39 / 40);
  threshold[3] = (num_of_times * 199 / 200);
  
  int total = 0;
  int cur_th = 0;
  for (int i = 0; i < graph_unit.length; i++) {
    // 色つけのために利用。実をいうと閾値ギリギリのところはこれじゃあかん気がする
    if ( cur_th < 4 && total < threshold[cur_th] && threshold[cur_th] < total + graph_unit[i] ) {
      cur_th++;
    }
    // 閾値ごとの色を設定
    if (cur_th == 0) fill(255, 100, 100);
    else if (cur_th == 1) fill(255, 220, 220);
    else if (cur_th == 2) fill(220, 220, 220);
    else if (cur_th == 3) fill(220, 220, 255);
    else fill(100, 100, 255);
    // 描画するで
    if((i / num_of_unit_1percent) >= min_x_percent && (i / num_of_unit_1percent) <= max_x_percent){
      int x = (i - min_x_percent * num_of_unit_1percent) * x_unit_size;
      rect(x, height-graphBottomMargin, x_unit_size, -graph_unit[i] * ((float)height * 0.9 / maxHeight));
    }
    total += graph_unit[i];
  }

  strokeWeight(3);
  stroke(255, 0, 0);
  int x = int((target_percent - min_x_percent) * x_unit_size * num_of_unit_1percent);
  line(x, height-graphBottomMargin, x, 0);
  strokeWeight(1);
  fill(255, 0, 0, 50);
  rect(x, 0, width-x, height-graphBottomMargin);

  // 結果を表示
  textAlign(LEFT, CENTER);
  textSize(96);
  fill(100, 100, 255);
  text(num_of_choices + " choices", width/2+50, 100);
  text("N = " + num_of_trials, width/2+50, 200);
  textSize(48);
  text("(" + num_of_times + " times)", width/2+50, 300); 
  // 画像として保存
  save(num_of_trials+".png");
  noLoop();
}
